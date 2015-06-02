FROM debian:latest

RUN apt-get update && true

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y iceweasel wget tar xz-utils openssh-server

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Create user "docker" and set the password to "docker"
RUN useradd -m -d /home/docker docker
RUN echo "docker:docker" | chpasswd

# Create OpenSSH privilege separation directory, enable X11Forwarding
RUN mkdir -p /var/run/sshd
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

# Prepare ssh config folder so we can upload SSH public key later
RUN mkdir /home/docker/.ssh
RUN chown -R docker:docker /home/docker
RUN chown -R docker:docker /home/docker/.ssh

ADD https://www.torproject.org/dist/torbrowser/4.5.1/tor-browser-linux64-4.5.1_en-US.tar.xz /home/docker/tor.tar.xz

RUN echo "b9a2ede538ac16765feb92fb057fc7ffb68d6ec2b60009306965fdd509e07259  tor.tar.xz" > /home/docker/tor.tar.xz.sha256sum

RUN cd /home/docker && sha256sum -c tor.tar.xz.sha256sum

RUN cd /home/docker && tar xJf /home/docker/tor.tar.xz

# RUN ln -s /home/docker/tor-browser_en-US/Browser/firefox /home/docker/tor

# USER docker

# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
