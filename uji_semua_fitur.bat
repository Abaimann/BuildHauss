@echo off
chcp 65001 > nul
echo ===================================================
echo   [BuildHaus] Menjalankan Seluruh Pengujian Otomatis
echo ===================================================
echo.
flutter test
echo.
pause
