zasm -u library.asm
python buildlibrary.py
zasm -u include_lib.asm
rm *.rom	
#cat library.lst
