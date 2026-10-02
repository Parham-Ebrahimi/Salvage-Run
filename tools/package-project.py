import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=json.loads((root/'default.project.json').read_text(encoding='utf-8-sig'))
t=p['tree']
t['ReplicatedStorage']['SalvageAssets']={'$path':'assets/snapshot/ReplicatedStorage/SalvageAssets'}
t['Workspace']['SalvageWorld']={'$path':'assets/snapshot/Workspace/SalvageWorld.rbxm'}
t['Workspace']['SpawnLocation']={'$path':'assets/snapshot/Workspace/SpawnLocation.rbxm'}
t['Workspace']['$attributes']={'__Rojo_ConnectionUrl':'http://localhost:34872'}
t['Lighting']['$path']='assets/snapshot/Lighting'
t['Lighting']['$properties']={'Ambient':[120/255,130/255,145/255],'OutdoorAmbient':[140/255,150/255,165/255],'Brightness':2,'GlobalShadows':True,'ClockTime':14}
(root/'default.project.json').write_text(json.dumps(p,indent=2)+'\n')
