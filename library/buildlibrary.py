# *****************************************************************************************
#
#									Library builder
#
# *****************************************************************************************
import re
#
#						Get the files that make up the library.
#
libout = [x.strip() for x in open("library.asm").readlines() if x.find("include") >= 0]
libFiles = [x.replace("include","").replace('"',"").strip() for x in libout]
libFiles.insert(0,'library.asm')
#
#				   Create the complete library file as a single file.
#
hLib = open("include_lib.asm","w")
for f in libFiles:
	libSrc = [x.rstrip() for x in open(f).readlines() if x.find("include") < 0]
	hLib.write("\n".join(libSrc))
hLib.close()
#
#		Get the library.list file and look for [[]]
#
libList = [x.strip() for x in open("library.lst").readlines()]
libList = [x for x in libList if x.find("[[") >= 0 and x.find("]]") >= 0 ]
#
libList = [x for x in libList if x.find("[[#value]]") < 0]
#
#		Get the addresses, divide by four to make commands.
#
library = {}
for l in libList:
	m = re.match("^([0-9A-F]+).*\;\s*\[\[(.*)\]\]$",l)
	assert m is not None,"Bad line "+l
	word = m.group(2).lower().strip()
	address = int(m.group(1),16)
	assert word not in library,"Duplicate "+l
	assert address % 4 == 0,"Not at 4 offset "+l
	library[word] = int((address & 0x7FFF) / 4)

keys = [x for x in library.keys()]
keys.sort()
#
#		Write out codes file.
#
hCodes = open("include_lib.codes","w")
hCodes.write("\n".join(["{0}:={1}".format(library[x],x) for x in keys]))
hCodes.close()
print("Core word set : "+" ".join(keys))