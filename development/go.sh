rm forth.lst forth.sna
zasm -u forth.asm
fuse --no-confirm-actions -g 2x --debugger-command "br 0x8030" forth.sna
