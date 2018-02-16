# docker-emulator-android
docker-emulator-android is one of the components of [android-farm](https://github.com/agoda-com/android-farm). It runs android emulator with hardware acceleration in a container.

# Features
- Compatible with [OpenSTF](https://openstf.io)
- Optimized for performance
  - hardware acceleration using KVM
  - QEMU 2
- Changing emulator spec is supported by
  - overriding config.ini variables using `ANDROID_CONFIG`
  - overriding emulator cmd args using `EMULATOR_OPTS` and `QEMU_OPTS`
  - overriding adb ports using `CONSOLE_PORT (default 5554)`, `ADB_PORT (default 5555)`
- VNC server (port 5900)
- Google API's enabled

# Usage
For example to run default emulator options with Marshmallow (API 23):
```console
$ docker run --rm --privileged -e ANDROID_ARCH="x86" -v /dev/kvm:/dev/kvm agoda-com/docker-emulator-android-23:latest
$ adb connect VIP:5555
```

If you want to start different configuration of device, for example a 7 inch tablet, you need to override `config.ini` variables:

```console
$ docker run --rm --privileged -e ANDROID_ARCH="x86" -e ANDROID_CONFIG="skin.name=600x1024;hw.lcd.density=160;hw.lcd.height=600;hw.lcd.width=1024;hw.device.name=7in WSVGA (Tablet);avd.ini.displayname=7  WSVGA (Tablet) API 23;" -v /dev/kvm:/dev/kvm agoda-com/docker-emulator-android-23:latest
```

For all the options available please check the [official documentation](https://developer.android.com/studio/run/emulator-commandline.html)

# Building

```console
$ export DOCKER_USER=user
$ export DOCKER_PASS=password
$ make PROXY=docker-registry-url/ build tag login push
```

# License

docker-emulator-android is open source and available under the [Apache License, Version 2.0](LICENSE).

Android SDK components are available under the [Android Software Development Kit License](https://developer.android.com/studio/terms.html)
