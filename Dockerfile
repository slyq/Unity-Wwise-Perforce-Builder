FROM jenkins/jenkins:lts-jdk17

ARG PASSWORD
ARG VERSION
ARG CHANGESET

# elevate for apt installs
USER root

# set root password if defined
RUN if test $PASSWORD; then echo "root:${PASSWORD}" | chpasswd && echo "Password set"; fi

RUN apt update && apt upgrade -y
RUN apt install -y wget sudo vim zip

# register Unity repo
RUN wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null
RUN sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
RUN apt update
RUN apt install -y unityhub

# install prerequisites to install Unity properly
RUN apt install -y ca-certificates libasound2 libc6-dev libcap2 libgconf-2-4 libglu1 libgtk-3-0 libncurses5 libnotify4 libnss3 libxtst6 libxss1 cpio lsb-release xvfb xz-utils
RUN apt install -y libstdc++6
RUN wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# drop root permissions for safety
USER jenkins

# install Unity and create activation file; modify modules as needed
# this only needs to be run once per volume - could comment this out in the future or just run this post-install instead
RUN xvfb-run unityhub --headless install --version $VERSION --changeset $CHANGESET -m mac-mono windows-mono --childmodules
WORKDIR /var/jenkins_home/Unity/Hub/Editor/"$VERSION"/Editor/
RUN ./Unity -batchmode -createManualActivationFile -logfile

# disable Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# install Jenkins plugins - you can modify this as desired
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# set up Jenkins job
COPY jobs /usr/share/jenkins/ref/jobs