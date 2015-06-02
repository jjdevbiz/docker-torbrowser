# Tor Browser - Docker Project #

The purpose of this project is to provide an ephemeral image for anonymous web
browsing.

# Build from Dockerfile #

```
docker build -t torbrowser .
docker run -d -p 55556:22 torbrowser
```

## Start ##

*~/.ssh/config entry for easy ssh*
```
Host docker-tor
  User      docker
  Port      55556
  HostName  127.0.0.1
  RemoteForward 64713 localhost:4713
  ForwardX11 yes
```
*use a script or tmux line to start a session*
```
tmux new -s torbrowser -d "ssh docker-ff './tor'"
```
