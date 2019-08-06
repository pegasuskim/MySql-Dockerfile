# MySql Dockerfile
#
# https://github.com/pegasuskim-dev/docker-mysql/blob/master/5.7/Dockerfile

# Pull base image.
FROM ubuntu:16.04

ENV OS_LOCALE="ko_KR.UTF-8"

# Install MySql
RUN \
    apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y python-software-properties && \
    apt-get install -y build-essential && \
    apt-get install -y language-pack-ko && \
    apt-get install -y vim && \
    apt-get install -y iputils-ping && \
    apt-get install -y net-tools && \
    apt-get install -y expect && \
    #apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 5072E1F5 && \
    #echo "deb http://repo.mysql.com/apt/ubuntu/ xenial mysql-5.7" | tee /etc/apt/sources.list.d/mysql.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server=${MYSQL_VERSION}* && \
    rm -rf /var/lib/mysql && \
    mkdir -p /var/lib/mysql && \
    chmod -R 0755 /var/lib/mysql && \
    usermod -d /var/lib/mysql mysql && \
    chown -R mysql:mysql /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    chown mysql:adm /var/log/mysql && \
    chown mysql:adm /var/log && \
    chown root:root /var && \
    touch /var/log/mysql/error.log && \
    chown mysql:adm /var/log/mysql/error.log && \
    mkdir -p /var/run/mysqld && \
    chown mysql:mysql /var/run/mysqld && \
    mkdir -p /etc/schema
    #rm -rf /etc/mysql/* && \
    #mkdir /etc/mysql/conf.d && \
    #rm -rf /var/lib/apt/lists/* && \
    # Forward request and error logs to docker log collector
    #ln -sf /dev/stderr ${MYSQL_LOG}

#ADD imqa.sql /etc/schema
#ADD imqa_user.sql /etc/schema
#ADD imqa_alert.sql /etc/schema
#ADD imqa_crash_apple.sql /etc/schema
#ADD imqa_crash_unity.sql /etc/schema
#ADD imqa_mpm_analysis.sql /etc/schema
#ADD imqa_mpm_apple.sql /etc/schema

# Add MySQL configuration
#COPY mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
ADD mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=en_US:en \
    LC_ALL=${OS_LOCALE}

WORKDIR /
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
#RUN chmod 755 /entrypoint.sh

EXPOSE 15772/tcp

VOLUME ["/var/lib/mysql","/var/log/mysql"]

#ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash","/entrypoint.sh"]
