#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# sync-upstream.sh - 同步上游 superpowers 和 gstack 更新
# 用法: ./scripts/sync-upstream.sh [选项]
#   --superpowers    仅同步 superpowers
#   --gstack         仅同步 gstack
#   --gstack-all      同步全部 gstack 技能（忽略过滤配置）
#   --check          检查更新但不执行
#   --dry-run        显示将要执行的操作
#   --backup         同步前备份
#   --rollback       回滚到上一个备份

# ---- 可配置路径（优先使用环境变量） ----
SUPERPOWERS_PATH="${SUPERPOWERS_PATH:-$HOME/.trae-cn/superpowers}"
GSTACK_PATH="${GSTACK_PATH:-$HOME/.claude/skills/gstack}"

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

# 清理函数
cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# 解析参数
SYNC_SUPERPOWERS=false
SYNC_GSTACK=false
GSTACK_ALL=false
CHECK_ONLY=false
DRY_RUN=false
BACKUP=false
ROLLBACK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --superpowers) SYNC_SUPERPOWERS=true; shift ;;
        --gstack) SYNC_GSTACK=true; shift ;;
        --gstack-all) SYNC_GSTACK=true; GSTACK_ALL=true; shift ;;
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

# 确认危险操作
confirm_destructive() {
    local msg="$1"
    echo -e "${YELLOW}[WARN]${NC} $msg"
    echo -n "确认执行? (y/N) "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) log_info "已取消"; return 1 ;;
    esac
}

# ---- 路径校验辅助 ----
check_path_safe() {
    local path="$1"
    local label="$2"
    if [[ -z "$path" ]]; then
        log_error "$label 路径为空"
        return 1
    fi
    if [[ ! -d "$path" ]]; then
        log_error "$label 目录不存在: $path"
        return 1
    fi
    # 防止路径指向根目录或 home
    if [[ "$path" == "/" || "$path" == "$HOME" ]]; then
        log_error "$label 路径指向系统关键目录，拒绝操作: $path"
        return 1
    fi
    return 0
}

# 创建备份
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"

    log_info "创建备份到 $backup_path..."
    mkdir -p "$backup_path"

    if [[ -d "$PROJECT_ROOT/skills/superpowers" ]]; then
        mkdir -p "$backup_path/skills"
        cp -r "$PROJECT_ROOT/skills/superpowers" "$backup_path/skills/"
    fi

    if [[ -d "$PROJECT_ROOT/skills/gstack" ]]; then
        mkdir -p "$backup_path/skills"
        cp -r "$PROJECT_ROOT/skills/gstack" "$backup_path/skills/"
    fi

    if [[ -d "$PROJECT_ROOT/skills/hybrid" ]]; then
        mkdir -p "$backup_path/skills"
        cp -r "$PROJECT_ROOT/skills/hybrid" "$backup_path/skills/"
    fi

    for dir in decision-layer context-layer execution-layer bridges governance; do
        if [[ -d "$PROJECT_ROOT/$dir" ]]; then
            cp -r "$PROJECT_ROOT/$dir" "$backup_path/"
        fi
    done

    if [[ -d "$PROJECT_ROOT/gstack-skills" ]]; then
        cp -r "$PROJECT_ROOT/gstack-skills" "$backup_path/"
    fi

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

    if [[ -d "$backup_path/skills/superpowers" ]]; then
        rm -rf "$PROJECT_ROOT/skills/superpowers"
        cp -r "$backup_path/skills/superpowers" "$PROJECT_ROOT/skills/"
    fi

    if [[ -d "$backup_path/skills/gstack" ]]; then
        rm -rf "$PROJECT_ROOT/skills/gstack"
        cp -r "$backup_path/skills/gstack" "$PROJECT_ROOT/skills/"
    fi

    if [[ -d "$backup_path/skills/hybrid" ]]; then
        rm -rf "$PROJECT_ROOT/skills/hybrid"
        cp -r "$backup_path/skills/hybrid" "$PROJECT_ROOT/skills/"
    fi

    for dir in decision-layer context-layer execution-layer bridges governance; do
        if [[ -d "$backup_path/$dir" ]]; then
            rm -rf "$PROJECT_ROOT/$dir"
            cp -r "$backup_path/$dir" "$PROJECT_ROOT/"
        fi
    done

    if [[ -d "$backup_path/gstack-skills" ]]; then
        rm -rf "$PROJECT_ROOT/gstack-skills"
        cp -r "$backup_path/gstack-skills" "$PROJECT_ROOT/"
    fi

    log_success "回滚完成"
}

