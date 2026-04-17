#!/bin/sh
# Rust 1.89.0 HarmonyOS 一键安装脚本
# 用法: /bin/sh -c "$(curl -fsSL https://gitcode.com/OpenHarmonyPCDeveloper/ohos-rust-release/releases/download/v1.89.0/install.sh)"

# ── 配置 ──────────────────────────────────────────────
RUST_VERSION="1.89.0"
ARCH="aarch64-unknown-linux-ohos"
PACKAGE_NAME="rust-${RUST_VERSION}-${ARCH}"
INSTALL_DIR="$HOME/usr/${PACKAGE_NAME}"
RELEASE_TAG="v1.89.0"
DOWNLOAD_URL="https://gitcode.com/OpenHarmonyPCDeveloper/ohos-rust-release/releases/download/${RELEASE_TAG}/${PACKAGE_NAME}.tar.gz"
MARKER="# >>> Rust ${RUST_VERSION} HarmonyOS >>>"
MARKER_END="# <<< Rust ${RUST_VERSION} HarmonyOS <<<"

CACERT="/etc/ssl/certs/cacert.pem"

# ── 颜色 ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { printf "${CYAN}==> ${NC}%s\n" "$1"; }
warn()  { printf "${YELLOW}==> ${NC}%s\n" "$1"; }
ok()    { printf "${GREEN}==> ${NC}%s\n" "$1"; }
fail()  { printf "${RED}==> ${NC}%s\n" "$1"; }

# ── 前置检查 ──────────────────────────────────────────
check_prereqs() {
    if ! command -v curl >/dev/null 2>&1; then
        fail "需要 curl，请先安装"
        exit 1
    fi

    if [ "$(uname -m)" != "aarch64" ]; then
        fail "本包仅支持 aarch64 架构，当前: $(uname -m)"
        exit 1
    fi

    if ! command -v clang >/dev/null 2>&1; then
        warn "未检测到 clang，可通过应用市场安装 DevBox"
    fi

    # 检查磁盘空间（需要约 700MB）
    available_kb=$(df -k "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
    if [ -n "$available_kb" ] && [ "$available_kb" -lt 716800 ]; then
        fail "磁盘空间不足（需要约 700MB，可用: $((available_kb/1024))MB）"
        exit 1
    fi
}

# ── 下载 ──────────────────────────────────────────────
download() {
    tarball="$HOME/tmp/${PACKAGE_NAME}.tar.gz"
    mkdir -p "$HOME/tmp"

    if [ -f "$tarball" ]; then
        warn "发现已有安装包: $tarball"
        printf "是否重新下载？[y/N] "
        read -r answer
        case "$answer" in
            y*|Y*) rm -f "$tarball" ;;
            *) ok "使用已有安装包" ; return ;;
        esac
    fi

    info "下载 Rust ${RUST_VERSION} HarmonyOS 版本..."
    if curl -fsSL --cacert "$CACERT" --retry 3 --connect-timeout 30 -o "$tarball" "$DOWNLOAD_URL"; then
        ok "下载完成"
    else
        warn "首次下载失败，尝试跳过证书验证..."
        if curl -fsSL -k --retry 3 --connect-timeout 30 -o "$tarball" "$DOWNLOAD_URL"; then
            ok "下载完成"
        else
            rm -f "$tarball"
            fail "下载失败，请检查网络或手动下载:"
            fail "  $DOWNLOAD_URL"
            exit 1
        fi
    fi
}

# ── 安装 ──────────────────────────────────────────────
install() {
    if [ -d "$INSTALL_DIR" ]; then
        warn "检测到已有安装: $INSTALL_DIR"
        printf "是否覆盖？[y/N] "
        read -r answer
        case "$answer" in
            y*|Y*) ;;
            *) ok "保留现有安装，仅更新 shell 配置"; return ;;
        esac
        rm -rf "$INSTALL_DIR"
    fi

    info "解压到 $INSTALL_DIR ..."
    mkdir -p "$(dirname "$INSTALL_DIR")"
    tar -xzf "$HOME/tmp/${PACKAGE_NAME}.tar.gz" -C "$(dirname "$INSTALL_DIR")"

    info "修复执行权限（HarmonyOS 签名机制要求）..."
    find "$INSTALL_DIR" -type f -name '*.so*' -exec chmod +x {} \; 2>/dev/null || true
    chmod +x "$INSTALL_DIR/bin/"* 2>/dev/null || true

    # 首次运行确认（ELF 签名机制）
    info "首次运行确认..."
    "$INSTALL_DIR/bin/rustc" --version >/dev/null 2>&1 || true

    ok "安装完成"
}

