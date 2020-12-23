FROM ubuntu:20.04

RUN apt-get update -qq\
 && apt-get install -y apt-transport-https ca-certificates \
 && apt-get install -y language-pack-fr-base software-properties-common apt-utils

RUN locale-gen fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr

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
  php-pear \
  php7.3-curl \
  sudo \
  rsync \
  sendmail \
  git-core \
  unzip \
  wget \
  curl \
  mysql-client

ENV AEGIR_UID 1000

RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"

RUN addgroup --gid $AEGIR_UID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_UID --system --home /var/aegir aegir
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

ENV DRUSH_VERSION=8.3.0
RUN wget https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

# Install fix-permissions and fix-ownership scripts
RUN wget http://cgit.drupalcode.org/hosting_tasks_extra/plain/fix_permissions/scripts/standalone-install-fix-permissions-ownership.sh
RUN bash standalone-install-fix-permissions-ownership.sh

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Aegir.' > /var/log/aegir/system.log

ENV REGISTRY_REBUILD_VERSION 7.x-2.5
RUN drush dl --destination=/usr/share/drush/commands registry_rebuild-$REGISTRY_REBUILD_VERSION -y

USER aegir

RUN mkdir /var/aegir/config
RUN chown aegir:aegir /var/aegir/config -R
RUN mkdir /var/aegir/.drush

#PREPARE SSH
RUN mkdir /var/aegir/.ssh
RUN chmod 700 /var/aegir/.ssh
RUN touch /var/aegir/.ssh/authorized_keys
RUN chmod 600 /var/aegir/.ssh/authorized_keys

ENV ID_RSA_PUB ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDrQdWf01Rr6pP0DRtMa5QeZd2s6SK1fKSlZES9IaXN/w+uBhSCCMsElyPWDJ7rXbQVJavXE+yYiIBUpKcrex7u7b7+7V/PJOApfXZgijp3wZs6uSEdmpgq+ik50ah3Dg6RgrnFjS041rPzg/tnmkVbszCjAL6JRI55uEjnjnJXbLjGulndof8ZzCg0haCgeHuEgQDxQJ9b+Er3BX0zB2MNSyZnUEfQr4QxSQmOecD0rAYihAsp1TGHu2sAnxLE+m1L6pjOS/ZN0ca+0BH9hOQTNdAelhzVue7GYWdFm9Cqa5iq5xZx7dYPtkvuHyukKIYd31dyvN9JjBRbloZTpWKhuUWge7RvVLGGdJ8gWJB0T2QdsBuR+bpDyTse0h31F+5o5pXZ8OeHEOsMQBsl1Qy02RMk/yfgKMic11udUDB53bgj9joFQwbuFLzrirSsR6ErCg/qsO/D532UE3a5EV4gHqp8gmeAmlGmOVgmuI6iM880PM/iyW347i0SiY3OMOc= aegir@devaegirhostmaster

RUN echo ${ID_RSA_PUB} >> /var/aegir/.ssh/authorized_keys

COPY www.conf /etc/php/7.3/fpm/pool.d/www.conf

# Must be fixed across versions so we can upgrade containers.
ENV AEGIR_HOSTMASTER_ROOT /var/aegir/hostmaster

WORKDIR /var/aegir

# The Hostname of the database server to use
ENV AEGIR_DATABASE_SERVER database

VOLUME /var/aegir

USER root

# Expose Apache
EXPOSE 80
COPY httpd-foreground /usr/local/bin/httpd-foreground
RUN chmod +x /usr/local/bin/httpd-foreground
# Launch Apache
CMD ["httpd-foreground"]