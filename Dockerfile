# run torbrowser from within debian:stable

FROM debian:stable

RUN apt-get update && true

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y iceweasel wget tar xz-utils openssh-server

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Create user "docker" and set the password to "docker"
RUN useradd -m -d /home/docker docker
RUN echo "docker:docker" | chpasswd

# Prepare ssh config folder so we can upload SSH public key later
RUN mkdir /home/docker/.ssh
RUN chown -R docker:docker /home/docker
RUN chown -R docker:docker /home/docker/.ssh

# Create OpenSSH privilege separation directory, enable X11Forwarding
RUN mkdir -p /var/run/sshd
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

WORKDIR /home/docker
ADD https://www.torproject.org/dist/torbrowser/4.5.2/tor-browser-linux64-4.5.2_en-US.tar.xz
ADD https://www.torproject.org/dist/torbrowser/4.5.2/tor-browser-linux64-4.5.2_en-US.tar.xz.asc

ADD https://dist.torproject.org/torbrowser/4.5.2/sha256sums-unsigned-build.txt
ADD https://dist.torproject.org/torbrowser/4.5.2/sha256sums-unsigned-build.txt.asc

RUN gpg --keyserver keys.mozilla.org --recv-keys 0x4E2C6E8793298290

RUN gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys 0x4E2C6E8793298290
RUN gpg --fingerprint 0x4E2C6E8793298290 | grep "EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290"

RUN gpg --verify /home/docker/sha256sums-unsigned-build.txt.asc
RUN gpg --verify /home/docker/tor-browser-linux64-4.5.2_en-US.tar.xz.asc

RUN grep tor-browser-linux64-4.5.2_en-US.tar.xz /home/docker/sha256sums-unsigned-build.txt > /home/docker/tor-browser-linux64-4.5.2_en-US.tar.xz.sha256sum
RUN sha256sum -c tor-browser-linux64-4.5.2_en-US.tar.xz.sha256sum

RUN tar xJf /home/docker/tor-browser-linux64-4.5.2_en-US.tar.xz

RUN ln -s /home/docker/tor-browser_en-US/Browser/firefox /home/docker/tor

# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
