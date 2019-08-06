#!/bin/bash
# https://github.com/pegasuskim-dev/docker-mysql/blob/master/5.7/entrypoint.sh

set -e
set -m

MYSQL_DATA_DIR="/var/lib/mysql"
MYSQL_CONFIG="/etc/mysql/mysql.conf.d/mysqld.cnf"
MYSQL_LOG="/var/log/mysql/error.log"
MYSQL_CACHE_ENABLED=false
MYSQL_USER=root
MYSQL_PASS=asdf12

DB_NAME="imqa,imqa_user,imqa_alert,imqa_crash_apple,imqa_crash_unity,imqa_mpm_analysis,imqa_mpm_apple"

#sed -e 's/datadir\ .*$/datadir = \/var\/lib\/sqldata/' -i /etc/mysql/mysql.conf.d/mysqld.cnf
#sed -e 's/bind-address .*/bind-address = 0.0.0.0/g' -i /etc/mysql/mysql.conf.d/mysqld.cnf
sed -e "s/^bind-address\(.*\)=.*/bind-address = 0.0.0.0/" -i /etc/mysql/mysql.conf.d/mysqld.cnf

#pass=!@hyperion78*
#unbuffer expect -c "spawn mysql_config_editor set --login-path=mylogin --host=localhost --user=root --password
#expect -nocase \"Enter password:\" {send \"$pass\r\"; interact}"
#mysql_config_editor print --login-path=mylogin

cat /etc/mysql/debian.cnf
echo "=== debian.cnf password empty ==="
sed -e 's/password = .*/password = /g' -i /etc/mysql/debian.cnf
cat /etc/mysql/debian.cnf

#echo "=== Mysql Setting ==="
#mkdir -p ${MYSQL_DATA_DIR}
chmod -R 0755 /var/lib/mysql
usermod -d /var/lib/mysql mysql
chown -R mysql:mysql /var/lib/mysql

chmod -R 0755 /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
touch /var/run/mysqld/mysqld.sock
chown mysql:mysql /var/run/mysqld/mysqld.sock
#ln -s /tmp/mysql.sock /var/run/mysqld/mysqld.sock
# Set permission of config file
#chmod 644 ${MYSQL_CONFIG}

echo "${MYSQL_DATA_DIR}"
echo "${MYSQL_CONFIG}"
echo "${MYSQL_USER}"
echo "${MYSQL_PASS}"
echo "${DB_NAME}"

start_mysql()
{
    if [ ! -d ${MYSQL_DATA_DIR}/mysql ]; then
        echo "initialize and Installing database..."
        #/usr/sbin/mysqld --initialize-insecure --user=mysql >/dev/null 2>&1
        mysqld --initialize-insecure --user=mysql >/dev/null 2>&1
        touch /tmp/.EMPTY_DB
        #/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
        #mysqld --initialize-insecure --user=mysql --basedir=/usr --datadir=/var/lib/mysql
        echo "0-0. Starting MySQL server..."
        #/usr/bin/mysqld_safe --user=root >/dev/null 2>&1 &
        /usr/bin/mysqld_safe >/dev/null 2>&1 &

        # wait for mysql server to start (max 30 seconds)
        timeout=30
        echo -n "Waiting for database server to accept connections..."
          #while ! /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf status >/dev/null 2>&1
          while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
            do
              timeout=$(($timeout - 1))
              if [ $timeout -eq 0 ]; then
                echo -e "\nCould not connect to database server. Aborting..."
                exit 1
              fi
              echo -n "."
              sleep 1
            done

        echo "Creating debian-sys-maint user..."
        mysql -uroot -e "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '';"
        #mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost';"

        mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"
        mysql -uroot -e "FLUSH PRIVILEGES;"
        #mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"
        echo -n "0-0 mysql shutdown!"
        /usr/bin/mysqladmin -uroot shutdown
     else
        $(which mysqld) >/dev/null 2>&1 &
        # start mysql server
        echo "0-1. Starting MySQL server... "
        #/usr/bin/mysqld_safe --user=root --skip-grant-tables >/dev/null 2>&1 &
        #/usr/bin/mysqld_safe --user=root >/dev/null 2>&1 &
        /usr/bin/mysqld_safe >/dev/null 2>&1 &

        # wait for mysql server to start (max 30 seconds)
        timeout=30
        echo -n "Waiting for database server to accept connections"
        #while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
        while ! /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf status >/dev/null 2>&1
          do
            timeout=$(($timeout - 1))
            if [ $timeout -eq 0 ]; then
              echo -e "\nCould not connect to database server. Aborting..."
              exit 1
            fi
            echo -n "."
            sleep 1
          done

        #echo "Creating debian-sys-maint user..."
        #mysql --defaults-file=/etc/mysql/debian.cnf -e "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '';"
        mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"
        mysql --defaults-file=/etc/mysql/debian.cnf -e "FLUSH PRIVILEGES;"
        echo -n "0-1 mysql shutdown!"
        /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
    fi
}

update_mysql_pass()
{
    #$(which mysqld) >/dev/null 2>&1 &
    # start mysql server
    echo "1. Starting MySQL server..."
    #/usr/bin/mysqld_safe --user=root --skip-grant-tables >/dev/null 2>&1 &
    #/usr/bin/mysqld_safe --user=root >/dev/null 2>&1 &
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

    # wait for mysql server to start (max 30 seconds)
    timeout=30
    echo -n "Waiting for database server to accept connections"
    #while ! /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf status >/dev/null 2>&1
    while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
      do
        timeout=$(($timeout - 1))
        if [ $timeout -eq 0 ]; then
          echo -e "\nCould not connect to database server. Aborting..."
          exit 1
        fi
        echo -n "."
        sleep 1
      done
    echo

    #echo "UPDATE MySQL PASSWORD ..."
    #mysql --login-path=~/.mylogin.cnf -e "UPDATE mysql.user SET authentication_string=PASSWORD('${MYSQL_PASS}') WHERE user='root';"
    mysql --defaults-file=/etc/mysql/debian.cnf -e "UPDATE mysql.user SET authentication_string=PASSWORD('${MYSQL_PASS}') WHERE user='root';"

    mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_PASS}' WITH GRANT OPTION;"
    mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT TRIGGER ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT SUPER ON *.* TO 'root'@'%';"
    mysql --defaults-file=/etc/mysql/debian.cnf -e "FLUSH PRIVILEGES;"
    #/usr/bin/mysqladmin -uroot shutdown
    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
}


create_db()
{
    #$(which mysqld) >/dev/null 2>&1 &
    # start mysql server
    echo "2. Starting MySQL server..."
    #/usr/bin/mysqld_safe --user=root --skip-grant-tables >/dev/null 2>&1 &
    #/usr/bin/mysqld_safe --user=root >/dev/null 2>&1 &
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

    # wait for mysql server to start (max 30 seconds)
    timeout=30
    echo -n "Waiting for database server to accept connections"

    #while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
    while ! /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf status >/dev/null 2>&1
    do
      timeout=$(($timeout - 1))
      if [ $timeout -eq 0 ]; then
        echo -e "\nCould not connect to database server. Aborting..."
        exit 1
      fi
      echo -n "."
      sleep 1
    done

    if [[ -n ${DB_NAME} ]]; then
        for db in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${DB_NAME}"); do
            echo "Creating database \"${db}\"..."
            #mysql --login-path=~/.mylogin.cnf  -e "CREATE DATABASE IF NOT EXISTS ${db};"
            #mysql -uroot -e  "CREATE DATABASE IF NOT EXISTS ${db};"
            mysql --defaults-file=/etc/mysql/debian.cnf  -e "CREATE DATABASE IF NOT EXISTS ${db};"

        done
        echo "Done!"
    fi
    #/usr/bin/mysqladmin -uroot shutdown
    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
}

create_schema()
{
    #$(which mysqld) >/dev/null 2>&1 &
    # start mysql server
    echo "3. Starting MySQL server..."
    #/usr/bin/mysqld_safe --user=root --skip-grant-tables >/dev/null 2>&1 &
    #/usr/bin/mysqld_safe --user=root >/dev/null 2>&1 &
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

    # wait for mysql server to start (max 30 seconds)
    timeout=30
    echo -n "Waiting for database server to accept connections"

    #while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
    while ! /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf status >/dev/null 2>&1
    do
      timeout=$(($timeout - 1))
      if [ $timeout -eq 0 ]; then
        echo -e "\nCould not connect to database server. Aborting..."
        exit 1
      fi
      echo -n "."
      sleep 1
    done
       
    #cd /etc/schema/
    #echo "Createing Schema imqa_user"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa_user < /etc/schema/imqa_user.sql

    #echo "Createing Schema imqa"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa < /etc/schema/imqa.sql

    #echo "Createing Schema imqa_crash_apple"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa_crash_apple < /etc/schema/imqa_crash_apple.sql

    #echo "Createing Schema imqa_crash_unity"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa_crash_unity < /etc/schema/imqa_crash_unity.sql

    #echo "Createing Schema imqa_mpm_analysis"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa_mpm_analysis < /etc/schema/imqa_mpm_analysis.sql

    #echo "Createing Schema imqa_mpm_apple"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa_mpm_apple < /etc/schema/imqa_mpm_apple.sql

    #echo "Createing Schema imqa_alert"
    #mysql --defaults-file=/etc/mysql/debian.cnf imqa_alert < /etc/schema/imqa_alert.sql


    #/usr/bin/mysqladmin -uroot shutdown
    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
}

#Initialize empty data volume and create MySQL user
if [[ ${MYSQL_CACHE_ENABLED} == true ]]; then
    echo "Enabled query cache to '${MYSQL_CONFIG}' (query_cache_type = 1)"
    sed -i "s/^#query_cache_type.*/query_cache_type = 1/" ${MYSQL_CONFIG}
fi

# allow arguments to be passed to mysqld_safe
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == mysqld_safe || ${1} == $(which mysqld_safe) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi


# default behaviour is to launch mysqld_safe
if [[ -z ${1} ]]; then
    start_mysql
    # Create admin user and pre create database
    #if [ ! -d ${MYSQL_DATA_DIR}/mysql ]; then
    if [ -f /tmp/.EMPTY_DB ]; then
        update_mysql_pass
        echo "Create DataBases ... "
        create_db
        sleep 1
        create_schema
        rm /tmp/.EMPTY_DB
    fi
    echo "DataBases Deamon Start ... "
    exec $(which mysqld_safe) $EXTRA_ARGS
else
    exec "$@"
fi
