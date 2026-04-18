# OHOS Rust 交叉编译指南

目标平台：`aarch64-unknown-linux-ohos`（OpenHarmony aarch64）

---

## 通俗理解

**交叉编译**：代码在一台电脑上编译，在另一台完全不同的设备上运行。

| 术语 | 例子 |
|------|------|
| **宿主平台** (Host) | 你用来编译的 x86 Windows/Linux 电脑 |
| **目标平台** (Target) | 代码最终运行的 aarch64 鸿蒙设备（如鸿蒙 PC） |

**为什么需要特殊配置？**
rustc 不知道目标设备的系统长什么样，需要额外提供三样东西。OHOS SDK 中包含了后两样：
1. **标准库**：目标平台的 Rust 标准库（`libstd` 等），由 rustup 安装
2. **sysroot**：目标设备的 libc 和系统头文件，位于 SDK 的 `native/sysroot/`
3. **链接器**：能生成目标机器码的 clang，位于 SDK 的 `native/llvm/bin/`

---

## 步骤一：安装目标平台标准库

```bash
rustup target add aarch64-unknown-linux-ohos
```

**目的**：下载目标平台（aarch64）的 Rust 标准库（`libstd`、`libcore` 等）。
rustc 编译时需要把这些库链接进你的程序，否则程序无法在鸿蒙设备上运行。

---

## 步骤二：获取 OpenHarmony SDK

获取 OpenHarmony SDK 并解压。
示例链接（OpenHarmony 6.1）：
```
https://cidownload.openharmony.cn/version/Master_Version/OpenHarmony_6.1.0.31/20260311_020435/version-Master_Version-OpenHarmony_6.1.0.31-20260311_020435-ohos-sdk-full_6.1-Release.tar.gz
```

> **注意**：SDK 包内包含了 Windows、Linux 等多个宿主平台的工具。
> 你只需要保留**当前电脑（宿主平台）**对应的那部分工具即可（例如 Windows 电脑用 `windows/` 下的，Linux 电脑用 `linux/` 下的），其他的可以忽略。

**目的**：SDK 的 native 组件提供两样东西：
- `native/llvm/bin/clang` —— 这是**宿主平台**（你的电脑）上运行的程序，但它是**交叉编译器**，知道如何生成**目标平台**（鸿蒙）的代码
- `native/sysroot/` —— 这里是**目标平台**的 libc（musl）、头文件和系统库。链接器需要从中查找符号，就像在设备上编译时需要系统库一样

> 已安装 DevEco Studio 的用户可直接使用其自带的 SDK，否则下载 SDK 压缩包解压即可。

---

## 步骤三：配置 `.cargo/config.toml`

在项目根目录创建 `.cargo/config.toml`，告诉 cargo 如何进行交叉编译。

> 以下路径为**示例路径**（假设 Windows 下 SDK 在 `D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony`，Linux 下在 `/home/user/DevEcoStudio/sdk/default/openharmony`），请替换为你电脑上的实际 SDK 路径。

### Windows 主机

```toml
[target.aarch64-unknown-linux-ohos]

# 链接器：告诉 rustc 用 OHOS 的 clang 进行链接
linker = "D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\llvm\\bin\\clang.exe"

# 传递给链接器的参数
rustflags = [
    "-C", "link-arg=--sysroot=D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\sysroot",
    "-C", "link-arg=--target=aarch64-linux-ohos",
    "-C", "link-arg=-O2",
]

# 静态库工具：用于打包 .a/.rlib 文件
ar = "D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\llvm\\bin\\llvm-ar.exe"

# 环境变量：如果项目依赖包含 C/C++ 代码（使用 cc crate），需要告诉它用哪个编译器
[env]
CC_aarch64_unknown_linux_ohos = "D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\llvm\\bin\\clang.exe"
CXX_aarch64_unknown_linux_ohos = "D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\llvm\\bin\\clang++.exe"
AR_aarch64_unknown_linux_ohos = "D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\llvm\\bin\\llvm-ar.exe"
RANLIB_aarch64_unknown_linux_ohos = "D:\\DevEco\\DevEco Studio\\sdk\\default\\openharmony\\native\\llvm\\bin\\llvm-ranlib.exe"
```

