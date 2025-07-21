FROM openjdk:21-bullseye

# Set environment variables
ENV ANDROID_HOME=/usr/local/android-sdk-linux
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
ENV ANDROID_VERSION=36
ENV ANDROID_BUILD_TOOLS_VERSION=36.0.0
ENV ANDROID_SDK_URL=https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip

# Step 1: Install Ruby from backports (includes Ruby >= 3)
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -y -t bullseye-backports ruby ruby-dev

# Step 2: Install base tools and Android SDK command line tools
RUN apt-get install -y curl unzip && \
    mkdir -p "$ANDROID_HOME/cmdline-tools" "$HOME/.android" && \
    cd "$ANDROID_HOME" && \
    curl -o sdk.zip $ANDROID_SDK_URL && \
    unzip sdk.zip -d cmdline-tools-temp && \
    mv cmdline-tools-temp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest" && \
    rm -rf sdk.zip cmdline-tools-temp

# Step 3: Accept licenses and install SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager --update && \
    sdkmanager \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "platforms;android-${ANDROID_VERSION}" \
        "platform-tools" \
        "extras;android;m2repository" \
        "extras;google;m2repository"

# Step 4: Install Fastlane and build tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        bundler \
        rake && \
    gem install fastlane && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean