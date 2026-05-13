@echo off

robocopy "C:\Users\habr\OneDrive - XXX\#WORK#" "C:\Users\habr\Qsync\ONEDRIVE_XXX_BACKUP\#WORK#" ^
/MIR /L ^
/XD "C:\Users\habr\OneDrive - XXX\#WORK#\BARRACUDA\ISO_BAR_USB-DRIVE" ^
/XF *.tmp desktop.ini "~$*" ^
/FFT /Z ^
/R:2 /W:5 ^
/MT:16 ^
/LOG:C:\Users\habr\Qsync\SOFTWARE\ONEDRIVE-BACKUP-SYNC\onedrive_backup.log
