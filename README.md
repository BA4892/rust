# ohos-rust

> Rust Port and Release for HarmonyOS PC

Porting the Rust toolchain to the HarmonyOS PC platform (aarch64 / musl libc / Clang) and providing pre-compiled portable packages.

---

## Version Overview

| Version | Status | Description |
|------|------|------|
| [**1.95.0**](https://gitcode.com/OpenHarmonyPCDeveloper/rust/tree/v1.95.0/) | 🌟 **Latest** | **Stable release, full toolchain** |
| [1.89.0](https://gitcode.com/OpenHarmonyPCDeveloper/rust/tree/v1.89.0/) | ✅ Available | First compatible version |

---

## 🎉 Latest Release

**Rust 1.95.0** (2026-04-28) — **Stable release, full toolchain**

| Item | Value |
|------|------|
| Rust Version | 1.95.0 |
| Build System | rustbuild (x.py dist) |
| Adaptation Status | ✅ Core features available |
| Built-in Tools | rustc, cargo, rustdoc, rustfmt, clippy, rust-analyzer |
| Target Platform | HarmonyOS aarch64, musl libc, Clang 15.0.4 |
| Kernel Version | HongMeng Kernel 1.11.0 |
| Target Triplet | `aarch64-unknown-linux-ohos` |
| Package Size | ~220 MB (stripped, ready-to-use) |

---

## Feature Overview

### Features

- **Compiler**: rustc compilation, type checking, macro expansion, generics, traits, lifetimes, async/await, pattern matching, etc.
- **Package Manager**: cargo new/build/run/test/bench/doc/clean/update, etc.
- **Formatting**: rustfmt code formatting
- **Lint**: clippy static analysis
- **Documentation**: rustdoc documentation generation
- **Code Analysis**: rust-analyzer language server
- **Standard Library**: std core functionality (collections, io, net, fs, sync, async)

### Patch Descriptions

| Patch | Description |
|------|------|
| `0001-rustc-ohos-auto-sign-fix.patch` | Platform detection (`aarch64-unknown-linux-ohos`), ELF auto-signing, linker configuration |

---

## 📦 Download and Installation

| File | Size | Description |
|------|------|------|
| `rust-1.95.0-aarch64-unknown-linux-ohos.tar.gz` | ~220 MB | Main package (stripped, ready to use) |

#
