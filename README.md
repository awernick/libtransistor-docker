# Libtransistor Docker
Docker development environment for the Nintendo Switch using libtransistor.
Huge shout out to @vgmoose and @reswitched since this Dockerfile is mostly theirs.
A few modifications where made to accomodate new requirements in the build processes
and a few other personal choices.

--------

## Build
```
docker build -t libtransistor_shell .
```

## Update / Refresh
```
docker build --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) . -t libtransistor_shell
```


## Usage
```
docker run -it libtransistor_shell
```

To share a folder from the host (e.g. directory for your source code):
```
docker run -v /ABSOLUTE/PATH/TO/SHAREDFOLDER:/MAPPED/PATH/IN/DOCKER -it libtransistor_shell
```





