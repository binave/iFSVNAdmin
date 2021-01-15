
ARG ALPINE_VERSION=3.5

FROM alpine:$ALPINE_VERSION

LABEL maintainer="binave <nidnil@icloud.com>"

ARG NETCAT_URL=https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.tar.gz
ARG REPO_MIRRORS_HOST=dl-cdn.alpinelinux.org

ARG SRV_URI_PREFIX=svnadmin
ARG SVN_DATA_DIR=/svn

RUN export SVN_PARENT_PATH=$SVN_DATA_DIR/repositories \
        SVN_PASSWORD_FILE=$SVN_DATA_DIR/conf/passwd \
        SVN_ACCESS_FILE=$SVN_DATA_DIR/conf/authz; \
    sed -i 's@^root::@root:!:@' /etc/shadow; \
    sed -i "s@dl-cdn.alpinelinux.org@$REPO_MIRRORS_HOST@g" /etc/apk/repositories; \
    apk update --no-cache || exit 1; \
:               \
:  iF.SVNAdmin  \
;               \
    apk add --no-cache --virtual .download curl tar && \
        mkdir -pv /opt/$SRV_URI_PREFIX && cd /opt/$SRV_URI_PREFIX && \
        curl $NETCAT_URL | tar -xzf - --strip=1 || exit 1; \
    apk del .download && \
    awk '!/^[#;]|^$/{if($1 ~ /^\[/){print "\n" $_} else print};END{print "\n"}' data/config.tpl.ini | \
        sed "s@^SVNAuthFile=@&$SVN_ACCESS_FILE@; \
    s@^SVNParentPath=@&$SVN_PARENT_PATH@; \
    s@^SvnExecutable=@&/usr/bin/svn@; \
    s@^SvnAdminExecutable=@&/usr/bin/svnadmin@; \
    s@^SVNUserFile=@&$SVN_PASSWORD_FILE@" > data/config.ini; \
:                                                               \
:   Fix: https://github.com/mfreiholz/iF.SVNAdmin/issues/118    \
;                                                               \
    sed -i ':1;N;$!b1;s@{.*return $check@{\n  return version_compare(PHP_VERSION, $minimumVersion)@' \
        /opt/$SRV_URI_PREFIX/classes/util/global.func.php || exit 1; \
:                \
:   install apk  \
;                \
    apk add --no-cache apache2 apache2-utils apache2-webdav mod_dav_svn && \
        apk add --no-cache subversion php7 php7-apache2 php7-session php7-json php7-ldap php7-xml || exit 1; \
	sed -i -e 's@^;\(extension=.*ldap\)@\1@' /etc/php7/php.ini && \
    mkdir -pv /run/apache2/ && cd /run/apache2/ && \
    printf "%s\n" \
H4sIAAAAAAAAA+3UW2/TMBQA4D77VxwGYhJSmt4jyKgU1hYmlbZKuvHQTpWbuEtEGgfbCdq0H4/T \
0DCYoE/lIs734vj4+NI6J2vOlVSCpnUZ1o6koVmWtWu1H9tGt2PVmh390Oo0u0W82Wq2OjVoHOtA \
D2VSUQFQE/qP+FXeofF/1NMn5jpKTBkSsv0YRAKMNIdn3tVkNXPc4WSum/m7MjBw5s5qcOGaPk82 \
NlE888N9qud9mLqD1ehiPLTJAgxZDjjn50PP24XhGu7vYUlAS0WUqA2cLm4Ez1J5vUyWycLUzQt4 \
DaLonUL/0Qo28UP+OQHDBZpSP2Svyub704GZU2HG/MYsR1s2ITJPJBM5A8MIKNtyvYax4YIV2yeB \
7hSX+/hXG0YcScUSI+VCQbv3sgHPidiCsQFTZMl+AzNUKg3qaRTYpAz5KgZjMJq6w7fu9HIysMmf \
vuafktk6Z0JGPKkX13qUPQ7Wf6Nda7Z1htXtdNtWUf+9XgPr/3cYcxq850EWMwhovtKVstqWXTOT \
uo6idfWa6/jqa05dcvJgJs1UeHdwbpVVzCZnY+5Tpd87MHWov/suDJwr0J3dsy7GGRUsUTOqwn1k \
rOvxWxSmZaqjF57fpgzeUBn5VWhCtwxOvOoFB5elXEaKi9uTKulSfxhGUcyqwJ3exvF9JmUVdtmn \
LBIMchpHgZHpGeTM3B+///fWNkIIIYQQQgghhBBCCCGEEEIIIYT+D18AH/jsdwAoAAA= \
| base64 -d | tar -xzvf - || exit 1; \
    sed -i "s@SVNParentPath@& $SVN_PARENT_PATH@; \
    s@AuthUserFile@& $SVN_PASSWORD_FILE@; \
    s@AuthzSVNAccessFile@& $SVN_ACCESS_FILE@" subversion.conf && \
    mv -v subversion.conf /etc/apache2/conf.d/ && \
    sed -i "s@\$SVN_DATA_DIR@$SVN_DATA_DIR@g; \
    s@\$SVN_PARENT_PATH@$SVN_PARENT_PATH@; \
    s@\$SVN_PASSWORD_FILE@$SVN_PASSWORD_FILE@; \
    s@\$SVN_ACCESS_FILE@$SVN_ACCESS_FILE@;" bootstrap.sh && \
    chmod +x bootstrap.sh && \
	ln -sv /opt/$SRV_URI_PREFIX /var/www/localhost/htdocs/$SRV_URI_PREFIX && \
	chown -R apache:apache /opt/$SRV_URI_PREFIX/data; \
:                \
:    timezone    \
;                \
    apk add --no-cache --virtual .tz tzdata || exit 1; \
    cp -fv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime || exit 1; \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del .tz

ENV HOME /home

EXPOSE 80 443 3690

VOLUME ["/var/log/apache2"]

ENTRYPOINT ["/run/apache2/bootstrap.sh"]
