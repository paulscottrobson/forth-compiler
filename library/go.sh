zasm -u library.asm
python buildlibrary.py
zasm -u include_lib.asm
diff -b include_lib.rom library.rom 
rm *.rom	
#cat library.lst