# 同步 superpowers
sync_superpowers() {
    log_info "同步 superpowers..."

    if ! check_path_safe "$SUPERPOWERS_PATH" "Superpowers"; then
        log_info "可通过环境变量设置: SUPERPOWERS_PATH=/path/to/superpowers"
        return 1
    fi

    local SP_SKILLS_PATH="$SUPERPOWERS_PATH/skills/superpowers"

    if ! check_path_safe "$SP_SKILLS_PATH" "Superpowers 技能目录"; then
        log_info "上游结构异常，请检查 superpowers 安装"
        return 1
    fi

    # 加载过滤配置
    local sp_all=false
    load_sync_filter "superpowers" || sp_all=true

    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ "$sp_all" == "true" ]]; then
            log_info "[DRY-RUN] 将同步所有 superpowers 技能"
        else
            log_info "[DRY-RUN] 将仅同步 ${#ROUTED_SKILLS[@]} 个路由技能"
        fi
        return 0
    fi

    if [[ "$CHECK_ONLY" == "true" ]]; then
        log_info "检查 superpowers 更新..."
        local sp_count=$(ls -1 "$SP_SKILLS_PATH" 2>/dev/null | wc -l)
        log_info "上游 superpowers 技能数量: $sp_count"
        local local_count=$(ls -1 "$PROJECT_ROOT/skills/superpowers/" 2>/dev/null | wc -l)
        log_info "本地 superpowers 技能数量: $local_count"
        if [[ "$sp_all" == "false" ]]; then
            log_info "过滤模式: 仅同步 ${#ROUTED_SKILLS[@]} 个路由技能"
        fi
        return 0
    fi

    # 校验项目路径安全
    if ! check_path_safe "$PROJECT_ROOT/skills/superpowers" "项目 skills/superpowers"; then
        mkdir -p "$PROJECT_ROOT/skills/superpowers"
    fi

    # 仅同步被路由引用的技能
    log_info "检测并复制 superpowers 技能到 skills/superpowers/..."

    local synced=0
    local skipped=0
    cd "$SP_SKILLS_PATH"
    for skill in */; do
        skill=${skill%/}
        if [[ ! -f "$SP_SKILLS_PATH/$skill/SKILL.md" ]]; then
            continue
        fi

        if [[ "$sp_all" == "false" ]]; then
            if ! is_skill_routed "$skill"; then
                log_info "  跳过（未路由）: $skill"
                skipped=$((skipped + 1))
                continue
            fi
        fi

        log_info "  同步技能: $skill"
        rm -rf "$PROJECT_ROOT/skills/superpowers/$skill"
        cp -r "$SP_SKILLS_PATH/$skill" "$PROJECT_ROOT/skills/superpowers/"
        synced=$((synced + 1))
    done

    # 清理未在白名单中的本地技能
    if [[ "$sp_all" == "false" ]]; then
        local to_clean=()
        cd "$PROJECT_ROOT/skills/superpowers"
        for local_skill in */; do
            local_skill=${local_skill%/}
            if [[ -d "$local_skill" ]]; then
                if ! is_skill_routed "$local_skill"; then
                    to_clean+=("$local_skill")
                fi
            fi
        done

        if [[ ${#to_clean[@]} -gt 0 ]]; then
            log_info "以下本地技能不在路由表中，将被删除:"
            for s in "${to_clean[@]}"; do
                echo "  - $s"
            done
            if ! confirm_destructive "删除 ${#to_clean[@]} 个未引用的技能?"; then
                log_info "跳过清理"
            else
                local cleaned=0
                for s in "${to_clean[@]}"; do
                    log_info "  删除: $s"
                    rm -rf "$s"
                    cleaned=$((cleaned + 1))
                done
                log_info "已清理 $cleaned 个未引用的技能"
            fi
        fi
    fi

    # 同步 agents
    if [[ -d "$SUPERPOWERS_PATH/agents" ]]; then
        cp -r "$SUPERPOWERS_PATH/agents" "$PROJECT_ROOT/"
    fi

    # 同步 commands
    if [[ -d "$SUPERPOWERS_PATH/commands" ]]; then
        cp -r "$SUPERPOWERS_PATH/commands" "$PROJECT_ROOT/"
    fi

    # 同步 hooks
    if [[ -d "$SUPERPOWERS_PATH/hooks" ]]; then
        cp -r "$SUPERPOWERS_PATH/hooks" "$PROJECT_ROOT/"
    fi

    # 同步配置文件
    if [[ -f "$SUPERPOWERS_PATH/CLAUDE.md" ]]; then
        cp "$SUPERPOWERS_PATH/CLAUDE.md" "$PROJECT_ROOT/"
    fi

    log_success "Superpowers 同步完成 (同步 $synced 个技能，跳过 $skipped 个未路由技能)"
}

# 读取同步过滤配置
load_sync_filter() {
    local section="$1"
    local filter_file="$PROJECT_ROOT/.sync-filter.json"

    if [[ ! -f "$filter_file" ]]; then
        log_warn "过滤配置文件不存在: $filter_file"
        log_info "将同步所有技能"
        return 1
    fi

    # 优先使用 jq（如果可用）
    if command -v jq &>/dev/null; then
        local mode
        mode=$(jq -r ".\"$section\".mode // \"all\"" "$filter_file" 2>/dev/null) || mode="all"
        if [[ "$mode" != "routed" ]]; then
            log_info "[$section] 过滤模式: all（同步所有技能）"
            return 1
        fi
        log_info "[$section] 过滤模式: routed（仅同步路由表引用的技能）"
        ROUTED_SKILLS=()
        while IFS= read -r skill; do
            ROUTED_SKILLS+=("$skill")
        done < <(jq -r ".\"$section\".routed_skills[] // []" "$filter_file" 2>/dev/null)
        log_info "[$section] 白名单技能数: ${#ROUTED_SKILLS[@]}"
        return 0
    fi

    # 无 jq 时使用 grep 回退方案
    local flat=$(tr -d '\n' < "$filter_file")
    local mode=$(echo "$flat" | grep -o '"'"$section"'"\s*:\s*{[^}]*"mode"\s*:\s*"[^"]*"' | grep -o '"mode"\s*:\s*"[^"]*"' | cut -d'"' -f4)

    if [[ "$mode" != "routed" ]]; then
        log_info "[$section] 过滤模式: all（同步所有技能）"
        return 1
    fi

    log_info "[$section] 过滤模式: routed（仅同步路由表引用的技能）"

    ROUTED_SKILLS=()
    local in_section=false
    local in_list=false
    while IFS= read -r line; do
        if echo "$line" | grep -q '"'"$section"'"'; then
            in_section=true
            continue
        fi
        if [[ "$in_section" == "true" ]]; then
            if echo "$line" | grep -q '"routed_skills"'; then
                in_list=true
                continue
            fi
            if [[ "$in_list" == "true" ]]; then
                local skill=$(echo "$line" | grep -o '"[^"]*"' | head -1 | tr -d '"')
                if [[ -n "$skill" && "$skill" != "routed_skills" ]]; then
                    ROUTED_SKILLS+=("$skill")
                fi
                if echo "$line" | grep -q ']'; then
                    break
                fi
            fi
        fi
    done < "$filter_file"

    log_info "[$section] 白名单技能数: ${#ROUTED_SKILLS[@]}"
    return 0
}

# 检查技能是否在白名单中
is_skill_routed() {
    local skill_name="$1"
    for routed in "${ROUTED_SKILLS[@]}"; do
        if [[ "$routed" == "$skill_name" ]]; then
            return 0
        fi
    done
    return 1
}

# 同步 gstack
sync_gstack() {
    log_info "同步 gstack..."

    if ! check_path_safe "$GSTACK_PATH" "GStack"; then
        log_info "可通过环境变量设置: GSTACK_PATH=/path/to/gstack"
        return 1
    fi

    # 加载过滤配置
    load_sync_filter "gstack"

    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ "$GSTACK_ALL" == "true" ]]; then
            log_info "[DRY-RUN] 将同步所有 gstack 技能"
        else
            log_info "[DRY-RUN] 将仅同步 ${#ROUTED_SKILLS[@]} 个路由技能"
        fi
        return 0
    fi

    if [[ "$CHECK_ONLY" == "true" ]]; then
        log_info "检查 gstack 更新..."
        if [[ -f "$GSTACK_PATH/VERSION" ]]; then
            local gstack_version=$(cat "$GSTACK_PATH/VERSION")
            log_info "当前 gstack 版本: $gstack_version"
        fi
        local gs_count=$(find "$GSTACK_PATH" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l)
        log_info "上游 gstack 技能数量: $gs_count"
        local local_count=$(find "$PROJECT_ROOT/skills/gstack" -name "SKILL.md" 2>/dev/null | wc -l)
        log_info "本地 gstack 技能数量: $local_count"
        if [[ "$GSTACK_ALL" == "false" ]]; then
            log_info "过滤模式: 仅同步 ${#ROUTED_SKILLS[@]} 个路由技能"
        fi
        return 0
    fi

    if ! check_path_safe "$PROJECT_ROOT/skills/gstack" "项目 skills/gstack"; then
        mkdir -p "$PROJECT_ROOT/skills/gstack"
    fi

    # 自动检测所有包含 SKILL.md 的技能目录
    log_info "检测并复制 gstack 技能到 skills/gstack/..."

    cd "$GSTACK_PATH"
    local synced=0
    local skipped=0
    for skill in */; do
        skill=${skill%/}
        if [[ ! -f "$GSTACK_PATH/$skill/SKILL.md" ]]; then
            continue
        fi

        if [[ "$GSTACK_ALL" == "false" ]]; then
            if ! is_skill_routed "$skill"; then
                log_info "  跳过（未路由）: $skill"
                skipped=$((skipped + 1))
                continue
            fi
        fi

        log_info "  同步技能: $skill"
        rm -rf "$PROJECT_ROOT/skills/gstack/$skill"
        cp -r "$GSTACK_PATH/$skill" "$PROJECT_ROOT/skills/gstack/"
        synced=$((synced + 1))
    done

    # 清理未在白名单中的本地技能
    if [[ "$GSTACK_ALL" == "false" ]]; then
        local to_clean=()
        cd "$PROJECT_ROOT/skills/gstack"
        for local_skill in */; do
            local_skill=${local_skill%/}
            if [[ -d "$local_skill" ]]; then
                if ! is_skill_routed "$local_skill"; then
                    to_clean+=("$local_skill")
                fi
            fi
        done

        if [[ ${#to_clean[@]} -gt 0 ]]; then
            log_info "以下本地技能不在路由表中，将被删除:"
            for s in "${to_clean[@]}"; do
                echo "  - $s"
            done
            if ! confirm_destructive "删除 ${#to_clean[@]} 个未引用的技能?"; then
                log_info "跳过清理"
            else
                local cleaned=0
                for s in "${to_clean[@]}"; do
                    log_info "  删除: $s"
                    rm -rf "$s"
                    cleaned=$((cleaned + 1))
                done
                log_info "已清理 $cleaned 个未引用的技能"
            fi
        fi
    fi

    # 特殊处理：browse 重命名为 gstack-browse
    if [[ -d "$PROJECT_ROOT/skills/gstack/browse" ]]; then
        log_info "  重命名: browse → gstack-browse"
        rm -rf "$PROJECT_ROOT/skills/gstack/gstack-browse"
        mv "$PROJECT_ROOT/skills/gstack/browse" "$PROJECT_ROOT/skills/gstack/gstack-browse"
    fi

    # 同步工具脚本
    log_info "复制 gstack 工具脚本..."
    mkdir -p "$PROJECT_ROOT/gstack-skills"
    rm -rf "$PROJECT_ROOT/gstack-skills/bin"
    cp -r "$GSTACK_PATH/bin" "$PROJECT_ROOT/gstack-skills/"
    if [[ -f "$GSTACK_PATH/setup" ]]; then
        cp "$GSTACK_PATH/setup" "$PROJECT_ROOT/gstack-skills/"
    fi
    if [[ -f "$GSTACK_PATH/VERSION" ]]; then
        cp "$GSTACK_PATH/VERSION" "$PROJECT_ROOT/gstack-skills/"
    fi
    if [[ -f "$GSTACK_PATH/package.json" ]]; then
        cp "$GSTACK_PATH/package.json" "$PROJECT_ROOT/gstack-skills/"
    fi

    local synced_count=$(find "$PROJECT_ROOT/skills/gstack" -name "SKILL.md" 2>/dev/null | wc -l)
    if [[ "$GSTACK_ALL" == "true" ]]; then
        log_success "GStack 同步完成 (同步 $synced_count 个技能到 skills/gstack/)"
    else
        log_success "GStack 同步完成 (同步 $synced 个技能，跳过 $skipped 个未路由技能)"
    fi
}

# 更新版本文件
update_version_file() {
    local today=$(date +%Y-%m-%d)

    log_info "更新版本追踪文件..."

    local sp_version="unknown"
    local gs_version="unknown"

    if [[ -f "$PROJECT_ROOT/skills/superpowers/brainstorming/SKILL.md" ]]; then
        sp_version=$(grep -m1 "^# " "$PROJECT_ROOT/skills/superpowers/brainstorming/SKILL.md" | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' || echo "synced")
    fi

    if [[ -f "$PROJECT_ROOT/gstack-skills/VERSION" ]]; then
        gs_version=$(cat "$PROJECT_ROOT/gstack-skills/VERSION")
    fi

    local sp_count=$(ls -1 "$PROJECT_ROOT/skills/superpowers/" 2>/dev/null | wc -l)
    local gs_count=$(find "$PROJECT_ROOT/skills/gstack" -name "SKILL.md" 2>/dev/null | wc -l)
    local hybrid_count=$(find "$PROJECT_ROOT/skills/hybrid" -name "SKILL.md" 2>/dev/null | wc -l)

    cat > "$VERSION_FILE" << EOF
{
  "superpowers": {
    "repo": "https://github.com/obra/superpowers",
    "version": "$sp_version",
    "last_sync": "$today",
    "skill_count": $sp_count,
    "path": "skills/superpowers/"
  },
  "gstack": {
    "path": "~/.claude/skills/gstack",
    "version": "$gs_version",
    "last_sync": "$today",
    "skill_count": $gs_count,
    "skill_path": "skills/gstack/"
  },
  "hybrid": {
    "description": "Superpowers + GStack 混合流程",
    "skill_count": $hybrid_count,
    "path": "skills/hybrid/"
  },
  "custom": {
    "description": "自定义扩展技能",
    "path": "skills/custom/"
  },
  "last_sync": "$today"
}
EOF

    log_success "版本追踪文件已更新: $VERSION_FILE"
}

# 显示目录结构
show_structure() {
    local sp_count=$(ls -1 "$PROJECT_ROOT/skills/superpowers/" 2>/dev/null | wc -l)
    local gs_count=$(find "$PROJECT_ROOT/skills/gstack" -name "SKILL.md" 2>/dev/null | wc -l)
    local hybrid_count=$(find "$PROJECT_ROOT/skills/hybrid" -name "SKILL.md" 2>/dev/null | wc -l)

    log_info "当前技能目录结构:"
    echo ""
    echo "skills/"
    echo "├── superpowers/     # Superpowers 核心技能 ($sp_count 个)"
    echo "├── gstack/          # GStack 工程技能 ($gs_count 个)"
    echo "├── hybrid/          # 混合流程技能 ($hybrid_count 个)"
    echo "└── custom/          # 自定义扩展"
    echo ""
    echo "三层架构目录:"
    echo "├── decision-layer/  # 决策层 (多角色审议)"
    echo "├── context-layer/   # 上下文层 (契约、注水)"
    echo "├── execution-layer/ # 执行层 (受约束的实现)"
    echo "├── bridges/         # 桥接层"
    echo "└── governance/      # 治理层 (决策冻结)"
    echo ""
}

# 主函数
main() {
    log_info "开始同步上游更新..."
    log_info "项目根目录: $PROJECT_ROOT"

    if [[ "$ROLLBACK" == "true" ]]; then
        do_rollback
        exit 0
    fi

    if [[ "$BACKUP" == "true" ]]; then
        create_backup
    fi

    if [[ "$SYNC_SUPERPOWERS" == "true" ]]; then
        sync_superpowers || log_warn "Superpowers 同步失败"
    fi

    if [[ "$SYNC_GSTACK" == "true" ]]; then
        sync_gstack || log_warn "GStack 同步失败"
    fi

    if [[ "$CHECK_ONLY" == "false" && "$DRY_RUN" == "false" ]]; then
        update_version_file
    fi

    if [[ "$CHECK_ONLY" == "false" && "$DRY_RUN" == "false" ]]; then
        show_structure
    fi

    log_success "同步完成!"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "这是 dry-run 模式，没有实际执行同步"
        log_info "去掉 --dry-run 参数以执行实际同步"
    fi
}

# 运行主函数
main
