@echo off

schtasks /Create /TN "OneDrive to QNAP Backup" ^
/TR "C:\Users\habr\Qsync\SOFTWARE\ONEDRIVE-BACKUP-SYNC\onedrive_to_qsync.bat" ^
/SC HOURLY ^
/MO 1 ^
/F
