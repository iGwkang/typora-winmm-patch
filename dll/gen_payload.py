#!/usr/bin/env python3
"""Regenerate dll/payload_js.h from src/payload.js."""
import pathlib
root = pathlib.Path(__file__).resolve().parent.parent
data = (root / 'src' / 'payload.js').read_bytes()
out = root / 'dll' / 'payload_js.h'
with out.open('w', encoding='ascii', newline='\n') as f:
    f.write('// Auto-generated from src/payload.js by dll/gen_payload.py\n#pragma once\n')
    f.write('static const unsigned char kPayloadJs[] = {\n')
    for i in range(0, len(data), 16):
        f.write('  ' + ','.join(str(b) for b in data[i:i+16]) + ',\n')
    f.write('};\nstatic const unsigned int kPayloadJsLen = %d;\n' % len(data))
print('wrote', out, len(data), 'bytes')
