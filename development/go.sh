rm forth.lst forth.sna
zasm -u forth.asm
python scanner.py
fuse --no-confirm-actions -g 2x --debugger-command "br 0xE12E" forth.sna
