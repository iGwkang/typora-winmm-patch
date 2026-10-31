/* Typora offline activation + telemetry blocker.
 * Runs inside the Electron main process before the original main script.
 * No user data or registry values are permanently modified.
 */
(function () {
  'use strict';
  var Module = require('module');
  var crypto = require('crypto');
  var path = require('path');
  var fs = require('fs');

  var LICENSE = 'ABCDEF-GHJKMNP-QRSTUV-WXYZ23';
  var EMAIL = 'patched@localhost';
  var origCreateHash = crypto.createHash;

  function typoraKey(p) { return typeof p === 'string' && /Software\\Typora/i.test(p); }
  function allowedHost(h) {
    h = String(h || '').toLowerCase().replace(/\.$/, '');
    if (!h) return false;
    if (h === 'dict.typora.io' || h === 'support.typora.io') return false;
    if (h === 'typora.io' || /\.typora\.io$/.test(h)) return true;
    if (h === 'typoraio.cn' || /\.typoraio\.cn$/.test(h)) return true;
    if (h === 'typora.com.cn' || /\.typora\.com\.cn$/.test(h)) return true;
    return false;
  }
  function nodeHost(o) {
    try {
      if (typeof o === 'string') return new URL(o).hostname;
      if (o && typeof o === 'object') return o.hostname || o.host || (o.href ? new URL(o.href).hostname : '');
    } catch (e) {}
    return '';
  }
  function blockedError(host) {
    var e = new Error('blocked by local patch: ' + host);
    e.code = 'ENOTFOUND';
    return e;
  }

  // ---- machine fingerprint: sha256(MachineGuid + "typora") base64, [/=+-] -> a, first 10 ----
  var machineGuid = null;
  var fingerprint = null;
  function fpFromDigest(out) {
    return out.toString('base64').replace(/[/=+-]/g, 'a').slice(0, 10);
  }
  function computeFingerprint() {
    if (fingerprint) return fingerprint;
    if (machineGuid) {
      try { fingerprint = fpFromDigest(origCreateHash('sha256').update(machineGuid).update('typora').digest()); } catch (e) {}
    }
    return fingerprint || '';
  }

  crypto.createHash = function (algo) {
    var h = origCreateHash.apply(this, arguments);
    if (String(algo).toLowerCase() === 'sha256') {
      var u = h.update.bind(h), d = h.digest.bind(h), acc = '';
      h.update = function (x) {
        try { acc += (typeof x === 'string' ? x : Buffer.from(x).toString('latin1')); } catch (e) {}
        return u.apply(null, arguments);
      };
      h.digest = function () {
        var out = d.apply(null, arguments);
        try { if (/^[0-9a-f-]{36}typora$/i.test(acc)) fingerprint = fpFromDigest(out); } catch (e) {}
        return out;
      };
    }
    return h;
  };

  // ---- pretend a valid locally stored license exists and return signed-looking data ----
  var origPublicDecrypt = crypto.publicDecrypt;
  crypto.publicDecrypt = function (key, buf) {
    try {
      if (typeof key === 'string' && key.indexOf('BEGIN PUBLIC KEY') !== -1) {
        var fp = computeFingerprint();
        return Buffer.from(JSON.stringify({
          fingerprint: fp,
          license: LICENSE,
          email: EMAIL,
          type: 'full',
          deviceId: fp,
          lastRetry: null
        }), 'utf8');
      }
    } catch (e) {}
    return origPublicDecrypt.apply(this, arguments);
  };

  function token() {
    return LICENSE + '#0#' + new Date().toLocaleDateString('en-US');
  }

  // ---- native-reg: synthesize SLicense, capture MachineGuid, shadow all writes to Software\Typora ----
  var keyPaths = new Map();
  var shadow = Object.create(null);
  var regWrappers = new WeakMap();
  function lastStringArg(args) {
    for (var i = args.length - 1; i >= 1; i--) if (typeof args[i] === 'string') return args[i];
    return null;
  }
  function wrapReg(exp) {
    var w = regWrappers.get(exp);
    if (w) return w;
    w = Object.create(exp);
    regWrappers.set(exp, w);
    ['openKey', 'createKey', 'openCurrentUser'].forEach(function (name) {
      var o = exp[name];
      if (typeof o !== 'function') return;
      w[name] = function () {
        var r = o.apply(exp, arguments);
        try { if (arguments[1] != null) keyPaths.set(r, String(arguments[1])); } catch (e) {}
        return r;
      };
    });
    ['getValue', 'getValueRaw', 'queryValue', 'queryValueRaw'].forEach(function (name) {
      var o = exp[name];
      if (typeof o !== 'function') return;
      w[name] = function (key) {
        var kp = keyPaths.get(key) || '';
        var vn = lastStringArg(arguments);
        if (typoraKey(kp)) {
          if (vn === 'SLicense') return token();
          if (vn != null && shadow[vn] !== undefined) return shadow[vn];
        }
        var r = o.apply(exp, arguments);
        try { if (vn === 'MachineGuid' && typeof r === 'string') machineGuid = r; } catch (e) {}
        return r;
      };
    });
    ['setValueRaw', 'setValueSZ', 'setValueEXPAND_SZ', 'setValueMULTI_SZ', 'setValueDWORD', 'setValueQWORD', 'put', 'deleteValue', 'deleteKeyValue'].forEach(function (name) {
      var o = exp[name];
      if (typeof o !== 'function') return;
      w[name] = function (key, vn, value) {
        var kp = keyPaths.get(key) || '';
        if (typoraKey(kp)) {
          var nm = typeof vn === 'string' ? vn : lastStringArg(arguments);
          if (name === 'deleteValue' || name === 'deleteKeyValue') { if (nm) delete shadow[nm]; }
          else if (nm) shadow[nm] = value;
          return;
        }
        return o.apply(exp, arguments);
      };
    });
    return w;
  }

  // ---- force the renderer license flag as a safety net on any Typora version ----
  function wrapWebContents(wc) {
    if (!wc || wc.__reaLicenseWrapped) return;
    wc.__reaLicenseWrapped = true;
    var orig = wc.executeJavaScript;
    if (typeof orig !== 'function') return;
    wc.executeJavaScript = function (code) {
      if (typeof code === 'string' && /File\.option\.hasLicense\s*=\s*false/.test(code)) {
        code = 'if(window.File&&File.option){File.option.hasLicense=true;File.megaMenu&&File.megaMenu.forceReload();}';
      }
      return orig.apply(wc, arguments);
    };
  }

  // ---- module hooks ----
  var origLoad = Module._load;
  Module._load = function (request, parent, isMain) {
    var exp = origLoad.apply(this, arguments);
    try {
      if (request === 'native-reg' && exp && typeof exp === 'object') return wrapReg(exp);
      if (request === 'electron' && exp && !exp.__reaElectronHooked) {
        exp.__reaElectronHooked = true;
        var app = exp.app;
        if (!app.__reaQuitHooked) {
          app.__reaQuitHooked = true;
          var oq = app.quit.bind(app), oe = app.exit.bind(app);
          function integrityQuit() {
            try {
              var st = new Error().stack || '';
              return /Timeout\._onTimeout/.test(st) && /atom\.compiled\.dist\.jsc/.test(st);
            } catch (e) { return false; }
          }
          app.quit = function () { if (integrityQuit()) return; return oq.apply(app, arguments); };
          app.exit = function () { if (integrityQuit()) return; return oe.apply(app, arguments); };
          var oexit = process.exit.bind(process);
          process.exit = function () { if (integrityQuit()) return; return oexit.apply(process, arguments); };
        }
        app.on('web-contents-created', function (e, wc) { wrapWebContents(wc); });
        if (app.whenReady) {
          app.whenReady().then(function () {
            try { exp.webContents.getAllWebContents().forEach(wrapWebContents); } catch (e) {}
            try {
              exp.session.defaultSession.webRequest.onBeforeRequest(function (details, cb) {
                var u = '';
                try { u = new URL(details.url).hostname; } catch (e) {}
                cb({ cancel: allowedHost(u) });
              });
            } catch (e) {}
          });
        }
      }
    } catch (e) {}
    return exp;
  };

  // ---- Chromium-side name blocking (in addition to webRequest) ----
  try {
    var electron = require('electron');
    var rules = ['store.typora.io', 'typora.io', 'www.typora.io', 'typoraio.cn', 'www.typoraio.cn',
      'store.typoraio.cn', 'dian.typora.com.cn', 'downloads.typora.io', 'downloads.typoraio.cn']
      .map(function (h) { return 'MAP ' + h + ' 127.0.0.1'; }).join(', ');
    electron.app.commandLine.appendSwitch('host-resolver-rules', rules);
  } catch (e) {}

  // ---- Node-side blocking ----
  try {
    var EventEmitter = require('events').EventEmitter;
    function fakeRequest(host) {
      var req = new EventEmitter();
      req.setHeader = req.removeHeader = req.abort = req.destroy = function () {};
      req.getHeader = function () { return undefined; };
      req.write = req.end = function () {
        process.nextTick(function () { req.emit('error', blockedError(host)); });
        return true;
      };
      req.once = EventEmitter.prototype.once;
      return req;
    }
    ['http', 'https'].forEach(function (m) {
      var mod = require(m);
      ['request', 'get'].forEach(function (fn) {
        var o = mod[fn];
        if (typeof o !== 'function') return;
        mod[fn] = function () {
          var h = nodeHost(arguments[0]);
          if (allowedHost(h)) return fakeRequest(h);
          return o.apply(this, arguments);
        };
      });
    });
    var dns = require('dns');
    ['lookup', 'resolve', 'resolve4', 'resolve6', 'resolveAny'].forEach(function (fn) {
      var o = dns[fn];
      if (typeof o !== 'function') return;
      dns[fn] = function (hostname) {
        if (allowedHost(hostname)) {
          var cb = arguments[arguments.length - 1];
          if (typeof cb === 'function') process.nextTick(function () { cb(blockedError(hostname)); });
          return {};
        }
        return o.apply(this, arguments);
      };
    });
  } catch (e) {}

  try {
    var origFetch = globalThis.fetch;
    if (typeof origFetch === 'function') {
      globalThis.fetch = function (input) {
        var h = nodeHost(input);
        if (allowedHost(h)) return Promise.reject(blockedError(h));
        return origFetch.apply(this, arguments);
      };
    }
  } catch (e) {}
})();