# ── 配置 Shell ─────────────────────────────────────────
add_shell_config() {
    config_file="$1"

    if [ -f "$config_file" ] && grep -qF "$MARKER" "$config_file"; then
        sed "/$MARKER/,/$MARKER_END/d" "$config_file" > "${config_file}.tmp"
        mv "${config_file}.tmp" "$config_file"
    fi

    cat >> "$config_file" << SHELL_EOF

${MARKER}
# Rust ${RUST_VERSION} HarmonyOS 环境变量
export PATH="$INSTALL_DIR/bin:\$PATH"
export RUST_HOME="$INSTALL_DIR"
export CARGO_HOME="$HOME/.cargo"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_LINKER=clang
export TMPDIR="\${TMPDIR:-\$HOME/tmp}"
export SSL_CERT_FILE="\${SSL_CERT_FILE:-/etc/ssl/certs/cacert.pem}"
export OHOS_BINARY_SIGN_TOOL="$INSTALL_DIR/tool/binary-sign-tool"
export CC="clang"
export CXX="clang++"
${MARKER_END}
SHELL_EOF
}

configure_shell() {
    configured=""

    if [ -f "$HOME/.bashrc" ]; then
        add_shell_config "$HOME/.bashrc"
        configured="$configured ~/.bashrc"
    fi

    if [ -f "$HOME/.zshrc" ]; then
        add_shell_config "$HOME/.zshrc"
        configured="$configured ~/.zshrc"
    fi

    if [ -z "$configured" ]; then
        touch "$HOME/.zshrc"
        add_shell_config "$HOME/.zshrc"
        configured="~/.zshrc (新建)"
    fi

    ok "已更新: $configured"
}

# ── 清理 ──────────────────────────────────────────────
cleanup() {
    rm -f "$HOME/tmp/${PACKAGE_NAME}.tar.gz"
}

# ── 完成 ──────────────────────────────────────────────
print_success() {
    echo ""
    printf "${GREEN}${BOLD}  ✅ Rust ${RUST_VERSION} HarmonyOS 安装成功！${NC}\n"
    echo ""
    printf "  安装位置:  ${CYAN}${INSTALL_DIR}${NC}\n"
    echo ""
    printf "  ${BOLD}下一步：${NC}\n"
    echo ""
    printf "    1. 使配置生效：\n"
    echo ""
    printf "       ${YELLOW}source ~/.zshrc${NC}\n"
    printf "       ${YELLOW}source ~/.bashrc${NC}\n"
    echo ""
    printf "    2. 验证安装：\n"
    echo ""
    printf "       ${YELLOW}rustc --version${NC}\n"
    printf "       ${YELLOW}cargo --version${NC}\n"
    echo ""
    printf "    3. 创建新项目：\n"
    echo ""
    printf "       ${YELLOW}cargo new hello_world${NC}\n"
    printf "       ${YELLOW}cd hello_world${NC}\n"
    printf "       ${YELLOW}cargo run${NC}\n"
    echo ""
    printf "    4. 如需卸载：\n"
    echo ""
    printf "       ${YELLOW}rm -rf ${INSTALL_DIR}${NC}\n"
    printf "       从 ~/.bashrc 和 ~/.zshrc 中删除 ${MARKER} 标记的行\n"
    echo ""
}

# ── 主流程 ────────────────────────────────────────────
main() {
    echo ""
    printf "${CYAN}${BOLD}  🦀 Rust ${RUST_VERSION} HarmonyOS 安装程序${NC}\n"
    echo "  ----------------------------------------"
    echo ""

    check_prereqs
    download
    install
    configure_shell
    cleanup
    print_success
}

main "$@"
