## iF.SVNAdmin-docker (alpine)

Dockerfile for iF.SVNAdmin, buile on Alpine linux.

import:
* [iF.SVNAdmin](https://github.com/mfreiholz/iF.SVNAdmin)
* [alpine linux](https://alpinelinux.org/)


build

```sh

# auto build
./build.sh

# build
docker build --tag binave/svnadmin:1.6.2-alpine3.6.5 \
    --build-arg ALPINE_VERSION=3.6.5 \
    --build-arg REPO_MIRRORS_HOST=mirrors.tuna.tsinghua.edu.cn \
    --build-arg NETCAT_URL=http://${assets_url%.*}.1:$port \
    .

```

--build-arg|description|default value
:--:|--|--
ALPINE_VERSION|alpine-linux version|3.6.5
REPO_MIRRORS_HOST|apk source host|dl-cdn.alpinelinux.org
NETCAT_URL|iF.SVNAdmin package|https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.tar.gz
SRV_URI_PREFIX|admin url `prefix`|svnadmin
SVN_DATA_DIR|svn url `prefix` and repositories `path`|/svn

<br/>

Run

```sh

# China
[ -f /usr/share/zoneinfo/Asia/Shanghai ] && ln -fsv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
[ -f /etc/timezone ] || echo "Asia/Shanghai" > /etc/timezone

docker run --detach \
    --name ifsvn \
    --restart always \
    --publish 80:80 --publish 443:443 \
    --volume /opt/ifsvn:/svn \
    --volume /etc/timezone:/etc/timezone:ro \
    --volume /etc/localtime:/etc/localtime:ro \
    binave/svnadmin:1.6.2-alpine3.6.5

```
path (in containerd)|description
--|--
/var/www/localhost/htdocs|apache root
/opt/svnadmin/data/userroleassignments.ini|role data

<br/>

#### Administrator page:

http://127.0.0.1/svnadmin<br/>

user|password
--|--
admin|admin

<br/>

#### Checkout

```sh
# http method: OPTIONS
svn co http://127.0.0.1/svn
```
