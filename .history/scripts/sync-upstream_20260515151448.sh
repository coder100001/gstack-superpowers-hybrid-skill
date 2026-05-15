#!/bin/bash

# sync-upstream.sh - 同步上游 superpowers 和 gstack 更新
# 用法: ./scripts/sync-upstream.sh [选项]
#   --superpowers    仅同步 superpowers
#   --gstack         仅同步 gstack
#   --check          检查更新但不执行
#   --dry-run        显示将要执行的操作
#   --backup         同步前备份
#   --rollback       回滚到上一个备份

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/.upstream-versions.json"
BACKUP_DIR="$PROJECT_ROOT/.backups"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 解析参数
SYNC_SUPERPOWERS=false
SYNC_GSTACK=false
CHECK_ONLY=false
DRY_RUN=false
BACKUP=false
ROLLBACK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --superpowers) SYNC_SUPERPOWERS=true; shift ;;
        --gstack) SYNC_GSTACK=true; shift ;;
        --check) CHECK_ONLY=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --backup) BACKUP=true; shift ;;
        --rollback) ROLLBACK=true; shift ;;
        *) log_error "未知参数: $1"; exit 1 ;;
    esac
done

# 如果没有指定，则同步所有
if [[ "$SYNC_SUPERPOWERS" == "false" && "$SYNC_GSTACK" == "false" ]]; then
    SYNC_SUPERPOWERS=true
    SYNC_GSTACK=true
fi

# 创建备份
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"
    
    log_info "创建备份到 $backup_path..."
    mkdir -p "$backup_path"
    
    # 备份 skills 目录
    if [[ -d "$PROJECT_ROOT/skills" ]]; then
        cp -r "$PROJECT_ROOT/skills" "$backup_path/"
    fi
    
    # 备份 gstack-skills 目录
    if [[ -d "$PROJECT_ROOT/gstack-skills" ]]; then
        cp -r "$PROJECT_ROOT/gstack-skills" "$backup_path/"
    fi
    
    # 备份版本文件
    if [[ -f "$VERSION_FILE" ]]; then
        cp "$VERSION_FILE" "$backup_path/"
    fi
    
    log_success "备份完成: $backup_path"
    echo "$backup_path" > "$BACKUP_DIR/latest"
}

# 回滚
do_rollback() {
    if [[ ! -f "$BACKUP_DIR/latest" ]]; then
        log_error "没有找到备份"
        exit 1
    fi
    
    local backup_path=$(cat "$BACKUP_DIR/latest")
    
    if [[ ! -d "$backup_path" ]]; then
        log_error "备份目录不存在: $backup_path"
        exit 1
    fi
    
    log_info "从 $backup_path 回滚..."
    
    # 恢复 skills
    if [[ -d "$backup_path/skills" ]]; then
        rm -rf "$PROJECT_ROOT/skills"
        cp -r "$backup_path/skills" "$PROJECT_ROOT/"
    fi
    
    # 恢复 gstack-skills
    if [[ -d "$backup_path/gstack-skills" ]]; then
        rm -rf "$PROJECT_ROOT/gstack-skills"
        cp -r "$backup_path/gstack-skills" "$PROJECT_ROOT/"
    fi
    
    log_success "回滚完成"
}

# 同步 superpowers
sync_superpowers() {
    log_info "同步 superpowers..."
    
    local SUPERPOWERS_PATH="$HOME/.trae-cn/superpowers"
    
    if [[ ! -d "$SUPERPOWERS_PATH" ]]; then
        log_error "Superpowers 目录不存在: $SUPERPOWERS_PATH"
        log_info "请先安装 superpowers 或检查路径"
        return 1
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 将从 $SUPERPOWERS_PATH 复制以下内容:"
        ls -la "$SUPERPOWERS_PATH/skills/" 2>/dev/null || true
        return 0
    fi
    
    if [[ "$CHECK_ONLY" == "true" ]]; then
        log_info "检查 superpowers 更新..."
        # 这里可以添加版本比较逻辑
        return 0
    fi
    
    # 同步核心文件
    log_info "复制 superpowers 核心文件..."
    cp -r "$SUPERPOWERS_PATH/skills/"* "$PROJECT_ROOT/skills/" 2>/dev/null || true
    cp -r "$SUPERPOWERS_PATH/agents" "$PROJECT_ROOT/" 2>/dev/null || true
    cp -r "$SUPERPOWERS_PATH/commands" "$PROJECT_ROOT/" 2>/dev/null || true
    cp -r "$SUPERPOWERS_PATH/hooks" "$PROJECT_ROOT/" 2>/dev/null || true
    
    # 同步配置文件
    cp "$SUPERPOWERS_PATH/CLAUDE.md" "$PROJECT_ROOT/" 2>/dev/null || true
    cp "$SUPERPOWERS_PATH/GEMINI.md" "$PROJECT_ROOT/" 2>/dev/null || true
    cp "$SUPERPOWERS_PATH/package.json" "$PROJECT_ROOT/" 2>/dev/null || true
    
    log_success "Superpowers 同步完成"
}

