"""Structural checks only. Runtime acceptance remains Roblox Studio playtests."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
project = json.loads((root / 'default.project.json').read_text(encoding='utf-8-sig'))
assert 'Baseplate' not in project['tree']['Workspace']
assert project['tree']['Workspace']['$properties']['StreamingEnabled']
required = ['RunService', 'VehicleService', 'StageService', 'CollectibleService', 'CargoService', 'BankingService', 'EnemyService', 'EconomyService', 'CollectionService', 'DisplayService', 'RarityService', 'DataService']
for name in required:
    assert (root / f'src/server/{name}.luau').exists(), name
for name in ['VehicleController', 'HUDController', 'UIKit', 'MenuController', 'EffectsController']:
    assert (root / f'src/client/{name}.luau').exists(), name
for p in (root / 'src').rglob('*.luau'):
    text = p.read_text(encoding='utf-8')
    assert 'Vector3.zero()' not in text, p
    assert 'loadstring' not in text, p
assert 'Bank' not in (root / 'src/server/init.server.luau').read_text().split('local function request')[1].split('ctx.Request.OnServerEvent')[0].replace('TradeUp', ''), 'Banking must have no request handler'
tree = ET.parse(root / 'build-check.rbxlx')
sources = [x.text or '' for x in tree.findall('.//*[@name="Source"]')]
assert len(sources) >= 20
print(f'PASS: scaffold, module split, no fake banking endpoint, {len(sources)} scripts bundled by Rojo. Luau runtime not tested by this script.')
