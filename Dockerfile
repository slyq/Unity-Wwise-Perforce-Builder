FROM jenkins/jenkins:lts-jdk11

# elevate for apt installs
USER root

RUN apt update && apt upgrade -y
RUN apt install -y wget sudo vim

# register Perforce repo
RUN wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor | sudo tee /usr/share/keyrings/perforce.gpg
RUN echo 'deb [signed-by=/usr/share/keyrings/perforce.gpg] https://package.perforce.com/apt/ubuntu jammy release' > /etc/apt/sources.list.d/perforce.list
RUN apt update
RUN apt install -y helix-cli

# register Unity repo
RUN wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null
RUN sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
RUN apt update
RUN apt install -y unityhub

# install prerequisites to install Unity properly
RUN apt install -y ca-certificates libasound2 libc6-dev libcap2 libgconf-2-4 libglu1 libgtk-3-0 libncurses5 libnotify4 libnss3 libxtst6 libxss1 cpio lsb-release xvfb xz-utils
RUN apt install -y libstdc++6
RUN wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# disable Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# install Jenkins plugins - you can modify this as desired
# COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN jenkins-plugin-cli -f plugins.txt
RUN jenkins-plugin-cli --plugins build-timeout:latest configuration-as-code:latest email-ext:latest mailer:latest matrix-auth:latest p4:latest timestamper:latest

# add simple authentication for Jenkins
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY casc.yaml /var/jenkins_home/casc.yaml

# drop root permissions for safety
USER jenkins