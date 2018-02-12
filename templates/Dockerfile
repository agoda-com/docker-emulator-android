FROM ubuntu:16.04

MAINTAINER Anton Malinskiy "anton@malinskiy.com"

# Set up insecure default key
ADD adbkey adbkey.pub adb_usb.ini /root/.android/

ENV LINK_ANDROID_SDK=https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    ANDROID_HOME=/opt/android-sdk-linux \
    PATH="$PATH:/opt/android-sdk-linux/tools:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools/bin:/opt/android-sdk-linux/emulator"


RUN dpkg --add-architecture i386 && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq software-properties-common libstdc++6:i386 zlib1g:i386 libncurses5:i386 \
                        locales ca-certificates apt-transport-https curl unzip redir iproute2 \
                        openjdk-8-jdk xvfb x11vnc fluxbox nano libpulse0 \
                        --no-install-recommends && \
    locale-gen en_US.UTF-8 && \

    # Install Android SDK
    curl -L $LINK_ANDROID_SDK > /tmp/android-sdk-linux.zip && \
    unzip /tmp/android-sdk-linux.zip -d /opt/android-sdk-linux/ && \
    rm /tmp/android-sdk-linux.zip && \

    # Customized steps per specific platform
    yes | sdkmanager --no_https --licenses && \
    sdkmanager --no_https emulator tools platform-tools "platforms;{{ .Env.PLATFORM }}" "system-images;{{ .Env.PLATFORM }};google_apis;x86" --verbose && \
    echo no | avdmanager create avd -n "x86" --package "system-images;{{ .Env.PLATFORM }};google_apis;x86" --tag google_apis && \
    # Unfilter devices (now local because CI downloads from github are unstable)
    # curl -o /root/.android/adb_usb.ini https://raw.githubusercontent.com/apkudo/adbusbini/master/adb_usb.ini && \

    # Optimize size of the image
    rm /root/.android/avd/x86.avd/userdata.img && \
    tar -czvf /opt/android-sdk-linux/system-images/{{ .Env.PLATFORM }}/google_apis/x86/userdata.img.tar.gz /opt/android-sdk-linux/system-images/{{ .Env.PLATFORM }}/google_apis/x86/userdata.img && \
    rm /opt/android-sdk-linux/system-images/{{ .Env.PLATFORM }}/google_apis/x86/userdata.img && \
    tar -czvf /opt/android-sdk-linux/system-images/{{ .Env.PLATFORM }}/google_apis/x86/system.img.tar.gz /opt/android-sdk-linux/system-images/{{ .Env.PLATFORM }}/google_apis/x86/system.img && \
    rm /opt/android-sdk-linux/system-images/{{ .Env.PLATFORM }}/google_apis/x86/system.img && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -yq unzip openjdk-8-jdk && \

    apt-get -yq autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD config.ini /root/.android/avd/x86.avd/config.ini

# Expose adb
EXPOSE 5037 5554 5555

# Add script
ADD start.sh /start.sh
RUN chmod +x /start.sh
CMD /start.sh
