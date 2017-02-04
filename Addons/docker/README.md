# PassWebTool as Docker images
```
vi Dockerfile; docker build -t pwt . && docker run -p 80:80 -p 443:443 -i -t pwt /bin/bash
```
## prebuild
head over to https://hub.docker.com/r/maldex/pass_web_tool/

##. building your own image
- ensure you got docker installed
- clone and build
```
cd ~  # go home!
git clone https://github.com/maldex/PassWebTool.git PWT_docker_build
cd PWT_docker_build/Addons/docker/
docker build -t pass_web_tool .

docker run -p 80:80 -p 443:443 -i -t pass_web_tool /bin/bash
```

- get started with default kdb (not encouraged!!!)
```
docker run -v ~/pwtdata:/tmp/pwtdata -it pass_web_tool /bin/bash

cp -Rv /opt/PassWebTool/var/* /tmp/pwtdata/
exit # back to host-os

find ~/pwtdata/

# run definitly
docker run -p 80:80 -p 443:443 -v ~/pwtdata:/opt/PassWebTool/var pass_web_tool

tail -f ~/pwtdata/log/*
