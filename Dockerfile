FROM debian:stretch
MAINTAINER AfterLogic Support <dockerimages@j3n50m4t.com>

# installing packages and dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y install wget unzip supervisor apache2 libapache2-mod-php7.0 mysql-server php7.0 php7.0-common php7.0-curl php7.0-fpm php7.0-cli php7.0-mysqlnd php7.0-mcrypt php7.0-mbstring php7.0-xml
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# adding configuration files and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
RUN chmod 755 /*.sh

# deleting default database
RUN rm -rf /var/lib/mysql/*

# setting up default apache config
ADD apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

VOLUME /var/www/html

# downloading and setting up webmail
RUN rm -rf /tmp/alwm
RUN mkdir -p /tmp/alwm
RUN wget -P /tmp/alwm https://afterlogic.org/download/webmail-lite-php-8.zip
RUN unzip -q /tmp/alwm/webmail-lite-php-8.zip -d /tmp/alwm/webmail
RUN rm -rf /var/www/html
RUN mkdir -p /var/www/html
RUN cp -r /tmp/alwm/webmail/* /var/www/html
RUN rm -rf /var/www/html/install
RUN chown www-data.www-data -R /var/www/html
RUN chmod 0777 -R /var/www/html/data
RUN rm -f /var/www/html/afterlogic.php
COPY afterlogic.php /var/www/html/afterlogic.php
RUN rm -rf /tmp/alwm

# setting php configuration values
ENV PHP_UPLOAD_MAX_FILESIZE 64M
ENV PHP_POST_MAX_SIZE 128M

# adding mysql volumes
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]


EXPOSE 80 3306
CMD ["/run.sh"]
