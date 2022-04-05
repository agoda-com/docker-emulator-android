FROM ubuntu:18.04

ENV LINK_ANDROID_SDK=https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH="$PATH:/opt/android-sdk-linux/tools:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools/bin:/opt/android-sdk-linux/emulator"

RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq software-properties-common libstdc++6 zlib1g libncurses5 \
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
    yes | sdkmanager --no_https --licenses && \
    yes | sdkmanager emulator tools platform-tools "platforms;{{ platform }}" "system-images;{{ platform }};google_apis;x86_64" --verbose | uniq && \
    echo no | avdmanager create avd -n "Pixel2" --package "system-images;{{ platform }};google_apis;x86_64" --tag google_apis && \
    # Unfilter devices (now local because CI downloads from github are unstable)
    # curl -o /root/.android/adb_usb.ini https://raw.githubusercontent.com/apkudo/adbusbini/master/adb_usb.ini && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -yq unzip openjdk-8-jdk && \
    # Clean up
    apt-get -yq autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up insecure default key
COPY adbkey adbkey.pub adb_usb.ini /root/.android/

# Convert large partitions to qcow2 to save space
RUN qemu-img convert -O qcow2 -c ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/system.img ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/system.qcow2 \
     && mv ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/system.qcow2 ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/system.img \
     \
     && qemu-img convert -O qcow2 -c ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/userdata.img ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/userdata.qcow2 \
     && mv ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/userdata.qcow2 ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/userdata.img \
     \
     && qemu-img resize -f raw /root/.android/avd/Pixel2.avd/userdata.img 4096M \
     \
     && (qemu-img convert -O qcow2 -c ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/vendor.img ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/vendor.qcow2 \
     && mv ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/vendor.qcow2 ${ANDROID_HOME}/system-images/{{ platform }}/google_apis/x86_64/vendor.img || true)

COPY config.ini /root/.android/avd/Pixel2.avd/config.ini

# Expose adb
EXPOSE 5037 5554 5555 5900

# Add script
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
