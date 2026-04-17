# ohos-rust

> 面向 HarmonyOS PC 的 Rust 移植与发布

将 Rust 工具链移植到鸿蒙 PC 平台（aarch64 / musl libc / Clang），提供预编译可移植包。

---

## 🎉 最新发布

**Rust 1.89.0**（2026-04-16）— **核心工具链可用**

| 指标 | 数值 |
|------|------|
| 内置工具 | rustc, cargo, rustdoc, rustfmt, clippy, rust-analyzer |
| 目标三元组 | `aarch64-unknown-linux-ohos` |
| 补丁数 | 1 个（平台识别 + ELF 自动签名） |
| 包大小 | **~220 MB**（stripped，即装即用） |
| 一键安装 | ✅ 支持 |

📦 **下载安装**：[rust](https://gitcode.com/OpenHarmonyPCDeveloper/rust)

| 软件 | 版本 | 安装命令 |
|------|------|------|
| rust | 1.89.0 | `/bin/sh -c "$(curl -fsSL https://gitcode.com/OpenHarmonyPCDeveloper/rust/releases/download/v1.89.0/install.sh)"` |

---

## 版本一览

| 版本 | 状态 | 说明 |
|------|------|------|
| [**1.89.0**](https://gitcode.com/OpenHarmonyPCDeveloper/rust/tree/v1.89.0/) | 🌟 **最新** | **首个适配版本，完整工具链** |

---

## 许可证

MIT License · Copyright (c) 2025-2026 OpenHarmony PC Developer 社区
