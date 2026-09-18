from __future__ import annotations
import argparse, json
from pathlib import Path
from uuid import UUID

def users_from_state(path: Path) -> list[dict]:
    try: links=json.loads(path.read_text(encoding='utf-8')).get('links', {})
    except (OSError, ValueError, AttributeError): return []
    out=[]
    for uid, link in links.items():
        if not isinstance(link, dict) or link.get('protocol') != 'vless-httpupgrade' or not link.get('active', True): continue
        try: out.append({'id': str(UUID(str(uid))), 'email': f'lumen-{uid}'})
        except (ValueError, TypeError, AttributeError): pass
    return out

def config(users: list[dict], path='/hup') -> dict:
    return {'log':{'loglevel':'warning'},'inbounds':[{'tag':'lumen-httpupgrade','listen':'127.0.0.1','port':10000,'protocol':'vless','settings':{'clients':users,'decryption':'none'},'streamSettings':{'network':'httpupgrade','security':'none','httpupgradeSettings':{'path':path,'host':[]}}}],'outbounds':[{'protocol':'freedom','tag':'direct'},{'protocol':'blackhole','tag':'block'}]}
if __name__ == '__main__':
    p=argparse.ArgumentParser(); p.add_argument('--state',default='/data/code_state.json'); p.add_argument('--output',default='/data/xray-httpupgrade.json'); p.add_argument('--path',default='/hup'); a=p.parse_args(); target=Path(a.output); target.parent.mkdir(parents=True,exist_ok=True); target.write_text(json.dumps(config(users_from_state(Path(a.state)),a.path),separators=(',',':')),encoding='utf-8')
