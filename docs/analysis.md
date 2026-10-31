# 逆向分析与补丁设计记录

对象：`typora-setup-x64.exe`（Inno Setup 6.0，Typora 1.14.15，Electron 42.2.0 / Chrome 148，x64）。

## 1. 包结构

`innounp` 解包后：

```
Typora.exe                 227,371,136 bytes  (Electron 主程序)
resources/app.asar         390,835 bytes      (只有 3 个文件)
  atom.compiled.dist.jsc   388,400 bytes      (V8 cached bytecode / bytenode)
  launch.dist.js           1,383 bytes        (bytecode loader)
  package.json             252 bytes
resources/lib.asar         8,342,504 bytes
resources/node_modules.asar 9,970,596 bytes
resources/node_modules/main.node  (spellchecker，不含许可逻辑)
```

`package.json` 的 `main` 为 `launch.dist.js`；`launch.dist.js` 设置
`Module._extensions['.jsc']`，用 `vm.Script` + `cachedData` 加载
`atom.compiled.dist.jsc`。

## 2. 许可

- 机器码由 `license.machineCode` 返回：base64(JSON)，形如
  `{"v":"win|1.14.15","i":"Wkv6kaubjE","l":"DESKTOP-... | user | Windows"}`。
- `i`（machineId）算法：
  `sha256(MachineGuid + "typora")` → base64 → 将 `[/=+-]` 替换为 `a` → 取前 10 位。
  `MachineGuid` 来自 `HKLM\SOFTWARE\Microsoft\Cryptography`。
- 本地许可存储：`HKCU\Software\Typora`。
  - `SLicense` 形如 `<encrypted>#<failCount>#<M/D/YYYY>`；
  - `IDate` 为安装日期。
- 启动时对 `SLicense` 的第一段进行 `crypto.publicDecrypt(内置 RSA 公钥, ...)`，
  解密结果按 JSON 解析，读取字段：`fingerprint`、`license`、`email`、`type`、
  `deviceId`、`lastRetry`。
  - `fingerprint` 必须等于当前 machineId，否则直接判为未激活；
  - 其余字段用于展示/renew。
- renew 请求发往 `/api/client/renew`（默认 `store.typora.io`，国内为
  `dian.typora.com.cn`）；失败不会立即清除本地许可，但会写回 failCount。
- 网络请求使用 `electron-fetch`（底层是 Electron `net`），因此可在 Chromium
  `webRequest` 层拦截。

## 3. 主进程状态与界面

主进程判定未激活时，会向渲染进程 `executeJavaScript` 注入：

```js
if(window.File.option){
  File.option.hasLicense = false;
  File.megaMenu && File.megaMenu.forceReload();
  // 在页面右下角插入“UNREGISTERED × / 未激活 ×”角标
}
```

补丁在 `webContents.executeJavaScript` 层把这段改写为
`File.option.hasLicense = true`，并去掉角标；主进程状态则由伪造的
`publicDecrypt` 结果保证。

## 4. 完整性校验

- Typora.exe 的 PE 资源中有：

  ```
  Type: INTEGRITY, Name: ELECTRONASAR, Lang: 1
  [{"file":"resources\\app.asar","alg":"SHA256","value":"<64 hex>"}]
  ```

  该值等于 `app.asar` **header JSON 字符串**的 SHA-256（不是整个 asar，
  不是 header 的 pickle 外壳）。
- asar header 里每个文件还有自己的 `integrity` 对象（`SHA256` + `blocks`）。
- 实验结论：
  - 只改文件数据（保持 header 不变）→ 校验失败；
  - 只改 header（增加一个无害字段）并把 exe 资源里的期望哈希改成新 header 的哈希
    → 校验通过；
  - 同时改数据和 header 的 per-file integrity，并同步 exe 资源哈希 → **仍然失败**
    （per-file 校验并不完全按 header 的当前值走，或还有其它绑定）。
- 最终采用的方案：**不修改 exe，也不试图让校验通过**。
  用同尺寸 loader 覆盖 `launch.dist.js`，让校验失败，但 payload 只拦截
  “由 `Timeout._onTimeout`（`atom.compiled.dist.jsc`）触发的
  `app.quit` / `app.exit` / `process.exit`”。用户正常退出不受影响。
- 这样做的代价是每次启动日志里有一行 `Integrity check failed`，但功能不受影响。

## 5. asar 重定向

- DLL 读取原 `resources\app.asar`，解析 header（pickle：
  `[u32 4][u32 headerSize][u32 payloadSize][u32 jsonLen][json...]`），
  找到 `launch.dist.js` 的 `offset` / `size`。
- 在 `%LOCALAPPDATA%\TyporaPatch\<sha256前16位>v1\app.asar` 写入同尺寸副本：
  头部/偏移/其它字节完全不变，仅把 `launch.dist.js` 区域替换为
  `<loader><空格填充>`。
- IAT hook `CreateFileW` / `CreateFile2` / `GetFileAttributesW` /
  `GetFileAttributesExW`，把对原 asar 的访问重定向到副本。
- 副本与源文件大小相同，因此所有检查大小/偏移的代码不受影响；原文件不被修改，
  更新后哈希变化会自动生成新副本。

## 6. loader

`launch.dist.js` 的原始逻辑是给 V8 cached data 打补丁并构造一个长度匹配的
占位 source，然后 `runInThisContext` 执行 jsc。补丁用一个约 880 字节的等价
loader 替换它：

1. 先 `require("<payload路径>")`；
2. 再 `require("./atom.compiled.dist.jsc")`。

payload 路径由 DLL 在生成 loader 时填入（`%LOCALAPPDATA%\TyporaPatch\payload.js`），
loader 长度必须小于原始 `launch.dist.js` 的 size（1.14.15 为 1383 字节，足够）。

## 7. payload

- hook `native-reg`：
  - 读取 `Software\Typora\SLicense` 时返回合成的
    `ABCDEF-GHJKMNP-QRSTUV-WXYZ23#0#<today>`；
  - 记录 `MachineGuid`；
  - 对 `Software\Typora` 的所有写入只写内存影子值，**不落真实注册表**，
    避免影响同机其它 Typora 版本。
- hook `crypto.createHash` 捕获 `sha256(GUID + "typora")` 的结果，计算 fingerprint。
- hook `crypto.publicDecrypt`：遇到内置 RSA 公钥时返回包含上述字段的 JSON Buffer。
- 网络：
  - `session.defaultSession.webRequest.onBeforeRequest` 取消 Typora 许可/更新请求；
  - `app.commandLine.appendSwitch('host-resolver-rules', ...)` 做 DNS 兜底；
  - Node `http/https/dns/fetch` 同域名拦截；
  - DLL 的 `GetAddrInfoW` / `GetAddrInfoExW` / `getaddrinfo` / `gethostbyname`
    再做一层，允许 `dict.typora.io`、`support.typora.io`。
- 退出抑制：只匹配
  `Timeout._onTimeout` + `atom.compiled.dist.jsc` 的调用栈。

## 8. 兼容性

- 1.3.8 使用 `main.node`（原生）而不是 `.jsc`，本方案不适用。
- 1.14.x/1.15.x 若仍使用相同的 `launch.dist.js` + `.jsc` 结构，DLL 会按新 asar
  自动重新生成副本，无需重新编译。
- 若 `launch.dist.js` 的 loader 逻辑或 `.jsc` 加载方式变化，需要同步更新
  `dll/winmm_proxy.cpp` 中的 `kLoaderTemplate`。
