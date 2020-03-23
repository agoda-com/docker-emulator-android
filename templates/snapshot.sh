#!/usr/bin/env bash

function save {
  local token=$(cat /root/.emulator_console_auth_token)
  expect -f /snapshot.expect $token
}

function clean_up {
    echo "Cleaning up"
    rm /tmp/.X1-lock

    kill $XVFB_PID
    exit
}

echo "Starting emulator"
trap clean_up SIGHUP SIGINT SIGTERM
export DISPLAY=:1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/android-sdk-linux/emulator/lib64/qt/lib:/opt/android-sdk-linux/emulator/lib64/libstdc++:/opt/android-sdk-linux/emulator/lib64:/opt/android-sdk-linux/emulator/lib64/gles_swiftshader
Xvfb :1 +extension GLX +extension RANDR +extension RENDER +extension XFIXES -screen 0 1024x768x24 &
XVFB_PID=$!

cd /opt/android-sdk-linux/emulator
LIBGL_DEBUG=verbose ./qemu/linux-x86_64/qemu-system-x86_64 -avd x86 -snapshot default -no-snapshot-save &
EMULATOR_PID=$!

adb wait-for-device

boot_completed=`adb -e shell getprop sys.boot_completed 2>&1`
timeout=0
until [ "X${boot_completed:0:1}" = "X1" ]; do
    sleep 1
    boot_completed=`adb shell getprop sys.boot_completed 2>&1 | head -n 1`
    echo "Read boot_completed property: <$boot_completed>"
    let "timeout += 1"
    if [ $timeout -gt 300 ]; then
         echo "Failed to start emulator"
         exit 1
    fi
done

sleep 5

save
adb emu kill

# Doesn't work: triggers cold boot
# qemu-img convert -O qcow2 -c /root/.android/avd/x86.avd/userdata-qemu.img /root/.android/avd/x86.avd/userdata-qemu.img_qcow2
# mv /root/.android/avd/x86.avd/userdata-qemu.img_qcow2 /root/.android/avd/x86.avd/userdata-qemu.img

# Moving adb binary away so that stopping adb server with delay will release the emulator and will make it available for external connections
mv /opt/android-sdk-linux/platform-tools/adb /opt/android-sdk-linux/platform-tools/_adb

echo "Great Scott!"
clean_up
