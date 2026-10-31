// winmm.dll proxy patch for Typora.
// Forwards all winmm exports to winmm_real.dll (a copy of the system winmm),
// redirects resources\app.asar to a same-size patched copy, and blocks
// Typora license/update hostnames.
//
// Build with MSVC x64: see build.bat.
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0601
#endif
#include <windows.h>
#include <ws2tcpip.h>
#include <string>
#include <vector>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <cwctype>
#include "payload_js.h"

extern "C" void InitWinmmStubs();

static const void* find_bytes(const void* hay, size_t hayLen, const void* needle, size_t needleLen) {
  if (!hay || !needle || needleLen == 0 || hayLen < needleLen) return nullptr;
  const uint8_t* h = (const uint8_t*)hay;
  const uint8_t* n = (const uint8_t*)needle;
  for (size_t i = 0; i + needleLen <= hayLen; i++) {
    if (h[i] == n[0] && memcmp(h + i, n, needleLen) == 0) return h + i;
  }
  return nullptr;
}

#pragma comment(lib, "ws2_32.lib")

namespace {

const wchar_t* kPatchVersion = L"v1";
const char* kLoaderTemplate =
    R"(const fs=require("fs"),vm=require("vm"),M=require("module"),p=require("path"),v8=require("v8");v8.setFlagsFromString("--no-lazy");v8.setFlagsFromString("--no-flush-bytecode");const D=new vm.Script("",{produceCachedData:!0}).createCachedData();M._extensions[".jsc"]=M._extensions[".cjsc"]=(e,t)=>{let a=fs.readFileSync(t);D.slice(12,16).copy(a,12);let r=a[8]|a[9]<<8|a[10]<<16|a[11]<<24,o=r>1?'"'+("\u200b").repeat(r-2)+'"':"",c=new vm.Script(o,{filename:t,displayErrors:!0,cachedData:a});if(c.cachedDataRejected)throw Error("bad cached data");let n=t=>e.require(t);n.resolve=(t,x)=>M._resolveFilename(t,e,!1,x);n.main=process.mainModule;n.extensions=M._extensions;n.cache=M._cache;let s=c.runInThisContext({filename:t});return s.apply(e.exports,[e.exports,n,e,t,p.dirname(t),process,global])};require("%s");require("./atom.compiled.dist.jsc");)";

HMODULE g_hInst = nullptr;
HMODULE g_kernel32 = nullptr;
HMODULE g_ws2 = nullptr;

std::wstring g_appDir;
std::wstring g_origAsar;
std::wstring g_patchRoot;
std::wstring g_payloadPath;
std::wstring g_patchedAsar;
bool g_init = false;
bool g_patchTried = false;
CRITICAL_SECTION g_cs;

typedef HANDLE(WINAPI* PFN_CreateFileW)(LPCWSTR, DWORD, DWORD,
                                       LPSECURITY_ATTRIBUTES, DWORD, DWORD,
                                       HANDLE);
typedef HANDLE(WINAPI* PFN_CreateFile2)(LPCWSTR, DWORD, DWORD, DWORD,
                                        void*);
typedef DWORD(WINAPI* PFN_GetFileAttributesW)(LPCWSTR);
typedef BOOL(WINAPI* PFN_GetFileAttributesExW)(LPCWSTR, GET_FILEEX_INFO_LEVELS,
                                               LPVOID);
typedef INT(WSAAPI* PFN_GetAddrInfoW)(PCWSTR, PCWSTR, const ADDRINFOW*,
                                      PADDRINFOW*);
typedef INT(WSAAPI* PFN_GetAddrInfoExW)(PCWSTR, PCWSTR, DWORD, LPGUID,
                                        const ADDRINFOEXW*, PADDRINFOEXW*,
                                        struct timeval*, LPOVERLAPPED,
                                        void*, LPHANDLE);
typedef INT(WSAAPI* PFN_getaddrinfo)(PCSTR, PCSTR, const ADDRINFOA*,
                                     PADDRINFOA*);
typedef struct hostent*(WSAAPI* PFN_gethostbyname)(PCSTR);

PFN_CreateFileW real_CreateFileW = nullptr;
PFN_CreateFile2 real_CreateFile2 = nullptr;
PFN_GetFileAttributesW real_GetFileAttributesW = nullptr;
PFN_GetFileAttributesExW real_GetFileAttributesExW = nullptr;
PFN_GetAddrInfoW real_GetAddrInfoW = nullptr;
PFN_GetAddrInfoExW real_GetAddrInfoExW = nullptr;
PFN_getaddrinfo real_getaddrinfo = nullptr;
PFN_gethostbyname real_gethostbyname = nullptr;

// ---------------------------------------------------------------- SHA-256
struct Sha256 {
  uint32_t h[8];
  uint64_t len;
  uint8_t buf[64];
  size_t used;
  Sha256() { reset(); }
  void reset() {
    static const uint32_t init[8] = {0x6a09e667, 0xbb67ae85, 0x3c6ef372,
                                     0xa54ff53a, 0x510e527f, 0x9b05688c,
                                     0x1f83d9ab, 0x5be0cd19};
    memcpy(h, init, sizeof(h));
    len = 0;
    used = 0;
  }
  static uint32_t ror(uint32_t x, int n) { return (x >> n) | (x << (32 - n)); }
  void block(const uint8_t* p) {
    static const uint32_t k[64] = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b,
        0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01,
        0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7,
        0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
        0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152,
        0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
        0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
        0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819,
        0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08,
        0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f,
        0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
        0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};
    uint32_t w[64];
    for (int i = 0; i < 16; i++)
      w[i] = (uint32_t(p[4 * i]) << 24) | (uint32_t(p[4 * i + 1]) << 16) |
             (uint32_t(p[4 * i + 2]) << 8) | uint32_t(p[4 * i + 3]);
    for (int i = 16; i < 64; i++) {
      uint32_t s0 = ror(w[i - 15], 7) ^ ror(w[i - 15], 18) ^ (w[i - 15] >> 3);
      uint32_t s1 = ror(w[i - 2], 17) ^ ror(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = w[i - 16] + s0 + w[i - 7] + s1;
    }
    uint32_t a = h[0], b = h[1], c = h[2], d = h[3], e = h[4], f = h[5],
             g = h[6], hh = h[7];
    for (int i = 0; i < 64; i++) {
      uint32_t S1 = ror(e, 6) ^ ror(e, 11) ^ ror(e, 25);
      uint32_t ch = (e & f) ^ (~e & g);
      uint32_t t1 = hh + S1 + ch + k[i] + w[i];
      uint32_t S0 = ror(a, 2) ^ ror(a, 13) ^ ror(a, 22);
      uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
      uint32_t t2 = S0 + maj;
      hh = g; g = f; f = e; e = d + t1; d = c; c = b; b = a; a = t1 + t2;
    }
    h[0] += a; h[1] += b; h[2] += c; h[3] += d;
    h[4] += e; h[5] += f; h[6] += g; h[7] += hh;
  }
  void update(const void* data, size_t n) {
    const uint8_t* p = (const uint8_t*)data;
    len += n;
    while (n) {
      size_t take = 64 - used;
      if (take > n) take = n;
      memcpy(buf + used, p, take);
      used += take; p += take; n -= take;
      if (used == 64) { block(buf); used = 0; }
    }
  }
  void final(uint8_t out[32]) {
    uint64_t bits = len * 8;
    uint8_t pad[72];
    size_t padn = (used < 56) ? (56 - used) : (120 - used);
    pad[0] = 0x80;
    memset(pad + 1, 0, padn - 1);
    update(pad, padn);
    uint8_t lb[8];
    for (int i = 0; i < 8; i++) lb[i] = uint8_t(bits >> (56 - 8 * i));
    update(lb, 8);
    for (int i = 0; i < 8; i++) {
      out[4 * i] = uint8_t(h[i] >> 24);
      out[4 * i + 1] = uint8_t(h[i] >> 16);
      out[4 * i + 2] = uint8_t(h[i] >> 8);
      out[4 * i + 3] = uint8_t(h[i]);
    }
  }
};

// ---------------------------------------------------------------- helpers
std::wstring DirName(const std::wstring& p) {
  size_t i = p.find_last_of(L"\\/");
  return i == std::wstring::npos ? std::wstring() : p.substr(0, i);
}

std::wstring FullPath(const std::wstring& p) {
  wchar_t buf[32768];
  DWORD n = GetFullPathNameW(p.c_str(), 32768, buf, nullptr);
  return (n && n < 32768) ? std::wstring(buf, n) : p;
}

bool EnsureDir(const std::wstring& dir) {
  if (dir.empty()) return false;
  DWORD a = GetFileAttributesW(dir.c_str());
  if (a != INVALID_FILE_ATTRIBUTES && (a & FILE_ATTRIBUTE_DIRECTORY)) return true;
  std::wstring parent = DirName(dir);
  if (!parent.empty() && parent != dir) EnsureDir(parent);
  if (CreateDirectoryW(dir.c_str(), nullptr)) return true;
  return GetLastError() == ERROR_ALREADY_EXISTS;
}

std::wstring EnvLocalAppData() {
  wchar_t buf[32768];
  DWORD n = GetEnvironmentVariableW(L"LOCALAPPDATA", buf, 32768);
  if (n && n < 32768) return std::wstring(buf, n);
  n = GetEnvironmentVariableW(L"USERPROFILE", buf, 32768);
  if (n && n < 32768) return std::wstring(buf, n) + L"\\AppData\\Local";
  return L"C:\\Windows\\Temp";
}

bool ReadWholeFile(const std::wstring& path, std::vector<uint8_t>& out) {
  if (!real_CreateFileW) return false;
  HANDLE h = real_CreateFileW(path.c_str(), GENERIC_READ,
                              FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                              OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (h == INVALID_HANDLE_VALUE) return false;
  LARGE_INTEGER sz;
  if (!GetFileSizeEx(h, &sz) || sz.QuadPart <= 0 ||
      sz.QuadPart > (LONGLONG)128 * 1024 * 1024) {
    CloseHandle(h);
    return false;
  }
  out.resize((size_t)sz.QuadPart);
  size_t done = 0;
  while (done < out.size()) {
    DWORD got = 0;
    DWORD want = (DWORD)((out.size() - done) > (1u << 20) ? (1u << 20)
                                                       : (out.size() - done));
    if (!ReadFile(h, out.data() + done, want, &got, nullptr) || got == 0) break;
    done += got;
  }
  CloseHandle(h);
  if (done != out.size()) return false;
  return true;
}

bool WriteWholeFile(const std::wstring& path, const uint8_t* data, size_t len) {
  if (!real_CreateFileW) return false;
  HANDLE h = real_CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr,
                              CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (h == INVALID_HANDLE_VALUE) return false;
  size_t done = 0;
  bool ok = true;
  while (done < len) {
    DWORD wrote = 0;
    DWORD want = (DWORD)((len - done) > (1u << 20) ? (1u << 20) : (len - done));
    if (!WriteFile(h, data + done, want, &wrote, nullptr) || wrote == 0) {
      ok = false;
      break;
    }
    done += wrote;
  }
  CloseHandle(h);
  return ok && done == len;
}

bool FileSame(const std::wstring& path, const uint8_t* data, size_t len) {
  std::vector<uint8_t> cur;
  if (!ReadWholeFile(path, cur) || cur.size() != len) return false;
  return memcmp(cur.data(), data, len) == 0;
}

bool ParseAsarLaunch(const std::vector<uint8_t>& file, size_t& dataBase,
                     size_t& entryOff, size_t& entryLen) {
  if (file.size() < 16) return false;
  uint32_t hdrSize = 0, strLen = 0;
  memcpy(&hdrSize, file.data() + 4, 4);
  memcpy(&strLen, file.data() + 12, 4);
  if (16ull + strLen > file.size()) return false;
  const char* js = (const char*)file.data() + 16;
  const char* end = js + strLen;
  const char key[] = "\"launch.dist.js\"";
  const char* p = (const char*)find_bytes(js, strLen, key, sizeof(key) - 1);
  if (!p) return false;
  p += sizeof(key) - 1;
  const char* limit = (p + 1024 < end) ? p + 1024 : end;
  const char* sp = (const char*)find_bytes(p, limit - p, "\"size\":", 7);
  if (!sp) return false;
  sp += 7;
  while (sp < limit && (*sp == ' ' || *sp == '"')) sp++;
  uint64_t sizeVal = 0;
  while (sp < limit && *sp >= '0' && *sp <= '9') sizeVal = sizeVal * 10 + (*sp++ - '0');
  const char* op = (const char*)find_bytes(p, limit - p, "\"offset\":\"", 10);
  if (!op) return false;
  op += 10;
  uint64_t offVal = 0;
  while (op < limit && *op >= '0' && *op <= '9') offVal = offVal * 10 + (*op++ - '0');
  dataBase = 8ull + hdrSize;
  entryOff = dataBase + offVal;
  entryLen = (size_t)sizeVal;
  if (entryLen == 0 || entryOff + entryLen > file.size()) return false;
  return true;
}

bool EnsurePatched() {
  if (!real_CreateFileW) return false;
  if (!g_patchedAsar.empty()) return true;
  EnterCriticalSection(&g_cs);
  if (!g_patchedAsar.empty()) { LeaveCriticalSection(&g_cs); return true; }
  bool ok = false;
  do {
    std::vector<uint8_t> orig;
    if (!ReadWholeFile(g_origAsar, orig)) break;
    uint8_t digest[32];
    Sha256 sha;
    sha.update(orig.data(), orig.size());
    sha.final(digest);
    wchar_t hex[17];
    for (int i = 0; i < 8; i++) swprintf_s(hex + 2 * i, 3, L"%02x", digest[i]);
    std::wstring dir =
        g_patchRoot + L"\\" + std::wstring(hex) + kPatchVersion;
    std::wstring patched = dir + L"\\app.asar";
    EnsureDir(g_patchRoot);
    EnsureDir(dir);
    if (!FileSame(g_payloadPath, kPayloadJs, kPayloadJsLen)) {
      WriteWholeFile(g_payloadPath, kPayloadJs, kPayloadJsLen);
    }
    DWORD attr = GetFileAttributesW(patched.c_str());
    if (attr != INVALID_FILE_ATTRIBUTES) {
      LARGE_INTEGER sz;
      HANDLE h = real_CreateFileW(patched.c_str(), GENERIC_READ,
                                  FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                                  OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
      if (h != INVALID_HANDLE_VALUE) {
        bool same = GetFileSizeEx(h, &sz) &&
                    (uint64_t)sz.QuadPart == orig.size();
        CloseHandle(h);
        if (same) {
          g_patchedAsar = patched;
          ok = true;
          break;
        }
      }
    }
    size_t dataBase = 0, entryOff = 0, entryLen = 0;
    if (!ParseAsarLaunch(orig, dataBase, entryOff, entryLen)) break;
    char payloadUtf8[2048];
    int n = WideCharToMultiByte(CP_UTF8, 0, g_payloadPath.c_str(), -1,
                                payloadUtf8, sizeof(payloadUtf8), nullptr,
                                nullptr);
    if (n <= 1) break;
    for (char* q = payloadUtf8; *q; q++)
      if (*q == '\\') *q = '/';
    std::string loader;
    {
      size_t cap = strlen(kLoaderTemplate) + n + 128;
      loader.resize(cap);
      int m = snprintf(&loader[0], cap, kLoaderTemplate, payloadUtf8);
      if (m <= 0 || (size_t)m >= cap) break;
      loader.resize((size_t)m);
    }
    if (loader.size() > entryLen) break;
    std::vector<uint8_t> out = orig;
    memcpy(out.data() + entryOff, loader.data(), loader.size());
    memset(out.data() + entryOff + loader.size(), ' ',
           entryLen - loader.size());
    std::wstring tmp = patched + L".tmp";
    if (!WriteWholeFile(tmp, out.data(), out.size())) {
      DeleteFileW(tmp.c_str());
      break;
    }
    MoveFileExW(tmp.c_str(), patched.c_str(), MOVEFILE_REPLACE_EXISTING);
    g_patchedAsar = patched;
    ok = true;
  } while (false);
  LeaveCriticalSection(&g_cs);
  return ok;
}

// ---------------------------------------------------------------- paths/hosts
bool IsTargetAsar(LPCWSTR name) {
  if (!name || g_origAsar.empty()) return false;
  std::wstring p = name;
  if (p.size() >= 4 && p[0] == L'\\' && p[1] == L'\\' && p[2] == L'?' &&
      p[3] == L'\\')
    p = p.substr(4);
  std::wstring full = FullPath(p);
  return _wcsicmp(full.c_str(), g_origAsar.c_str()) == 0;
}

bool IsBlockedHost(const wchar_t* name) {
  if (!name) return false;
  std::wstring h(name);
  while (!h.empty() && h.back() == L'.') h.pop_back();
  for (auto& c : h) c = (wchar_t)towlower(c);
  if (h == L"dict.typora.io" || h == L"support.typora.io") return false;
  auto ends = [&](const wchar_t* suf) {
    size_t n = wcslen(suf);
    return h.size() >= n && h.compare(h.size() - n, n, suf) == 0;
  };
  if (h == L"typora.io" || ends(L".typora.io")) return true;
  if (h == L"typoraio.cn" || ends(L".typoraio.cn")) return true;
  if (h == L"typora.com.cn" || ends(L".typora.com.cn")) return true;
  return false;
}

// ---------------------------------------------------------------- hooks
HANDLE WINAPI Hook_CreateFileW(LPCWSTR name, DWORD access, DWORD share,
                               LPSECURITY_ATTRIBUTES sa, DWORD disposition,
                               DWORD flags, HANDLE templ) {
  if (IsTargetAsar(name) && EnsurePatched() && !g_patchedAsar.empty())
    name = g_patchedAsar.c_str();
  return real_CreateFileW(name, access, share, sa, disposition, flags, templ);
}

HANDLE WINAPI Hook_CreateFile2(LPCWSTR name, DWORD access, DWORD share,
                               DWORD disposition,
                               void* ext) {
  if (IsTargetAsar(name) && EnsurePatched() && !g_patchedAsar.empty())
    name = g_patchedAsar.c_str();
  return real_CreateFile2(name, access, share, disposition, ext);
}

DWORD WINAPI Hook_GetFileAttributesW(LPCWSTR name) {
  if (IsTargetAsar(name) && EnsurePatched() && !g_patchedAsar.empty())
    name = g_patchedAsar.c_str();
  return real_GetFileAttributesW(name);
}

BOOL WINAPI Hook_GetFileAttributesExW(LPCWSTR name, GET_FILEEX_INFO_LEVELS lvl,
                                      LPVOID info) {
  if (IsTargetAsar(name) && EnsurePatched() && !g_patchedAsar.empty())
    name = g_patchedAsar.c_str();
  return real_GetFileAttributesExW(name, lvl, info);
}

INT WSAAPI Hook_GetAddrInfoW(PCWSTR name, PCWSTR service,
                             const ADDRINFOW* hints, PADDRINFOW* result) {
  if (IsBlockedHost(name)) {
    if (result) *result = nullptr;
    return WSAHOST_NOT_FOUND;
  }
  return real_GetAddrInfoW(name, service, hints, result);
}

INT WSAAPI Hook_GetAddrInfoExW(PCWSTR name, PCWSTR service, DWORD ns,
                               LPGUID nsp, const ADDRINFOEXW* hints,
                               PADDRINFOEXW* result, struct timeval* timeout,
                               LPOVERLAPPED ov, void* cb,
                               LPHANDLE handle) {
  if (IsBlockedHost(name)) {
    if (result) *result = nullptr;
    return WSAHOST_NOT_FOUND;
  }
  return real_GetAddrInfoExW(name, service, ns, nsp, hints, result, timeout, ov,
                             cb, handle);
}

INT WSAAPI Hook_getaddrinfo(PCSTR name, PCSTR service, const ADDRINFOA* hints,
                            PADDRINFOA* result) {
  if (name) {
    wchar_t w[1024];
    MultiByteToWideChar(CP_ACP, 0, name, -1, w, 1024);
    if (IsBlockedHost(w)) {
      if (result) *result = nullptr;
      return EAI_NONAME;
    }
  }
  return real_getaddrinfo(name, service, hints, result);
}

struct hostent* WSAAPI Hook_gethostbyname(PCSTR name) {
  if (name) {
    wchar_t w[1024];
    MultiByteToWideChar(CP_ACP, 0, name, -1, w, 1024);
    if (IsBlockedHost(w)) {
      WSASetLastError(WSAHOST_NOT_FOUND);
      return nullptr;
    }
  }
  return real_gethostbyname(name);
}

void* ResolveHook(const char* name) {
  if (!strcmp(name, "CreateFileW")) return (void*)&Hook_CreateFileW;
  if (!strcmp(name, "CreateFile2")) return (void*)&Hook_CreateFile2;
  if (!strcmp(name, "GetFileAttributesW")) return (void*)&Hook_GetFileAttributesW;
  if (!strcmp(name, "GetFileAttributesExW"))
    return (void*)&Hook_GetFileAttributesExW;
  if (!strcmp(name, "GetAddrInfoW")) return (void*)&Hook_GetAddrInfoW;
  if (!strcmp(name, "GetAddrInfoExW")) return (void*)&Hook_GetAddrInfoExW;
  if (!strcmp(name, "getaddrinfo")) return (void*)&Hook_getaddrinfo;
  if (!strcmp(name, "gethostbyname")) return (void*)&Hook_gethostbyname;
  return nullptr;
}

void PatchThunk(IMAGE_THUNK_DATA* ft, void* hook) {
  DWORD old = 0;
  if (VirtualProtect(&ft->u1.Function, sizeof(void*), PAGE_READWRITE, &old)) {
    ft->u1.Function = (ULONG_PTR)hook;
    VirtualProtect(&ft->u1.Function, sizeof(void*), old, &old);
  }
}

void HookImportTable(HMODULE mod) {
  if (!mod) return;
  uint8_t* base = (uint8_t*)mod;
  auto dos = (PIMAGE_DOS_HEADER)base;
  if (dos->e_magic != IMAGE_DOS_SIGNATURE) return;
  auto nt = (PIMAGE_NT_HEADERS)(base + dos->e_lfanew);
  if (nt->Signature != IMAGE_NT_SIGNATURE) return;
  auto& dir =
      nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
  if (!dir.VirtualAddress || !dir.Size) return;
  auto imp = (PIMAGE_IMPORT_DESCRIPTOR)(base + dir.VirtualAddress);
  for (; imp->Name; imp++) {
    auto oft = (PIMAGE_THUNK_DATA)(base + imp->OriginalFirstThunk);
    auto ft = (PIMAGE_THUNK_DATA)(base + imp->FirstThunk);
    if (!oft) continue;
    for (; oft->u1.AddressOfData; oft++, ft++) {
      if (oft->u1.Ordinal & IMAGE_ORDINAL_FLAG) continue;
      auto byname = (PIMAGE_IMPORT_BY_NAME)(base + oft->u1.AddressOfData);
      void* hook = ResolveHook((const char*)byname->Name);
      if (hook) PatchThunk(ft, hook);
    }
  }
  // Delay imports
  auto& ddir =
      nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT];
  if (ddir.VirtualAddress && ddir.Size) {
    auto desc = (PIMAGE_DELAYLOAD_DESCRIPTOR)(base + ddir.VirtualAddress);
    for (; desc->DllNameRVA; desc++) {
      auto oft = (PIMAGE_THUNK_DATA)(base + desc->ImportNameTableRVA);
      auto ft = (PIMAGE_THUNK_DATA)(base + desc->ImportAddressTableRVA);
      if (!oft) continue;
      for (; oft->u1.AddressOfData; oft++, ft++) {
        if (oft->u1.Ordinal & IMAGE_ORDINAL_FLAG) continue;
        auto byname = (PIMAGE_IMPORT_BY_NAME)(base + oft->u1.AddressOfData);
        void* hook = ResolveHook((const char*)byname->Name);
        if (hook) PatchThunk(ft, hook);
      }
    }
  }
}

void InitOnce() {
  if (g_init) return;
  g_init = true;
  InitializeCriticalSection(&g_cs);
  InitWinmmStubs();
  g_kernel32 = GetModuleHandleW(L"kernel32.dll");
  g_ws2 = GetModuleHandleW(L"ws2_32.dll");
  if (g_kernel32) {
    real_CreateFileW =
        (PFN_CreateFileW)GetProcAddress(g_kernel32, "CreateFileW");
    real_CreateFile2 =
        (PFN_CreateFile2)GetProcAddress(g_kernel32, "CreateFile2");
    real_GetFileAttributesW = (PFN_GetFileAttributesW)GetProcAddress(
        g_kernel32, "GetFileAttributesW");
    real_GetFileAttributesExW = (PFN_GetFileAttributesExW)GetProcAddress(
        g_kernel32, "GetFileAttributesExW");
  }
  if (g_ws2) {
    real_GetAddrInfoW =
        (PFN_GetAddrInfoW)GetProcAddress(g_ws2, "GetAddrInfoW");
    real_GetAddrInfoExW =
        (PFN_GetAddrInfoExW)GetProcAddress(g_ws2, "GetAddrInfoExW");
    real_getaddrinfo =
        (PFN_getaddrinfo)GetProcAddress(g_ws2, "getaddrinfo");
    real_gethostbyname =
        (PFN_gethostbyname)GetProcAddress(g_ws2, "gethostbyname");
  }
  wchar_t self[32768];
  DWORD n = GetModuleFileNameW(g_hInst, self, 32768);
  if (n && n < 32768) {
    g_appDir = DirName(std::wstring(self, n));
    g_origAsar = FullPath(g_appDir + L"\\resources\\app.asar");
    g_patchRoot = EnvLocalAppData() + L"\\TyporaPatch";
    g_payloadPath = g_patchRoot + L"\\payload.js";
  }
  HookImportTable(GetModuleHandleW(nullptr));
}

}  // namespace

BOOL WINAPI DllMain(HMODULE hinst, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) {
    g_hInst = hinst;
    DisableThreadLibraryCalls(hinst);
    InitOnce();
  }
  return TRUE;
}
