FROM ubuntu:18.04

MAINTAINER Anton Malinskiy "anton@malinskiy.com"

# Set up insecure default key
COPY adbkey adbkey.pub adb_usb.ini /root/.android/

ENV LINK_ANDROID_SDK=https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    ANDROID_HOME=/opt/android-sdk-linux \
    PATH="$PATH:/opt/android-sdk-linux/tools:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools/bin:/opt/android-sdk-linux/emulator"

RUN dpkg --add-architecture i386 && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq software-properties-common libstdc++6:i386 zlib1g:i386 libncurses5:i386 \
        locales ca-certificates apt-transport-https curl unzip redir iproute2 \
        openjdk-8-jdk xvfb x11vnc fluxbox nano telnet expect \
        libc6 libdbus-1-3 libfontconfig1 libgcc1 \
        libpulse0 libtinfo5 libx11-6 libxcb1 libxdamage1 \
        libnss3 libxcomposite1 libxcursor1 libxi6 \
        libxext6 libxfixes3 zlib1g libgl1 pulseaudio socat \
        --no-install-recommends && \
    locale-gen en_US.UTF-8 && \
    # Install Android SDK
    curl -L $LINK_ANDROID_SDK > /tmp/android-sdk-linux.zip && \
    unzip -q /tmp/android-sdk-linux.zip -d /opt/android-sdk-linux/ && \
    rm /tmp/android-sdk-linux.zip && \
    # Customized steps per specific platform
    yes | sdkmanager --no_https --licenses --sdk_root=${ANDROID_HOME} && \
    yes | sdkmanager --sdk_root=${ANDROID_HOME} emulator tools platform-tools "platforms;{{ platform }}" "system-images;{{ platform }};google_apis;x86" --verbose | uniq && \
    echo no | avdmanager create avd -n "Pixel2" --package "system-images;{{ platform }};google_apis;x86" --tag google_apis && \
    # Unfilter devices (now local because CI downloads from github are unstable)
    # curl -o /root/.android/adb_usb.ini https://raw.githubusercontent.com/apkudo/adbusbini/master/adb_usb.ini && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -yq unzip openjdk-8-jdk && \
    # Clean up
    apt-get -yq autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Convert large partitions to qcow2 to save space
# RUN qemu-img convert -O qcow2 -c /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.img /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.qcow2 && \
#     mv /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.qcow2 /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.img && \
#     qemu-img convert -O qcow2 -c /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.img /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.qcow2 && \
#     mv /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.qcow2 /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.img && \
#     qemu-img resize /root/.android/avd/Pixel2.avd/userdata.img 2G && \
#     resize2fs /root/.android/avd/Pixel2.avd/userdata.img && \
#     qemu-img convert -O qcow2 -c /root/.android/avd/Pixel2.avd/userdata.img /root/.android/avd/Pixel2.avd/userdata.qcow2 && \
#     mv /root/.android/avd/Pixel2.avd/userdata.qcow2 /root/.android/avd/Pixel2.avd/userdata.img && \
#     (qemu-img convert -O qcow2 -c /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.img /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.qcow2 && \
#     mv /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.qcow2 /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.img || true)

COPY config.ini /root/.android/avd/Pixel2.avd/config.ini

# Expose adb
EXPOSE 5037 5554 5555 5900

# Add script
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
