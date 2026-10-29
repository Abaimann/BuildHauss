@echo off
chcp 65001 > nul
echo ===================================================
echo   [BuildHaus] Memasang (Install) APK ke Perangkat
echo ===================================================
echo.
if not exist "build\app\outputs\flutter-apk\buildhaus.apk" (
    echo File APK belum ditemukan. Sedang membuat file APK terlebih dahulu...
    call flutter build apk --release
    copy /Y build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\buildhaus.apk > nul
)

echo Memasang buildhaus.apk ke HP/Emulator...
adb install -r build\app\outputs\flutter-apk\buildhaus.apk
if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUKSES] Aplikasi berhasil dipasang di perangkat!
    echo Membuka aplikasi...
    adb shell am start -n com.buildhaus.buildhaus/.MainActivity
) else (
    echo.
    echo [GAGAL] Pastikan HP terhubung via kabel data dan USB Debugging aktif.
)
echo.
pause