### Linux 主机

```toml
[target.aarch64-unknown-linux-ohos]

linker = "/home/user/DevEcoStudio/sdk/default/openharmony/native/llvm/bin/clang"

rustflags = [
    "-C", "link-arg=--sysroot=/home/user/DevEcoStudio/sdk/default/openharmony/native/sysroot",
    "-C", "link-arg=--target=aarch64-linux-ohos",
    "-C", "link-arg=-O2",
]

ar = "/home/user/DevEcoStudio/sdk/default/openharmony/native/llvm/bin/llvm-ar"

[env]
CC_aarch64_unknown_linux_ohos = "/home/user/DevEcoStudio/sdk/default/openharmony/native/llvm/bin/clang"
CXX_aarch64_unknown_linux_ohos = "/home/user/DevEcoStudio/sdk/default/openharmony/native/llvm/bin/clang++"
AR_aarch64_unknown_linux_ohos = "/home/user/DevEcoStudio/sdk/default/openharmony/native/llvm/bin/llvm-ar"
RANLIB_aarch64_unknown_linux_ohos = "/home/user/DevEcoStudio/sdk/default/openharmony/native/llvm/bin/llvm-ranlib"
```

### 配置项说明

| 配置项 | 作用 |
|--------|------|
| `linker` | rustc 在链接阶段调用的程序。默认是系统的 `cc`，交叉编译时必须替换为目标平台的 clang |
| `rustflags` | 传递给 rustc 的额外参数。`-C link-arg=X` 会将 X 透传给链接器。`--sysroot` 告诉链接器去哪找目标系统的库，`--target` 告诉 clang 目标 triple |
| `ar` | rustc 打包静态库（`.rlib`/`.a`）时使用的归档工具 |
| `[env]` | 设置环境变量。如果项目依赖了包含 C/C++ 代码的 crate（如 `cc` crate），它会按 `CC_<目标平台>` 的命名规则查找编译器 |

> **注意**：`.cargo/config.toml` 中不支持 `$HOME` 等环境变量展开，必须写绝对路径。

---

## 步骤四：编译

```bash
cargo build --target aarch64-unknown-linux-ohos
cargo build --release --target aarch64-unknown-linux-ohos
```

**目的**：`--target` 告知 cargo 目标平台，cargo 会查找 `.cargo/config.toml` 中对应的配置。

### Release 优化

在 `Cargo.toml` 中添加：

```toml
[profile.release]
opt-level = 3          # 最高优化级别
lto = true             # 链接时优化，跨 crate 内联
codegen-units = 1      # 单个代码生成单元，最大化 LTO 效果
panic = "abort"        # panic 时直接终止，避免展开开销
strip = true           # 编译后自动剥离符号表，减小体积
```

---

## 步骤五：验证产物

```bash
file target/aarch64-unknown-linux-ohos/release/your_binary
```

正确输出：
```
ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV),
dynamically linked, interpreter /lib/ld-musl-aarch64.so.1
```

**目的**：确认生成的二进制文件是给 ARM aarch64 的，而不是给你当前电脑的。

---

## 步骤六：部署到设备

```bash
# 推送二进制到设备
hdc file send target/aarch64-unknown-linux-ohos/release/your_binary /data/local/tmp/

# 设置执行权限
hdc shell "chmod +x /data/local/tmp/your_binary"

# 运行
hdc shell "/data/local/tmp/your_binary"
```

**目的**：将程序传输到设备上运行。`/data/local/tmp/` 是 OHOS 沙盒下常用的可执行目录。

---

## 常见问题

### linker not found
检查 SDK 路径是否正确，clang 文件是否存在。

### cc crate 编译失败
确认 `[env]` 中 `CC_aarch64_unknown_linux_ohos` 路径正确。注意目标 triple 中的连字符 `-` 需要替换为下划线 `_`。

### 动态库缺失
OHOS 使用 musl libc。目标设备上需要有 `/lib/ld-musl-aarch64.so.1`。

---
