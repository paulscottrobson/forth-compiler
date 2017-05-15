#
#	Scan forth.lst for words in the dictionary
#
import re
words = []
src = open("forth.lst").readlines()
for s in src:
	m = re.match("^([0-9A-F]+).*\<\<(.*)\>\>",s)
	if m is not None:
		words.append("{1}:=${0}".format(m.group(1).strip(),m.group(2).strip()))

words.sort()
print("Found {0} words".format(len(words)))
open("words.txt","w").write("\n".join(words))	