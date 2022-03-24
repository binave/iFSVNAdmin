
ARG ALPINE_VERSION=3.6.5

FROM alpine:$ALPINE_VERSION

LABEL maintainer="binave <nidnil@icloud.com>"

ARG NETCAT_URL=https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.tar.gz
ARG REPO_MIRRORS_HOST=dl-cdn.alpinelinux.org

ARG SRV_URI_PREFIX=svnadmin
ARG SVN_DATA_DIR=/svn

RUN set -e; \
    export SVN_PARENT_PATH=$SVN_DATA_DIR/repositories \
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
    sed -i 's@^\(ErrorLog \).*@\1/proc/self/fd/2@; \
    s@#\(CustomLog \).*\( common\)$@\1/proc/self/fd/1\2@; \
    s@CustomLog.*combined$@#&@' /etc/apache2/httpd.conf; \
:                     \
:   decompress file   \
;                     \
    mkdir -pv /run/apache2/ && cd /run/apache2/ && \
    printf "%s\n" \
H4sIAAAAAAAAA+3TT2/aMBQAcM7+FG+sWk8mJm1hG1W1rMBWiUEVaHdoK2QS00QDO7OdbK364edA \
ybpVGqfun97v4vj5OXZiv5lS1ljNs4ZJak+EOe12e9U6P7fsYJ/VmvuM+X67ub/n11jTb/qtGrCn \
2tBDubFcA9S0+xG/yts2/o96/sybpdIzCTHCAhUdsvwUpxpoVsDO+Hw4PQ3C3nDimsn7daAbTIJp \
9yT0IiXnHWJVHiWb1PH44yjsTvsng16HXAA164Hg+Lg3Hq/CcAV3d5DpVNo57F5ca5Vn5upSXspd \
OHqU3SFRor5IoCHwjEeJeL1uftwJeAXX3kJde+tRv0OIKaQRuhBAaczFUrl30LnSolxQxq5Tnufj \
L6R0kRorJM2UtrDXesXgBSF6CXQOns7lZgUvsTaLG1kad4j4KiJY9YF2+6Ow9y4cnQ27UN95Uyd/ \
+ny3MfmsENqkSjbK83ySNbbWv39f/4w1WYuV9d9iB1j/v8NA8fiDivOFgJgXU1c20+W66+XGFVU6 \
q668i0/vcxpGkQczeW6T261zq6xytiu8MyPOJv2XMJLkcKAibt0lBM+NHxFwusE5uM7q2WWfci2k \
PeU22UQGrlK/R8vXlAOBW2Vykwl4y00aVaEhXwqoj6vbDqHIlEmt0jf1KsntSPfThagCt26ZIIqE \
MVU4FJ/zVAso+CKNae5mkENvs/2jv77eEUIIIYQQQgghhBBCCCGEEEIIIfT/+QYa6cAlACgAAA== \
| base64 -d | tar -xzvf - || exit 1; \
    sed -i "s@SVNParentPath@& $SVN_PARENT_PATH@; \
    s@AuthUserFile@& $SVN_PASSWORD_FILE@; \
    s@AuthzSVNAccessFile@& $SVN_ACCESS_FILE@; \
    s@\(Location \).*\(>\)@\1$SVN_DATA_DIR\2@" subversion.conf && \
    chmod 644 subversion.conf && \
    mv -v subversion.conf /etc/apache2/conf.d/ && \
    sed -i "s@\$SVN_DATA_DIR@$SVN_DATA_DIR@g; \
    s@\$SVN_PARENT_PATH@$SVN_PARENT_PATH@g; \
    s@\$SVN_PASSWORD_FILE@$SVN_PASSWORD_FILE@g; \
    s@\$SVN_ACCESS_FILE@$SVN_ACCESS_FILE@g;" bootstrap.sh && \
    chmod +x bootstrap.sh && \
	ln -sv /opt/$SRV_URI_PREFIX /var/www/localhost/htdocs/$SRV_URI_PREFIX && \
    sed -i 's@^\(Repository\(Delete\|Dump\)Enabled=\).*@\1true@' /opt/$SRV_URI_PREFIX/data/config.ini && \
	chown -R apache:apache /opt/$SRV_URI_PREFIX/data; \
:                \
:    timezone    \
;                \
    apk add --no-cache --virtual .tz tzdata || exit 1; \
    cp -fv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime || exit 1; \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del .tz

ENV HOME /home

ENV PS1='\u@\h:\W\$ '

EXPOSE 80 443

ENTRYPOINT ["/run/apache2/bootstrap.sh"]
