#!/bin/bash
# see http://openresty.org/#Installation

SCRIPT_ROOT=`pwd`
echo $SCRIPT_ROOT

# so MySQL will not prompt you for a root password
DEBIAN_FRONTEND=noninteractive apt-get install -y libpcre3-dev build-essential libssl-dev sudo libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make mysql-server

# HT github.com/benagricola/ngx-openresty-build

# creating openresty group if it's not already there
if ! getent group openresty >/dev/null; then
    addgroup --system openresty >/dev/null
fi

# creating openresty user if it's not already there
if ! getent passwd openresty >/dev/null; then
    adduser \
      --system \
      --disabled-login \
      --ingroup openresty \
      --no-create-home \
      --home /nonexistent \
      --gecos "openresty user" \
      --shell /bin/false \
      openresty  >/dev/null
fi

# these commands threw errors when I tried adding this script as a Vagrant provisioner
# `2> /dev/null` may be more appropriate here than `|| true`
mkdir /var/cache/openresty || true
cp initd /etc/init.d/openresty || true
chmod +x /etc/init.d/openresty || true

VERSION=${1:-"1.4.3.9"}
PKG=ngx_openresty-$VERSION

wget http://openresty.org/download/${PKG}.tar.gz
# for the paranoid; may need some tweaks to work right
#wget http://openresty.org/download/${PKG}.tar.gz.asc
#gpg --keyserver pgpkeys.mit.edu --recv-key A0E98066
#gpg --fingerprint A0E98066
#gpg --verify ${PKG}.tar.gz.asc ${PKG}.tar.gz

tar xzf ${PKG}.tar.gz
cd $PKG

# besides the prefix, these paths aren't OpenResty defaults but they follow Linux conventions
./configure --prefix=/usr/local/openresty/ \
    --with-luajit \
    --sbin-path=/usr/sbin/openresty \
    --conf-path=/etc/openresty/openresty.conf \
    --error-log-path=/var/log/openresty/error.log \
    --http-log-path=/var/log/openresty/access.log \
    --pid-path=/var/run/openresty.pid \
    --lock-path=/var/run/openresty.lock \
    --http-client-body-temp-path=/var/cache/openresty/client_temp \
    --http-proxy-temp-path=/var/cache/openresty/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/openresty/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/openresty/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/openresty/scgi_temp \
    --user=openresty --group=openresty

make
make install

cd $SCRIPT_ROOT

mysql -u root < create.sql
RANDOM_PASS=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c 20 | xargs`
mysqladmin -u root password $RANDOM_PASS
# so you can change this password
echo $RANDOM_PASS > mysql.pass

cp {,/etc/openresty/}openresty.conf
cp {,/usr/local/openresty/nginx/}app.lua

# again, HT github.com/benagricola/ngx-openresty-build

if [ -x "/etc/init.d/openresty" ]; then
    if [ -f "/var/run/openresty.pid" ] && kill -0 `cat /var/run/openresty.pid` >/dev/null; then
        /etc/init.d/openresty upgrade || true
    else
        update-rc.d openresty defaults >/dev/null
        if [ -x "`which invoke-rc.d 2>/dev/null`" ]; then
            invoke-rc.d openresty start || true
        else
            /etc/init.d/openresty start || true
        fi
    fi
fi

echo FIN
