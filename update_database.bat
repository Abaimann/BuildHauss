@echo off
chcp 65001 > nul
echo ===================================================
echo   [BuildHaus] Sinkronisasi & Generate Tabel Database
echo ===================================================
echo.
dart run build_runner build --delete-conflicting-outputs
echo.
pause