# 同步 gstack
sync_gstack() {
    log_info "同步 gstack..."
    
    local GSTACK_PATH="$HOME/.claude/skills/gstack"
    
    if [[ ! -d "$GSTACK_PATH" ]]; then
        log_error "GStack 目录不存在: $GSTACK_PATH"
        log_info "请先安装 gstack 或检查路径"
        return 1
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 将从 $GSTACK_PATH 复制以下内容:"
        ls -la "$GSTACK_PATH/" 2>/dev/null | head -20
        return 0
    fi
    
    if [[ "$CHECK_ONLY" == "true" ]]; then
        log_info "检查 gstack 更新..."
        if [[ -f "$GSTACK_PATH/VERSION" ]]; then
            local gstack_version=$(cat "$GSTACK_PATH/VERSION")
            log_info "当前 gstack 版本: $gstack_version"
        fi
        return 0
    fi
    
    # 同步 gstack 技能
    log_info "复制 gstack 技能..."
    
    # gs-hybrid-v3
    if [[ -d "$GSTACK_PATH/../gs-hybrid-v3" ]]; then
        cp -r "$GSTACK_PATH/../gs-hybrid-v3" "$PROJECT_ROOT/skills/" 2>/dev/null || true
    fi
    
    # browse 技能
    if [[ -d "$GSTACK_PATH/browse" ]]; then
        mkdir -p "$PROJECT_ROOT/skills/gstack-browse"
        cp -r "$GSTACK_PATH/browse/"* "$PROJECT_ROOT/skills/gstack-browse/" 2>/dev/null || true
    fi
    
    # design 技能
    if [[ -d "$GSTACK_PATH/design" ]]; then
        cp -r "$GSTACK_PATH/design" "$PROJECT_ROOT/skills/" 2>/dev/null || true
    fi
    
    # review 技能
    if [[ -d "$GSTACK_PATH/review" ]]; then
        cp -r "$GSTACK_PATH/review" "$PROJECT_ROOT/skills/" 2>/dev/null || true
    fi
    
    # qa 技能
    if [[ -d "$GSTACK_PATH/qa" ]]; then
        cp -r "$GSTACK_PATH/qa" "$PROJECT_ROOT/skills/" 2>/dev/null || true
    fi
    
    # 同步工具脚本
    log_info "复制 gstack 工具脚本..."
    mkdir -p "$PROJECT_ROOT/gstack-skills"
    cp -r "$GSTACK_PATH/bin" "$PROJECT_ROOT/gstack-skills/" 2>/dev/null || true
    cp "$GSTACK_PATH/setup" "$PROJECT_ROOT/gstack-skills/" 2>/dev/null || true
    cp "$GSTACK_PATH/VERSION" "$PROJECT_ROOT/gstack-skills/" 2>/dev/null || true
    cp "$GSTACK_PATH/package.json" "$PROJECT_ROOT/gstack-skills/" 2>/dev/null || true
    
    log_success "GStack 同步完成"
}

# 更新版本文件
update_version_file() {
    local today=$(date +%Y-%m-%d)
    
    log_info "更新版本追踪文件..."
    
    # 获取版本信息
    local sp_version="unknown"
    local gs_version="unknown"
    
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        sp_version=$(grep -o '"version": *"[^"]*"' "$PROJECT_ROOT/package.json" | head -1 | cut -d'"' -f4)
    fi
    
    if [[ -f "$PROJECT_ROOT/gstack-skills/VERSION" ]]; then
        gs_version=$(cat "$PROJECT_ROOT/gstack-skills/VERSION")
    fi
    
    # 创建版本文件
    cat > "$VERSION_FILE" << EOF
{
  "superpowers": {
    "repo": "https://github.com/obra/superpowers",
    "version": "$sp_version",
    "last_sync": "$today"
  },
  "gstack": {
    "path": "~/.claude/skills/gstack",
    "version": "$gs_version",
    "last_sync": "$today"
  },
  "hybrid_version": "1.0.0"
}
EOF
    
    log_success "版本文件已更新"
}

# 主流程
main() {
    log_info "开始同步上游更新..."
    log_info "项目根目录: $PROJECT_ROOT"
    
    # 回滚模式
    if [[ "$ROLLBACK" == "true" ]]; then
        do_rollback
        exit 0
    fi
    
    # 备份模式
    if [[ "$BACKUP" == "true" ]]; then
        create_backup
    fi
    
    # 执行同步
    if [[ "$SYNC_SUPERPOWERS" == "true" ]]; then
        sync_superpowers
    fi
    
    if [[ "$SYNC_GSTACK" == "true" ]]; then
        sync_gstack
    fi
    
    # 更新版本文件
    if [[ "$DRY_RUN" == "false" && "$CHECK_ONLY" == "false" ]]; then
        update_version_file
    fi
    
    log_success "同步完成!"
    
    if [[ "$DRY_RUN" == "false" && "$CHECK_ONLY" == "false" ]]; then
        log_info "建议执行以下操作:"
        echo "  1. 检查变更: git status"
        echo "  2. 应用补丁: ./scripts/apply-patches.sh (如果有)"
        echo "  3. 提交更改: git add . && git commit -m 'chore: sync upstream updates'"
    fi
}

main "$@"
