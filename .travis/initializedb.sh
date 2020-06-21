#!/bin/bash

set -ex

cat << EOF >mysqld.cnf
[mysqld]
secure-auth=0
EOF

path=`pwd`

sudo chmod -R 777 /var/run/mysqld
sudo docker pull ${DB_VERSION}
sudo docker run \
    -itd \
    --privileged \
    --name=mysqld \
    --pid=host \
    -p 3306:3306 \
    --ipc=host \
    -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    --volume=/var/run/mysqld:/var/run/mysqld \
    --volume=$path/mysqld.cnf:/etc/mysql/conf.d/mysqld.cnf \
    ${DB_VERSION}

mysql() {
    docker exec mysqld mysql "${@}"
}
while :
do
    sleep 3
    mysql --protocol=tcp -e 'select version()' && break
done
docker logs mysqld

mysql -uroot -e 'create database golang_test;'

mysql -uroot -e 'create user "user_old"@"%" identified with mysql_old_password;'
mysql -uroot -e 'set old_passwords = 1;set password for "user_old"@"%" = PASSWORD("pass_old");'
mysql -uroot -e 'grant all on golang_test.* to "user_old"@"%";'
mysql -uroot -e 'create user "nopass_old"@"%" identified with mysql_old_password;'
mysql -uroot -e 'set password for "nopass_old"@"%" = "";'
mysql -uroot -e 'grant all on golang_test.* to "nopass_old"@"%";'

mysql  -uroot -e 'use golang_test;create table cats (id serial primary key, name varchar(5));'
mysql  -uroot -e 'use golang_test;insert into cats (name) value ("Bob"),(""),(null);'
mysql  -uroot -e 'use golang_test;select * from cats;'


mysql -uroot -e 'select * from information_schema.plugins where  plugin_type="AUTHENTICATION"\G';
mysql -uroot -e 'select User, plugin from mysql.user\G';

mysql -uroot -e 'flush privileges;'
