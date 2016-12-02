# run torbrowser from within debian:stable
FROM debian:stable

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# tor version
# https://www.torproject.org/dist/torbrowser/5.0.4/tor-browser-linux64-5.0.4_en-US.tar.xz
ENV USER docker
ENV VER 6.0.7
ENV CHKSUM sha256sums-unsigned-build.txt
ENV PACKAGE tor-browser-linux64-${VER}_en-US.tar.xz
ENV GPG_KEY 0x4E2C6E8793298290
# ENV GPG_KEYSERVER keys.mozilla.org
ENV GPG_KEYSERVER x-hkp://pool.sks-keyservers.net
ENV GPG_FINGERPRINT "5242 013F 02AF C851 B1C7  36B8 7017 ADCE F65C 2036"
ENV SOURCE https://www.torproject.org/dist/torbrowser/${VER}/$PACKAGE
ENV SOURCE_ASC https://www.torproject.org/dist/torbrowser/${VER}/$PACKAGE.asc
ENV SOURCE_CHKSUM https://dist.torproject.org/torbrowser/${VER}/$CHKSUM
ENV SOURCE_CHKSUM_ASC https://dist.torproject.org/torbrowser/${VER}/$CHKSUM.asc

# update and upgrade
RUN apt-get update
RUN apt-get upgrade -y -qq

RUN apt-get install -y -qq iceweasel
RUN apt-get install -y -qq wget tar xz-utils
RUN apt-get install -y -qq openssh-server

# Create user "$USER" and set the password to "$USER"
RUN useradd -m -d /home/$USER $USER
RUN echo "$USER:$USER" | chpasswd

# Prepare ssh config folder so we can upload SSH public key later
RUN mkdir /home/$USER/.ssh
RUN chown -R $USER:$USER /home/$USER
RUN chown -R $USER:$USER /home/$USER/.ssh

# Create OpenSSH privilege separation directory, enable X11Forwarding
RUN mkdir -p /var/run/sshd
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

# Download package, check package against gpg and checksum
ENV USER $USER
WORKDIR /home/$USER
RUN wget $SOURCE
RUN wget $SOURCE_ASC
RUN wget $SOURCE_CHKSUM
RUN wget $SOURCE_CHKSUM_ASC

# RUN gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys 0x4E2C6E8793298290
# RUN gpg --keyserver $KEY_SERVER --recv-keys $GPG_KEY
RUN gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys 0x4E2C6E8793298290
# RUN gpg --fingerprint $GPG_KEY | grep "5242 013F 02AF C851 B1C7  36B8 7017 ADCE F65C 2036" # $GPG_FINGERPRINT
RUN gpg --verify $CHKSUM.asc
RUN gpg --verify $PACKAGE.asc

RUN sha256sum -c $CHKSUM 2>/dev/null | grep $PACKAGE

RUN tar xJf $PACKAGE
RUN ln -s /home/$USER/tor-browser_en-US/Browser/firefox /home/$USER/tor

# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
