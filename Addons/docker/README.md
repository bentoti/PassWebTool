# PassWebTool as Docker images
```
vi Dockerfile; docker build -t pwt . && docker run -p 80:80 -p 443:443 -i -t pwt /bin/bash
```
## prebuild
head over to https://hub.docker.com/r/maldex/pass_web_tool/

##. building your own image
- ensure you got docker installed
```
# for CentOS
echo "[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg" > /etc/yum.repos.d/docker.repo
 
yum install -y docker-engine
systemctl enable docker; systemctl start docker
```
- clone and build
```
cd ~  # go home!
git clone https://github.com/maldex/PassWebTool.git PWT_docker_build
cd PWT_docker_build/Addons/docker/
docker build -t pass_web_tool .

docker run -p 80:80 -p 443:443 -i -t pass_web_tool /bin/bash
```
