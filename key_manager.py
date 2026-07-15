#!/usr/bin/env python3
"""إنشاء وتجديد مفاتيح التطبيق بمدة افتراضية 30 يومًا.

الاستخدام:
  export GITHUB_TOKEN='ضع التوكن هنا'
  export GIST_ID='c3271d0dced87c1e4e46ab073b885cbf'
  python key_manager.py create
  python key_manager.py renew XXXX-XXXX-XXXX
"""
import json, os, secrets, string, sys
from datetime import datetime, timedelta, timezone
from urllib.request import Request, urlopen

TOKEN = os.environ.get('GITHUB_TOKEN')
GIST_ID = os.environ.get('GIST_ID', 'c3271d0dced87c1e4e46ab073b885cbf')
FILE_NAME = 'keys.json'
DAYS = 30

if not TOKEN:
    raise SystemExit('❌ عيّن GITHUB_TOKEN أولاً في متغيرات البيئة.')


def api(method='GET', body=None):
    url = f'https://api.github.com/gists/{GIST_ID}'
    data = json.dumps(body).encode() if body is not None else None
    req = Request(url, data=data, method=method, headers={
        'Authorization': f'Bearer {TOKEN}',
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json',
        'X-GitHub-Api-Version': '2022-11-28',
    })
    with urlopen(req, timeout=15) as r:
        return json.load(r)


def load_data():
    gist = api()
    return json.loads(gist['files'][FILE_NAME]['content'])


def save_data(data):
    api('PATCH', {'files': {FILE_NAME: {'content': json.dumps(data, ensure_ascii=False, indent=2)}}})


def expiry():
    return (datetime.now(timezone.utc) + timedelta(days=DAYS)).isoformat()


def new_key():
    alphabet = string.ascii_uppercase + string.digits
    return '-'.join(''.join(secrets.choice(alphabet) for _ in range(4)) for _ in range(3))


def create():
    data = load_data(); keys = data.setdefault('keys', {})
    key = new_key()
    while key in keys: key = new_key()
    keys[key] = {'active': True, 'device_id': None, 'registered_at': None, 'expires_at': expiry()}
    save_data(data)
    print(f'✅ تم إنشاء المفتاح: {key}')
    print(f'⏳ الصلاحية: {DAYS} يوم')
    print(f"📅 ينتهي في: {keys[key]['expires_at']}")


def renew(key):
    data = load_data(); keys = data.setdefault('keys', {})
    if key not in keys: raise SystemExit('❌ المفتاح غير موجود')
    keys[key]['active'] = True
    keys[key]['expires_at'] = expiry()
    save_data(data)
    print(f'✅ تم تجديد {key} لمدة {DAYS} يومًا')

if __name__ == '__main__':
    cmd = sys.argv[1].lower() if len(sys.argv) > 1 else ''
    if cmd == 'create': create()
    elif cmd == 'renew' and len(sys.argv) > 2: renew(sys.argv[2].upper())
    else: print('الاستخدام: python key_manager.py create | python key_manager.py renew KEY')
