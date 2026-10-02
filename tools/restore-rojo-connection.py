import json
from pathlib import Path
path=Path(r'C:/Users/Parham Ebrahimi/AppData/Local/Roblox/1752636068/InstalledPlugins/0/settings.json')
data=json.loads(path.read_text())
Path('tools/plugin-settings-backup.json').write_text(json.dumps({k:data.get(k) for k in ['Rojo_autoReconnect','Rojo_autoConnectPlaytestServer','Rojo_confirmationBehavior']}))
data['Rojo_autoReconnect']=True
data['Rojo_autoConnectPlaytestServer']=True
path.write_text(json.dumps(data))
