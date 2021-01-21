#!/bin/sh
set -e;
mkdir -pv $SVN_PARENT_PATH $SVN_DATA_DIR/conf;
touch $SVN_PASSWORD_FILE;
[ -s $SVN_ACCESS_FILE ] || printf '[groups]\n\n' > $SVN_ACCESS_FILE;
chown -R apache:apache $SVN_DATA_DIR /var/log/apache2;

svnserve --daemon --foreground --root $SVN_PARENT_PATH --listen-port 3690 &

rm -f /run/apache2/httpd.pid;
exec httpd -DFOREGROUND "$@"
