#!/usr/bin/env bash
#
# install.sh - gstack-superpowers-hybrid-skill 安装脚本
#
# 用法: ./scripts/install.sh [命令] [选项]
#
# 命令:
#   install     安装到目标目录（默认）
#   uninstall   卸载
#   rollback    回滚到上一个版本
#   validate    验证安装
#   status      显示安装状态
#   backups     列出所有备份
#
# 选项:
#   --target DIR        目标目录（默认: ~/.trae-cn/superpowers）
#   --no-backup         安装时不创建备份
#   --dry-run           预览模式，不执行实际操作
#   --force             强制安装，覆盖现有文件
#   --verbose           详细输出
#   -y, --yes           跳过确认提示
#   -h, --help          显示帮助信息
#
# 示例:
#   ./scripts/install.sh install                    # 安装到默认位置
#   ./scripts/install.sh install --target ~/.claude/skills/gstack-hybrid
#   ./scripts/install.sh uninstall                  # 卸载
#   ./scripts/install.sh rollback                   # 回滚到上一个版本
#   ./scripts/install.sh validate                   # 验证安装
#   ./scripts/install.sh status                     # 显示状态
#

set -euo pipefail

# =============================================================================
# 配置
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION="4.1.0"

# 默认目标目录
DEFAULT_TARGET="$HOME/.trae-cn/superpowers"
TARGET_DIR="$DEFAULT_TARGET"
BACKUP_BASE="$HOME/.trae-cn/superpowers-backups"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 选项
DRY_RUN=false
NO_BACKUP=false
FORCE=false
VERBOSE=false
YES=false
COMMAND="install"

# 统计
COPIED_FILES=0
COPIED_DIRS=0
SKIPPED_FILES=0

# =============================================================================
# 工具函数
# =============================================================================

