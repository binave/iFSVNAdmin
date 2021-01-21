#!/bin/bash
# commit 'bootstrap.sh' and 'subversion.conf' at Dockerfile

cd `dirname $0`;

sed -i ':1;N;$!b1;s@[0-9A-Za-z/+]\{76\}[[:space:]][^|]\+@'"`

    tar -czf - bootstrap.sh subversion.conf | base64 | awk '{print $0 " \\\\\\\\\\\\"}'

`"\n'@' ${0%/*}/Dockerfile

cd - >/dev/null
