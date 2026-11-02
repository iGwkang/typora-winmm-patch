# Typora 1.14.x 本地激活补丁（winmm.dll）

## 文件

- `winmm.dll` —— 唯一需要放进 Typora 安装目录的文件。
- `install.bat` —— 可选的安装脚本（会询问安装目录，并备份已有的 `winmm.dll`）。

## 适用版本

- 已在 **Typora 1.14.15 x64**（Electron 42.2.0 / Chrome 148）上验证。
- 后续 1.14.x/1.15.x 只要 `resources/app.asar` 里的 `launch.dist.js` 仍是同一套 `.jsc` 加载逻辑，就会自动适配。
- **不适用于 1.3.8 等老版本**（老版本用 `main.node`，不是 `.jsc`）。

## 安装

1. 完全退出 Typora。
2. 把 `winmm.dll` 复制到 Typora 安装目录，和 `Typora.exe` 同级，例如：
   `C:\Program Files\Typora\winmm.dll`
   或运行 `install.bat`，输入安装目录。
3. 启动 Typora。首次启动会在
   `%LOCALAPPDATA%\TyporaPatch\`
   生成 `payload.js` 以及一个按 `app.asar` 内容哈希命名的补丁副本。之后每次启动复用。

> 如果安装目录里已经有别的 `winmm.dll`（例如旧破解），先备份再覆盖，避免两个补丁互相影响。

## 卸载

删除 Typora 安装目录里的 `winmm.dll` 即可恢复原状。可选删除：

```
%LOCALAPPDATA%\TyporaPatch
```

不会修改安装目录中的 `Typora.exe`、`resources\app.asar`、`lib.asar`、`node_modules.asar` 等任何原文件。

## 工作原理（简述）

1. **winmm 代理**：补丁 DLL 导出全部 180 个 winmm 函数，转发到系统
   `%SystemRoot%\System32\winmm.dll`，因此 Typora/Chromium 的多媒体调用不受影响。
2. **app.asar 重定向**：进程启动后，DLL 读取真实的 `resources\app.asar`，
   按内容 SHA-256 在 `%LOCALAPPDATA%\TyporaPatch\<hash>v1\app.asar`
   生成一个**同样大小**的副本，只把其中的 `launch.dist.js` 替换成一个很小的
   loader（其它字节、header、偏移完全不变）。
   然后通过 IAT hook `CreateFileW` / `CreateFile2` / `GetFileAttributesW` /
   `GetFileAttributesExW`，把对原 `app.asar` 的读取重定向到该副本。
   安装目录里的原 asar 保持不变，Typora 更新后哈希变化会自动生成新副本。
3. **JS payload**（DLL 释放到 `%LOCALAPPDATA%\TyporaPatch\payload.js`，由 loader
   在原始 `.jsc` 之前加载）：
   - 把 `HKCU\Software\Typora\SLicense` 的读取伪造成一个本地许可串；
     所有对该键的写入被内存影子值拦截，**不会写注册表**，因此不会影响同机其它
     Typora 版本。
   - hook `crypto.publicDecrypt`，对许可证校验返回与当前机器指纹匹配的许可数据。
     机器指纹算法：`sha256(MachineGuid + "typora")` 的 base64，把 `[/=+-]`
     替换为 `a`，取前 10 位。
   - 屏蔽以下 Typora 通信（Chromium 的 `webRequest` + Node 的
     `http/https/dns/fetch` + DLL 的 DNS hook 三层）：
     `store.typora.io`、`typora.io`、`typoraio.cn`、`typora.com.cn`、
     `dian.typora.com.cn`、`downloads.typora.io`、`downloads.typoraio.cn`。
     保留 `dict.typora.io`（词典）和 `support.typora.io`（帮助）。
   - 完整性检查（Electron asar 校验）在修改 asar 后必然失败并尝试退出；
     payload 只拦截“由 1 秒定时器触发的 `app.quit`/`app.exit`/`process.exit`”，
     用户正常退出不受影响。
   - 兜底：把注入到渲染进程的 `File.option.hasLicense = false` 改写为 `true`，
     并去掉“未激活”角标。
   - `/api/client/renew` 续期请求不落到网络层，由 payload 直接返回
     `200 {"success":true}`；否则续期失败会在约 9 分钟后把许可标记为无效
     并弹出试用/激活窗口。

## 已知现象

- `%APPDATA%\Typora\typora.log` 里每次启动会出现：

  ```
  ERROR ... [LC] l
  ERROR ... Integrity check failed
  ```

  这是完整性校验发现 asar 被改后的日志，补丁已阻止它退出，**不影响功能**。
- 许可证面板显示：
  `email=patched@localhost`，`license=ABCDEF-GHJKMNP-QRSTUV-WXYZ23`，`type=full`。
  这是本地伪造的展示信息。
- 因为屏蔽了更新域名，Typora 的“检查更新”会失败；需要更新时请手动下载安装包。
  覆盖安装后只要 `winmm.dll` 还在目录里，补丁会自动适配新的 `app.asar`。

## 重新构建

源码在上一级目录：

- `src/payload.js` —— 注入的 JS。
- `src/loader.min.js` —— loader 参考（DLL 里会按实际 payload 路径动态生成）。
- `dll/winmm_proxy.cpp` —— DLL 主体（IAT hook、asar 补丁、DNS 屏蔽）。
- `dll/winmm_stubs.asm` —— 180 个 winmm 导出跳板（MASM）。
- `dll/winmm_stubs.cpp` —— 跳板指针定义，启动时从系统 winmm 解析。
- `dll/winmm_proxy.def` —— 导出表。
- `dll/payload_js.h` —— 由 `dll/gen_payload.py` 从 `src/payload.js` 生成。
- `dll/build.bat` —— 需要 VS2022（x64 工具链、ml64）。

构建后产物为 `patch/winmm.dll`。

## 风险与免责

- DLL 使用 API hook 和 DLL 劫持，部分杀毒软件可能误报。
- 仅供本机学习/测试使用；请支持正版。
- 如果未来 Typora 大改 `launch.dist.js`/`.jsc` 加载方式，补丁可能失效，需要更新源码。
