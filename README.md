## iF.SVNAdmin-docker (alpine)

Dockerfile for iF.SVNAdmin, buile on Alpine linux.

import:
* [iF.SVNAdmin](https://github.com/mfreiholz/iF.SVNAdmin)
* [alpine linux](https://alpinelinux.org/)


build

```sh

# auto build
./build.sh

```

run

```sh
docker run --detach \
    --name ifsvn \
    --restart always \
    --publish 80:80 --publish 443:443 --publish 3690:3690 \
    --volume /opt/ifsvn:/svn \
    binave/svnadmin:1.6.2-alpine3.6.5

```

http://127.0.0.1/svnadmin<br/>
admin<br/>
admin


```sh
svn co http://127.0.0.1/svn
```


