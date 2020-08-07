FROM ubuntu:18.04

MAINTAINER Fahrudin "fahrudinjaya@gmail.com"

# Set up insecure default key
COPY adbkey adbkey.pub adb_usb.ini /root/.android/

ENV LINK_ANDROID_SDK=https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
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
                locales ca-certificates apt-transport-https curl wget unzip redir iproute2 \
                openjdk-8-jdk xvfb x11vnc fluxbox nano libpulse0 telnet expect libnss3-dev \
     			libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \ 
     			libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \ 
     			libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \ 
     			libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \ 
     			libnss3 \
                --no-install-recommends && \
    locale-gen en_US.UTF-8 && \
    # Install Android SDK
    curl -L $LINK_ANDROID_SDK > /tmp/android-sdk-linux.zip && \
    unzip -q /tmp/android-sdk-linux.zip -d /opt/android-sdk-linux/ && \
    rm /tmp/android-sdk-linux.zip && \
    # Customized steps per specific platform
    yes | sdkmanager --no_https --licenses && \
    yes | sdkmanager emulator tools platform-tools "platforms;{{ platform }}" "system-images;{{ platform }};google_apis;x86" --verbose | uniq && \
    echo no | avdmanager create avd -n "x86" --package "system-images;{{ platform }};google_apis;x86" --tag google_apis && \
    # Unfilter devices (now local because CI downloads from github are unstable)
    # curl -o /root/.android/adb_usb.ini https://raw.githubusercontent.com/apkudo/adbusbini/master/adb_usb.ini && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -yq unzip openjdk-8-jdk && \
    # Convert large partitions to qcow2 to save space
    qemu-img convert -O qcow2 -c /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.img /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.qcow2 && \
    mv /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.qcow2 /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/system.img && \
    qemu-img convert -O qcow2 -c /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.img /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.qcow2 && \
    mv /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.qcow2 /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/userdata.img && \
    qemu-img resize /root/.android/avd/x86.avd/userdata.img 2G && \
    e2fsck -fy /root/.android/avd/x86.avd/userdata.img && \
    resize2fs /root/.android/avd/x86.avd/userdata.img && \
    qemu-img convert -O qcow2 -c /root/.android/avd/x86.avd/userdata.img /root/.android/avd/x86.avd/userdata.qcow2 && \
    mv /root/.android/avd/x86.avd/userdata.qcow2 /root/.android/avd/x86.avd/userdata.img && \
    (qemu-img convert -O qcow2 -c /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.img /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.qcow2 && \
    mv /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.qcow2 /opt/android-sdk-linux/system-images/{{ platform }}/google_apis/x86/vendor.img || true) && \
    # Clean up
    apt-get -yq autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get install -yq unzip && \
    apt-get install -yq python-numpy && \
    apt-get install -yq net-tools
#=======
# noVNC
# Use same commit id that docker-selenium uses
# https://github.com/elgalu/docker-selenium/blob/236b861177bd2917d864e52291114b1f5e4540d7/Dockerfile#L412-L413
#=======
ENV NOVNC_SHA="b403cb92fb8de82d04f305b4f14fa978003890d7" \
    WEBSOCKIFY_SHA="558a6439f14b0d85a31145541745e25c255d576b"
RUN  wget -nv -O noVNC.zip "https://github.com/kanaka/noVNC/archive/${NOVNC_SHA}.zip" \
 && unzip -x noVNC.zip \
 && rm noVNC.zip  \
 && mv noVNC-${NOVNC_SHA} noVNC \
 && wget -nv -O websockify.zip "https://github.com/kanaka/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
 && unzip -x websockify.zip \
 && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
 && rm websockify.zip \
 && ln noVNC/vnc_auto.html noVNC/index.html

COPY config.ini /root/.android/avd/x86.avd/config.ini

# Expose adb
EXPOSE 5037 5554 5555 5900 6080

# Add script
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
