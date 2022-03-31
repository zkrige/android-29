FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/32.0.0"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get update -yqq
RUN apt-get install -y curl expect git libc6 libgcc1 libncurses5 libstdc++6 zlib1g openjdk-11-jdk wget unzip vim ruby ruby-dev build-essential
RUN apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools
COPY licenses /opt/licenses
COPY rt.jar /usr/lib/jvm/java-11-openjdk-amd64/lib

WORKDIR /opt/android-sdk-linux
RUN chmod +x /opt/tools/android-sdk-update.sh
RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmdline-tools;latest"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "build-tools;32.0.0"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platform-tools"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platforms;android-32"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "system-images;android-32;google_apis;x86_64"

RUN gem install --no-document rubygems-update
RUN update_rubygems
RUN gem update --no-document --system 3.0.6
RUN gem install --no-document bundler
RUN gem install --no-document rake
RUN gem install --no-document fastlane
RUN gem install --no-document google-cloud-storage
RUN gem install --no-document fastlane-plugin-huawei_appgallery_connect


CMD /opt/tools/entrypoint.sh built-in
