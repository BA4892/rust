# OpenHarmony NAPI 使用指南

使用 `ohos_napi_rs` 开发 Rust NAPI 模块。

---

## 前置准备

**交叉编译环境配置**请参考：[cross-compilation](../cross-compilation/README.md)

确保已完成：
- Rust 工具链安装
- `aarch64-unknown-linux-ohos` target 安装
- OpenHarmony SDK 配置
- `.cargo/config.toml` 配置

---

## 创建项目

### 1. 新建项目

```bash
cargo new my_napi --lib
cd my_napi
```

### 2. 配置 Cargo.toml

```toml
[package]
name = "my_napi"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
napi = { git = "https://gitcode.com/openharmony-tpc/ohos_napi_rs.git" }
napi-derive = { git = "https://gitcode.com/openharmony-tpc/ohos_napi_rs.git" }

[build-dependencies]
napi-build = { git = "https://gitcode.com/openharmony-tpc/ohos_napi_rs.git" }
```

### 3. 创建 build.rs

```rust
fn main() {
    napi_build::setup();
}
```

---

## 编写 NAPI 代码

编辑 `src/lib.rs`：

```rust
use napi_derive::napi;

#[napi]
pub fn add(a: u32, b: u32) -> u32 {
    a + b
}
```

---

## 编译

```bash
cargo build --target aarch64-unknown-linux-ohos
```

输出：

```
target/aarch64-unknown-linux-ohos/debug/libmy_napi.so
```

---

## 集成到应用

### 1. 复制 .so 文件

```
your_app/entry/libs/arm64-v8a/libmy_napi.so
```

### 2. ArkTS 调用

```typescript
import native from 'libmy_napi.so';

native.add(1, 2);  // 3
```

---

## 参考资源

- [ohos_napi_rs 仓库](https://gitcode.com/openharmony-tpc/ohos_napi_rs)
- [cross-compilation](../cross-compilation/README.md) - 交叉编译详解
- **[详细使用指南](https://gitcode.com/openharmony-tpc/ohos_napi_rs/blob/master/docs/user_guide.md)** - 更多 NAPI 用法

---

## 常见问题

### 编译警告 unexpected cfg

添加 `#![allow(unexpected_cfgs)]` 到 `lib.rs` 开头（如果出现警告）。

### module not found

确保 `.so` 文件在 `entry/libs/arm64-v8a/` 目录。

---

**编译配置问题**（如 linker not found）请参考 [cross-compilation](../cross-compilation/README.md)。

---