log_info()     { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success()  { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()     { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()    { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug()    { [[ "$VERBOSE" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $1" || true; }
log_step()     { echo -e "${GREEN}[STEP]${NC} $1"; }

die() {
    log_error "$1"
    exit "${2:-1}"
}

confirm() {
    [[ "$YES" == "true" ]] && return 0
    read -rp "$1 [y/N] " ans
    [[ "$ans" == "y" || "$ans" == "Y" ]]
}

usage() {
    sed -n '/^# 用法:/,/^# 示例:/s/^# \{0,1\}//p' "$0"
    exit "${1:-0}"
}

# =============================================================================
# 前置检查
# =============================================================================

check_prerequisites() {
    log_step "检查前置条件..."

    local errors=0

    if [[ ! -d "$PROJECT_ROOT" ]]; then
        log_error "项目目录不存在: $PROJECT_ROOT"
        errors=$((errors + 1))
    fi

    if ! command -v bash >/dev/null 2>&1; then
        log_error "需要 bash shell"
        errors=$((errors + 1))
    fi

    if ! command -v cp >/dev/null 2>&1; then
        log_error "需要 cp 命令"
        errors=$((errors + 1))
    fi

    if ! command -v mkdir >/dev/null 2>&1; then
        log_error "需要 mkdir 命令"
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        die "前置检查失败，发现 $errors 个错误"
    fi

    log_success "前置检查通过"
}

check_source_integrity() {
    log_step "检查源目录完整性..."

    local required_dirs=(
        "skills"
        "decision-layer"
        "context-layer"
        "execution-layer"
        "bridges"
        "governance"
    )

    local required_files=(
        "skills/hybrid/gs-hybrid-v3/SKILL.md"
        "CLAUDE.md"
        "project-config.yml"
    )

    local errors=0

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$PROJECT_ROOT/$dir" ]]; then
            log_error "缺少必需目录: $dir"
            errors=$((errors + 1))
        else
            log_debug "✓ 目录存在: $dir"
        fi
    done

    for file in "${required_files[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            log_error "缺少必需文件: $file"
            errors=$((errors + 1))
        else
            log_debug "✓ 文件存在: $file"
        fi
    done

    if [[ $errors -gt 0 ]]; then
        die "源目录完整性检查失败，发现 $errors 个错误"
    fi

    log_success "源目录完整性检查通过"
}

# =============================================================================
# 备份管理
# =============================================================================

create_backup() {
    if [[ "$NO_BACKUP" == "true" ]]; then
        log_info "跳过备份（--no-backup）"
        return 0
    fi

    if [[ ! -d "$TARGET_DIR" ]]; then
        log_info "目标目录不存在，无需备份"
        return 0
    fi

    log_step "创建备份..."

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_BASE/backup_$timestamp"

    mkdir -p "$BACKUP_BASE"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 将创建备份: $backup_dir"
        return 0
    fi

    log_info "备份目录: $backup_dir"
    cp -r "$TARGET_DIR" "$backup_dir"

    local latest_link="$BACKUP_BASE/latest"
    rm -f "$latest_link"
    ln -s "$backup_dir" "$latest_link"

    log_success "备份完成: $backup_dir"
}

list_backups() {
    echo ""
    echo "可用备份列表:"
    echo "=============="
    echo ""

    if [[ ! -d "$BACKUP_BASE" ]]; then
        echo "  没有找到备份目录"
        return 0
    fi

    local count=0
    for backup in "$BACKUP_BASE"/backup_*; do
        if [[ -d "$backup" ]]; then
            count=$((count + 1))
            local name
            name=$(basename "$backup")
            local size
            size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            local date
            date=$(stat -f "%Sm" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null)
            printf "  %2d. %-30s %8s  %s\n" "$count" "$name" "$size" "$date"
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo "  没有找到备份"
    else
        echo ""
        echo "共 $count 个备份"
    fi

    if [[ -L "$BACKUP_BASE/latest" ]]; then
        echo ""
        echo "最新备份: $(readlink "$BACKUP_BASE/latest")"
    fi
}

rollback() {
    log_step "回滚到上一个版本..."

    if [[ ! -d "$BACKUP_BASE" ]]; then
        die "没有找到备份目录: $BACKUP_BASE"
    fi

    local latest_backup="$BACKUP_BASE/latest"

    if [[ ! -L "$latest_backup" ]]; then
        die "没有找到最新备份链接"
    fi

    local backup_dir
    backup_dir=$(readlink "$latest_backup")

    if [[ ! -d "$backup_dir" ]]; then
        die "备份目录不存在: $backup_dir"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 将从 $backup_dir 回滚"
        return 0
    fi

    confirm "确定要从 $backup_dir 回滚吗？" || die "用户取消"

    log_info "删除当前安装..."
    rm -rf "$TARGET_DIR"

    log_info "恢复备份..."
    cp -r "$backup_dir" "$TARGET_DIR"

    log_success "回滚完成"
}

# =============================================================================
# 安装过程
# =============================================================================

copy_files() {
    log_step "复制文件..."

    local items=(
        "skills"
        "decision-layer"
        "context-layer"
        "execution-layer"
        "bridges"
        "governance"
        "gstack-skills"
        "docs"
        "specs"
        "commands"
        "hooks"
        "agents"
        "overrides"
        "schema"
        ".sync-filter.json"
        "CLAUDE.md"
        "project-config.yml"
        "README.md"
        "INSTALL.md"
        "LICENSE"
    )

    COPIED_FILES=0
    COPIED_DIRS=0
    SKIPPED_FILES=0

    for item in "${items[@]}"; do
        local src="$PROJECT_ROOT/$item"
        local dest="$TARGET_DIR/$item"

        if [[ ! -e "$src" ]]; then
            log_debug "跳过不存在的项目: $item"
            SKIPPED_FILES=$((SKIPPED_FILES + 1))
            continue
        fi

        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY-RUN] 将复制: $item"
            continue
        fi

        log_debug "复制: $item"

        if [[ -d "$src" ]]; then
            rm -rf "$dest"
            cp -r "$src" "$dest"
            COPIED_DIRS=$((COPIED_DIRS + 1))
        elif [[ -f "$src" ]]; then
            cp "$src" "$dest"
            COPIED_FILES=$((COPIED_FILES + 1))
        fi
    done

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 预览完成"
    else
        log_success "文件复制完成 (目录: $COPIED_DIRS, 文件: $COPIED_FILES, 跳过: $SKIPPED_FILES)"
    fi
}

set_permissions() {
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi

    log_step "设置权限..."

    chmod +x "$TARGET_DIR/scripts/"*.sh 2>/dev/null || true
    chmod +x "$TARGET_DIR/gstack-skills/bin/"* 2>/dev/null || true

    log_success "权限设置完成"
}

# =============================================================================
# 验证
# =============================================================================

validate_installation() {
    log_step "验证安装..."

    local errors=0

    local required_dirs=(
        "skills"
        "decision-layer"
        "context-layer"
        "execution-layer"
        "bridges"
        "governance"
    )

    local required_files=(
        "skills/hybrid/gs-hybrid-v3/SKILL.md"
        "CLAUDE.md"
        "project-config.yml"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$TARGET_DIR/$dir" ]]; then
            log_error "缺少目录: $dir"
            errors=$((errors + 1))
        else
            log_debug "✓ 目录存在: $dir"
        fi
    done

    for file in "${required_files[@]}"; do
        if [[ ! -f "$TARGET_DIR/$file" ]]; then
            log_error "缺少文件: $file"
            errors=$((errors + 1))
        else
            log_debug "✓ 文件存在: $file"
        fi
    done

    if [[ $errors -gt 0 ]]; then
        log_error "验证失败，发现 $errors 个错误"
        return 1
    fi

    log_success "验证通过"
    return 0
}

# =============================================================================
# 状态显示
# =============================================================================

show_status() {
    echo ""
    echo "=========================================="
    echo "  gstack-superpowers-hybrid-skill 状态"
    echo "=========================================="
    echo ""
    echo "版本: $VERSION"
    echo "源目录: $PROJECT_ROOT"
    echo "目标目录: $TARGET_DIR"
    echo ""

    if [[ -d "$TARGET_DIR" ]]; then
        echo "安装状态: ✓ 已安装"
        echo ""

        local sp_count
        sp_count=$(find "$TARGET_DIR/skills/superpowers" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        local gs_count
        gs_count=$(find "$TARGET_DIR/skills/gstack" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        local hybrid_count
        hybrid_count=$(find "$TARGET_DIR/skills/hybrid" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

        echo "技能统计:"
        echo "  - superpowers: $sp_count 个技能"
        echo "  - gstack: $gs_count 个技能"
        echo "  - hybrid: $hybrid_count 个技能"
        echo ""

        if [[ -f "$TARGET_DIR/project-config.yml" ]]; then
            echo "配置文件: ✓ 存在"
        else
            echo "配置文件: ✗ 缺失"
        fi

        if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
            echo "CLAUDE.md: ✓ 存在"
        else
            echo "CLAUDE.md: ✗ 缺失"
        fi

        echo ""

        local install_time
        install_time=$(stat -f "%Sm" "$TARGET_DIR" 2>/dev/null || stat -c "%y" "$TARGET_DIR" 2>/dev/null)
        echo "安装时间: $install_time"
    else
        echo "安装状态: ✗ 未安装"
    fi

    echo ""

    if [[ -d "$BACKUP_BASE" ]]; then
        local backup_count
        backup_count=$(find "$BACKUP_BASE" -maxdepth 1 -name "backup_*" -type d 2>/dev/null | wc -l | tr -d ' ')
        echo "备份数量: $backup_count"
    else
        echo "备份数量: 0"
    fi

    echo ""
}

show_summary() {
    echo ""
    echo "=========================================="
    echo "  安装摘要"
    echo "=========================================="
    echo ""
    echo "版本: $VERSION"
    echo "源目录: $PROJECT_ROOT"
    echo "目标目录: $TARGET_DIR"
    echo ""
    echo "复制统计:"
    echo "  - 目录: $COPIED_DIRS"
    echo "  - 文件: $COPIED_FILES"
    echo "  - 跳过: $SKIPPED_FILES"
    echo ""

    if [[ -d "$BACKUP_BASE" ]] && [[ "$NO_BACKUP" != "true" ]]; then
        local latest_backup
        latest_backup=$(readlink "$BACKUP_BASE/latest" 2>/dev/null || echo "无")
        echo "备份位置: $latest_backup"
    fi

    echo ""
    echo "下一步:"
    echo "  1. 重启 Trae 或 Claude Code"
    echo "  2. 使用 'gs-hybrid-v3' 命令测试"
    echo "  3. 查看 README.md 了解更多功能"
    echo ""
}

# =============================================================================
# 主要命令
# =============================================================================

do_install() {
    log_info "开始安装 gstack-superpowers-hybrid-skill v$VERSION"
    echo ""

    check_prerequisites
    check_source_integrity

    if [[ -d "$TARGET_DIR" ]] && [[ "$FORCE" != "true" ]]; then
        log_warn "目标目录已存在: $TARGET_DIR"
        confirm "是否继续安装（将创建备份）？" || die "用户取消"
    fi

    create_backup

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 将创建目录: $TARGET_DIR"
    else
        mkdir -p "$TARGET_DIR"
    fi

    copy_files
    set_permissions

    if [[ "$DRY_RUN" != "true" ]]; then
        validate_installation || die "安装验证失败"
        show_summary
    fi

    log_success "安装完成！"
}

do_uninstall() {
    log_info "开始卸载..."
    echo ""

    if [[ ! -d "$TARGET_DIR" ]]; then
        log_warn "目标目录不存在: $TARGET_DIR"
        return 0
    fi

    confirm "确定要卸载 $TARGET_DIR 吗？" || die "用户取消"

    create_backup

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 将删除: $TARGET_DIR"
    else
        rm -rf "$TARGET_DIR"
        log_success "卸载完成"
    fi
}

do_validate() {
    log_info "验证安装..."
    echo ""

    if [[ ! -d "$TARGET_DIR" ]]; then
        die "目标目录不存在: $TARGET_DIR"
    fi

    validate_installation
}

# =============================================================================
# 参数解析
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            install|uninstall|rollback|validate|status|backups)
                COMMAND="$1"
                shift
                ;;
            --target)
                TARGET_DIR="$2"
                shift 2
                ;;
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --yes|-y)
                YES=true
                shift
                ;;
            --help|-h)
                usage 0
                ;;
            *)
                log_error "未知参数: $1"
                usage 1
                ;;
        esac
    done
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    parse_args "$@"

    echo ""
    echo "=========================================="
    echo "  gstack-superpowers-hybrid-skill"
    echo "  Version $VERSION"
    echo "=========================================="
    echo ""

    case "$COMMAND" in
        install)
            do_install
            ;;
        uninstall)
            do_uninstall
            ;;
        rollback)
            rollback
            ;;
        validate)
            do_validate
            ;;
        status)
            show_status
            ;;
        backups)
            list_backups
            ;;
        *)
            log_error "未知命令: $COMMAND"
            usage 1
            ;;
    esac
}

main "$@"
