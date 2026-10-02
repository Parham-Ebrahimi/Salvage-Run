from pathlib import Path
import shutil

root = Path('assets/ui-kits/Free Icon Pack 3.0.1 (Basic)')
picks = {'coin': ('Currency/Coin', 'Golden Coin 1st Outline 256px.png'), 'garage': ('Item/Hammer', 'Hammer 1st Outline 256px.png'), 'index': ('Item/Book', 'Book 1st Outline 256px.png'), 'inventory': ('Item/Backpack', 'Backpack 1st Outline 256px.png'), 'settings': ('Main/Settings', 'Settings 1st Outline 256px.png'), 'boost': ('Main/Lighting', 'Lighting 1st Outline 256px.png'), 'home': ('Main/House', 'House 1st Outline 256px.png')}
out = Path('assets/ui')
out.mkdir(exist_ok=True)
for i, (name, (folder, preferred)) in enumerate(picks.items()):
    files = list((root / folder).rglob(preferred))
    if not files:
        files = list((root / folder).rglob('*1st Outline 256px.png'))
    if not files:
        files = list((root / folder).rglob('*.png'))
    f = files[0]
    shutil.copyfile(f, out / (name + '.png'))
    print(f)
