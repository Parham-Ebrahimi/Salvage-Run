from pathlib import Path
import struct, sys
sys.path.insert(0,str(Path(__file__).parent / '.deps'))
import lz4.block

data=Path(sys.argv[1]).read_bytes()
pos=32
out=Path('tools/rojo-inspect')
out.mkdir(exist_ok=True)
names={}
sources={}
def string(buf, pos):
    size=struct.unpack_from('<I',buf,pos)[0]
    return buf[pos+4:pos+4+size],pos+4+size
while pos+16<=len(data):
    tag=data[pos:pos+4]; compressed,size,reserved=struct.unpack_from('<III',data,pos+4);pos+=16
    chunk=data[pos:pos+(compressed or size)];pos+=(compressed or size)
    if compressed: chunk=lz4.block.decompress(chunk,uncompressed_size=size)
    if tag==b'PROP':
        cls=struct.unpack_from('<I',chunk)[0];prop,cpos=string(chunk,4);typ=chunk[cpos];cpos+=1
        if prop in (b'Name',b'Source') and typ==1:
            vals=[]
            while cpos<len(chunk):
                value,cpos=string(chunk,cpos);vals.append(value.decode('utf-8',errors='replace'))
            if prop==b'Name':names[cls]=vals
            if prop==b'Source':sources[cls]=vals
    if tag==b'END\x00':break
for cls,rows in sources.items():
 for i,source in enumerate(rows):
    name=names[cls][i] if i<len(names[cls]) else str(i)
    if name=='ignorePlaceIds' or any(term in source for term in ['autoConnect','AutoConnect','Reconnect','GetSetting','connectButton','connect =','function App:startSession']):
        dest=out/(str(i)+'-'+name.replace('/','_')+'.luau');dest.write_text(source,encoding='utf-8');print(dest)
