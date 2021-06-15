FROM ubuntu:18.04

ARG ANDROID_SDK_TOOLS='7302050'

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    ANDROID_SDK_ROOT=/opt \
    PATH="$PATH:/opt/cmdline-tools/tools/bin:/opt/platform-tools:/opt/emulator"

RUN dpkg --add-architecture i386 \
    && echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse" > /etc/apt/sources.list \
    && echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
            apt-transport-https \
            ca-certificates \
            curl \
            expect \
            fluxbox \
            iproute2 \
            libc6:i386 \
            libgcc1:i386 \
            libncurses5:i386 \
            libstdc++6:i386 \
            libtinfo5:i386 \
            libasound2 \
            libgl1 \
            libnss3 \
            libpulse0 \
            libxcomposite1 \
            libxcursor1 \
            libxi6 \
            locales \
            nano \
            openjdk-8-jdk \
            redir \
            software-properties-common \
            telnet \
            unzip \
            x11vnc \
            xvfb \
            zlib1g:i386 \
    && locale-gen en_US.UTF-8

# Set up insecure default key
COPY adbkey adbkey.pub adb_usb.ini /root/.android/

# Install Android SDK
RUN curl -L https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip > /tmp/android-sdk-linux.zip \
    && unzip -q /tmp/android-sdk-linux.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/ \
    && rm /tmp/android-sdk-linux.zip \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools \
    && rm -Rf ${ANDROID_SDK_ROOT}/emulator \
    \
    # Customized steps per specific platform
    && yes | sdkmanager --no_https --licenses \
    && sdkmanager emulator platform-tools --verbose \
        "platforms;{{ platform }}" \
        "system-images;{{ platform }};google_apis;x86" | uniq \
    && echo no | avdmanager create avd -n "x86" --package "system-images;{{ platform }};google_apis;x86" --tag google_apis \
    \
    # Clean up
    && apt-get purge -yq unzip openjdk-8-jdk \
    && apt-get -yq autoremove \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Convert large partitions to qcow2 to save space
RUN qemu-img convert -O qcow2 -c ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/system.img ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/system.qcow2 \
    && mv ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/system.qcow2 ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/system.img \
    \
    && qemu-img convert -O qcow2 -c ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/userdata.img ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/userdata.qcow2 \
    && mv ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/userdata.qcow2 ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/userdata.img \
    \
    && qemu-img resize -f raw /root/.android/avd/x86.avd/userdata.img 2048M \
    \
    && (qemu-img convert -O qcow2 -c ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/vendor.img ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/vendor.qcow2 \
    && mv ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/vendor.qcow2 ${ANDROID_SDK_ROOT}/system-images/{{ platform }}/google_apis/x86/vendor.img || true)

COPY config.ini /root/.android/avd/x86.avd/config.ini

# Expose adb
EXPOSE 5037 5554 5555 5900

# Add script
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
