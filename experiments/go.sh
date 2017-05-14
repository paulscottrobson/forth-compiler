rm hello.lst hello.sna
zasm -u hello.asm
fuse --no-confirm-actions -g 2x --debugger-command "br 0x8000" hello.sna
