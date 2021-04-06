FROM ubuntu:20.04

RUN apt-get update -qq\
 && apt-get install -y apt-transport-https ca-certificates \
 && apt-get install -y locales locales-all software-properties-common apt-utils

ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr

ENV MYSQL_STATISTICS false

RUN locale-gen $LANG

RUN apt-add-repository ppa:ondrej/php

RUN apt-get update -qq && apt-get install -y -qq\
  apache2 \
  apache2-utils \
  libapache2-mod-fcgid \
  openssl \
  php7.3 \
  php7.3-cli \
  php7.3-common \
  php7.3-gd \
  php7.3-mysql \
  php7.3-xml \
  php7.3-mbstring \
  php7.3-redis \
  php7.3-fpm \
  php7.3-ldap \
  php7.3-zip \
  php-pear \
  php7.3-curl \
  sudo \
  rsync \
  sendmail \
  git-core \
  unzip \
  wget \
  curl \
  mysql-client \
  openssh-server \
  cron

ARG AEGIR_UID=1000
ENV AEGIR_UID ${AEGIR_UID:-1000}
ENV APACHE_PHP_RUN_USER aegir
ENV APACHE_PHP_RUN_GROUP aegir
ENV APACHE_RUN_USER aegir
ENV APACHE_RUN_GROUP aegir
ENV AEGIR_SSH_PWD aegir


RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"

RUN addgroup --gid $AEGIR_UID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_UID --home /var/aegir aegir
RUN adduser aegir www-data
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod actions fcgid alias proxy_fcgi
RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -s /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
  composer global require drush/drush && \
  composer global require cweagans/composer-patches

# Et on fini par l'install de VIM car on en aura forcement besoin 
RUN apt-get install -y vim 

ENV DRUSH_VERSION=8.4.6
RUN wget https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

# Install fix-permissions and fix-ownership scripts
RUN wget http://cgit.drupalcode.org/hosting_tasks_extra/plain/fix_permissions/scripts/standalone-install-fix-permissions-ownership.sh
RUN bash standalone-install-fix-permissions-ownership.sh

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN chown -R aegir:aegir /var/log/*
RUN echo 'Hello, Aegir.' > /var/log/aegir/system.log

ENV REGISTRY_REBUILD_VERSION 7.x-2.5
RUN drush dl --destination=/usr/share/drush/commands registry_rebuild-$REGISTRY_REBUILD_VERSION -y

#Prepare PHP FPM config for apache
COPY php-fpm.conf /etc/apache2/conf-available/
RUN a2enconf php-fpm

USER aegir

#PREPARE SSH
RUN chmod 755 /var/aegir
RUN mkdir /var/aegir/.ssh
RUN chmod 700 /var/aegir/.ssh
RUN touch /var/aegir/.ssh/authorized_keys
RUN chmod 600 /var/aegir/.ssh/authorized_keys
ENV ID_RSA_PUB ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbsKy0p+/hd+nT1ArljTAJGlwSVWbOx+oZfhO/IY3MLzp3DNq9Y7pT3S7FTSAvVIU/NezxfUCY459mBQ6DaKXozf1Lv27qaVEp7329ukCDDhlYdodHTMBjCcLsGyaYIl9jeamTUIOjnj2rMMXnB9rH4g65wJ/owjGxkfN2i7oho4+uOO8WIcjjR9maySP5KnP8aedGSImGvkWLkmpWev91qoFkBvD3ReYdD5Rm7uS2WgICQx030XxwxCPXZAycN8r3cvb0f0zXpTelOtRI7cGrrxtq/Ql+6kGH++x/wrjanVlWcnM5OLMzf+s/YbidctbxqtVcD94o6KfjLzQ+de8CVL8OmFFlg6GLNIkUqHfhYzgfE9eC8Kog1Hr795H51z3zOGs57oDQLZQQmuQzt5N2PN/C3YQm5B6B9k0H8658rCkPqiQCmvazg7HP5hhs6GOJp4XqmW2MVlHYzaSYaGRY+7nAJZEzsguSV15vZhgMOZ3EtVdMvvt5gGnHJsU1AQM= root@ssh-dff584fc-9qjjp aegir@devaegirhostmaster

RUN echo ${ID_RSA_PUB} >> /var/aegir/.ssh/authorized_keys

RUN mkdir /var/aegir/config
RUN chown aegir:aegir /var/aegir/config -R
RUN mkdir /var/aegir/.drush

COPY www.conf /etc/php/7.3/fpm/pool.d/www.conf

# Must be fixed across versions so we can upgrade containers.
ENV AEGIR_HOSTMASTER_ROOT /var/aegir/hostmaster

WORKDIR /var/aegir

# The Hostname of the database server to use
ENV AEGIR_DATABASE_SERVER database

VOLUME /var/aegir

# Expose Apache
EXPOSE 80
COPY httpd-foreground /usr/local/bin/httpd-foreground
RUN sudo chmod +x /usr/local/bin/httpd-foreground
# Launch Apache
CMD ["httpd-foreground"]
User root