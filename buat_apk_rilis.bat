@echo off
chcp 65001 > nul
echo ===================================================
echo   [BuildHaus] Membuat File APK Rilis (Release)
echo ===================================================
echo.
echo Sedang mengkompilasi APK... Mohon tunggu sebentar...
call flutter build apk --release
if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUKSES] APK berhasil dibuat!
    copy /Y build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\buildhaus.apk > nul
    echo Lokasi file: build\app\outputs\flutter-apk\buildhaus.apk
) else (
    echo.
    echo [GAGAL] Terjadi kesalahan saat membuat APK.
)
echo.
pause
