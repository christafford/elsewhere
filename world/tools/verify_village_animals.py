#!/usr/bin/env python3
"""Offline integrity and articulated-model contract, with no network fallback."""
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1] / 'art' / 'animals'


def verify(root=ROOT):
    manifest=json.loads((root/'manifest.json').read_text())
    assert {e['species'] for e in manifest['models']} == {'pig','chicken','dog','goat','cow'}
    for entry in manifest['models']:
        path=root/entry['file'];data=path.read_bytes()
        assert len(data)==entry['bytes'], f'{path}: size mismatch; rebuild assets'
        assert hashlib.sha256(data).hexdigest()==entry['sha256'], f'{path}: SHA-256 mismatch; rebuild assets'
        magic,version,size=struct.unpack_from('<4sII',data)
        assert (magic,version,size)==(b'glTF',2,len(data))
        count=struct.unpack_from('<I',data,12)[0];gltf=json.loads(data[20:20+count])
        names={n['name'] for n in gltf['nodes']}
        expected={'Body','Head','Tail'}|{f'{part}{i}' for part in ['Leg','Shin'] for i in range(2 if entry['species']=='chicken' else 4)}
        assert expected<=names, f'{path}: missing articulated joints'
        assert all('uri' not in b for b in gltf['buffers']), f'{path}: external buffer'
        assert not gltf.get('images'), f'{path}: unexpected texture dependency'
        assert entry['triangles']<=5000, f'{path}: model budget exceeded'
    return len(manifest['models'])


if __name__=='__main__':
    print(f'Verified {verify()} original village animals (offline)')
