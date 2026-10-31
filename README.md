# Typora 1.14.x winmm patch

> 仅供本机学习、研究与兼容性测试使用。请支持正版 Typora。
> 本仓库不包含 Typora 安装包、原始 `app.asar` 或任何 Typora 二进制文件。
> 补丁会绕过 Typora 的许可校验并屏蔽其许可/更新服务器通信，请自行确认所在地法律与服务条款；不要用于商业分发。

这是一个可复现构建的 Windows x64 `winmm.dll` 补丁，用于 Typora 1.14.x：

- 本地激活（不依赖 Typora 服务器，不修改安装目录里的任何原文件）；
- 屏蔽 Typora 许可/更新域名；
- 客户端更新后，按新的 `resources/app.asar` 内容哈希自动重新生成补丁副本；
- 在 **Typora 1.14.15**（Electron 42.2.0 / Chrome 148）上验证。

## 使用

把 `patch/winmm.dll` 复制到 Typora 安装目录（与 `Typora.exe` 同级），重启 Typora。

- 也可以运行 `patch/install.bat`，输入安装目录；脚本会把已有的 `winmm.dll` 备份为 `winmm.dll.bak`。
- 卸载：删除安装目录里的 `winmm.dll`，可选删除 `%LOCALAPPDATA%\TyporaPatch`。
- 不要放进仍在使用其它 `winmm.dll` 破解的旧版 Typora 目录（例如 1.3.8），本补丁只适用于 1.14.x 的 `.jsc` 结构。

详细说明、已知日志与兼容性见 [patch/README.md](patch/README.md)。

## 可复现构建

### 本地构建

要求：

- Windows x64；
- Visual Studio 2022，安装 **使用 C++ 的桌面开发**（`cl.exe`、`ml64.exe`、Windows SDK）；
- Python 3（可选；`dll/payload_js.h` 已提交，只有修改 `src/payload.js` 后才需要重新生成）。

```bat
dll\build.bat
```

产物：`patch\winmm.dll`。

构建脚本通过 `vswhere.exe` 查找 VS 安装；`dll/gen_payload.py` 从 `src/payload.js` 生成 `dll/payload_js.h`；`ml64` 汇编 180 个 winmm 导出跳板；`cl /MT` 链接出只依赖 `KERNEL32.dll` / `WS2_32.dll` 的 DLL。

### CI

`.github/workflows/build.yml` 在 `windows-latest` 上执行同一套 `dll\build.bat`，并上传构建产物。推送或手动触发 workflow 后可在 Actions 页面下载 `winmm-dll`。

### 关于二进制哈希

`patch/winmm.dll` 是本次在 Typora 1.14.15 上实际测试通过的二进制，其 SHA-256 记录在 `SHA256SUMS`。不同 MSVC/Windows SDK 版本重新构建的二进制可能在 PE 时间戳/对齐等非功能字节上不同；功能等价。以源码和 `dll/build.bat` 为准。

## 目录

```
patch/                 发布物：winmm.dll、安装脚本、使用说明
src/payload.js         注入主进程的 JS（许可伪造、网络屏蔽、完整性退出抑制）
src/loader.min.js      asar loader 参考（DLL 会按实际 payload 路径动态生成）
dll/winmm_proxy.cpp    DLL 主体：IAT hook、asar 同尺寸补丁、DNS 屏蔽
dll/winmm_stubs.asm    180 个 winmm 导出跳板（MASM）
dll/winmm_stubs.cpp    跳板指针定义，启动时从系统 winmm 解析
dll/winmm_proxy.def    导出表
dll/payload_js.h       由 src/payload.js 生成的字节数组
dll/build.bat          构建脚本
docs/analysis.md       逆向分析与补丁设计记录
```

## 原理摘要

1. `winmm.dll` 代理全部 winmm 导出，转发到系统 `%SystemRoot%\System32\winmm.dll`。
2. 启动时按真实 `resources\app.asar` 的 SHA-256，在
   `%LOCALAPPDATA%\TyporaPatch\<hash>v1\app.asar` 生成**同样大小**的副本，
   只把 `launch.dist.js` 替换成一个小 loader；其它字节和 asar header/偏移不变。
3. 通过 IAT hook `CreateFileW` / `CreateFile2` / `GetFileAttributes*` 把原 asar 的读取
   重定向到副本。安装目录里的原文件保持不变。
4. loader 在原始 `.jsc` 之前加载 `payload.js`：
   - 伪造 `SLicense` 读取并 hook `crypto.publicDecrypt`；
   - 屏蔽 Typora 许可/更新域名（保留词典与帮助域名）；
   - 忽略 asar 完整性校验定时器触发的进程退出（不影响用户正常退出）。
5. 机器指纹：`sha256(MachineGuid + "typora")` 的 base64，把 `[/=+-]` 替换为 `a`，取前 10 位。

更详细的分析（包括完整性校验资源与绕过方式）见 [docs/analysis.md](docs/analysis.md)。

## 已知现象 / 限制

- `%APPDATA%\Typora\typora.log` 每次启动会出现
  `[LC] l` / `Integrity check failed`，这是完整性校验发现 asar 被修改后的日志，
  补丁已阻止其退出，不影响功能。
- 许可证面板显示 `email=patched@localhost`、`license=ABCDEF-GHJKMNP-QRSTUV-WXYZ23`、`type=full`，
  均为本地展示数据。
- 更新检查被屏蔽；需要更新时手动安装。覆盖安装后若 `winmm.dll` 未被删除，补丁自动适配；
  若安装器清空目录，重新复制一次。
- 未来 Typora 若大幅改动 `launch.dist.js` / `.jsc` 加载方式，补丁可能失效，需要更新源码。
- DLL 使用 DLL 劫持与 API hook，部分杀毒软件可能误报。

## 免责声明

本项目仅用于学习 Windows DLL 加载、Electron/asar 结构与 API hook 技术。使用者需自行承担
许可合规、法律与安全风险；作者不对任何损失或纠纷负责。
