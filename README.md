# Rust 1.95.0 — HarmonyOS 移植版

面向 HarmonyOS PC（aarch64）的 Rust 1.95.0 预编译包，基于 musl libc + Clang 工具链构建。

## 版本信息

| 项目 | 值 |
|------|------|
| Rust 版本 | 1.95.0 |
| 构建系统 | rustbuild (x.py dist) |
| 适配状态 | ✅ 核心功能可用 |
| 内置工具 | rustc, cargo, rustdoc, rustfmt, clippy, rust-analyzer |
| 目标平台 | HarmonyOS aarch64, musl libc, Clang 15.0.4 |
| 内核版本 | HongMeng Kernel 1.11.0 |
| 目标三元组 | `aarch64-unknown-linux-ohos` |

## 功能概览

### 功能特性

- **编译器**：rustc 编译、类型检查、宏展开、泛型、trait、生命周期、async/await、模式匹配等
- **包管理器**：cargo new/build/run/test/bench/doc/clean/update 等
- **格式化**：rustfmt 代码格式化
- **Lint**：clippy 静态分析
- **文档**：rustdoc 文档生成
- **代码分析**：rust-analyzer 语言服务器
- **标准库**：std 核心功能（collections, io, net, fs, sync, async）

### 补丁说明

| 补丁 | 说明 |
|------|------|
| `0001-rustc-ohos-auto-sign-fix.patch` | 平台识别（`aarch64-unknown-linux-ohos`）、ELF 自动签名、链接器配置 |

## 预编译包

| 文件 | 大小 | 说明 |
|------|------|------|
| `rust-1.95.0-aarch64-unknown-linux-ohos.tar.gz` | ~220 MB | 主包（stripped，即装即用） |

## 使用注意项

- 需从应用市场安装 **DevBox**，提供 clang、ohos-sdk 等工具链
- 鸿蒙PC上编译产物及中间产物需 ELF 签名，默认使用内置签名工具，可通过 `OHOS_BINARY_SIGN_TOOL` 环境变量设置

## 快速开始

```bash
# 一键安装
/bin/sh -c "$(curl -fsSL https://gitcode.com/OpenHarmonyPCDeveloper/rust/releases/download/v1.95.0/install.sh)"

# 使配置生效
source ~/.zshrc
source ~/.bashrc

# 验证
rustc --version
# rustc 1.95.0

cargo --version
# cargo 1.95.0

# 创建项目
cargo new hello && cd hello && cargo run
```
