**A docker image with apache / php mod fpm version 7.3 to host aegir sites.**
*Designed to run easily under Rancher, see [rancher website](https://rancher.com/)*

What is Aegir?
==============

Aegir is a free and open source hosting system for Drupal, CiviCRM, and Wordpress.

Designed for mass Drupal hosting, Aegir can launch new sites with a single form submission or API call (See [Hosting Services](http://drupal.org/project/hosting_services).

Aegir itself is built on Drupal and Drush, allowing you to tap into the large contributed module community.

For more information, visit aegirproject.org

How to use this image
=====================

This image is designed to create a new aegir web server to deploy aegir sites.

## Manual launch:

    $ docker run --name database -d -e MYSQL_ROOT_PASSWORD=12345 -e mariadb 
    $ docker run --name hostmaster --hostname devwebsrv.local.computer -e MYSQL_ROOT_PASSWORD=12345 --link database:mysql -p 80:80 pmietlicki/aegir-web-server
    
## docker-compose launch:

  1. Create a docker-compose.yml file:

    ```yml
    version: '2'
    services:
    
      hostmaster:
        image: pmietlicki/aegir
        ports:
          - 80:80
        hostname: devaegir.local
        links:
          - database
        depends_on:
          - database
        environment:
          MYSQL_ROOT_PASSWORD: strongpassword
          AEGIR_HOSTNAME: devaegir.local

      webserver:
        image: pmietlicki/aegir-web-server
        ports:
          - 80:80
        hostname: devwebsrv.local
      
      database:
        image: mariadb
        environment:
          MYSQL_ROOT_PASSWORD: strongpassword
    ```
  2. run `docker-compose up`.

# Environment Variables

## AEGIR_CLIENT_NAME 

*Default: admin*

The username of UID1 and the client node.

## LANG 
*Default: fr_FR.UTF-8*

Default LANG for system, put en_US.UTF-8 for english.

## LANGUAGE
*Default: fr_FR:fr*

Default LANGUAGE for system, put en_US for english.

## AEGIR_PROFILE 
*Default: hostmaster*

The install profile to run for the drupal front-end. Defaults to hostmaster.

## AEGIR_UID
*Default: 1000*

UID of the aegir user, you can put 0 if you have sudo or rights problems.

## APACHE_PHP_RUN_USER
*Default: aegir*

username of the user that runs php mod fpm (for rights problems).

## APACHE_PHP_RUN_GROUP
*Default: aegir*

username of the group that runs php mod fpm (for rights problems).

## DRUSH_VERSION
*Default: 8.3.0*

The drush version to install inside the container.

## REGISTRY_REBUILD_VERSION
*Default: 7.x-2.5*

The aegir registry version to install on top of drush.

## ID_RSA_PUB
*Default: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDrQdWf01Rr6pP0DRtMa5QeZd2s6SK1fKSlZES9IaXN/w+uBhSCCMsElyPWDJ7rXbQVJavXE+yYiIBUpKcrex7u7b7+7V/PJOApfXZgijp3wZs6uSEdmpgq+ik50ah3Dg6RgrnFjS041rPzg/tnmkVbszCjAL6JRI55uEjnjnJXbLjGulndof8ZzCg0haCgeHuEgQDxQJ9b+Er3BX0zB2MNSyZnUEfQr4QxSQmOecD0rAYihAsp1TGHu2sAnxLE+m1L6pjOS/ZN0ca+0BH9hOQTNdAelhzVue7GYWdFm9Cqa5iq5xZx7dYPtkvuHyukKIYd31dyvN9JjBRbloZTpWKhuUWge7RvVLGGdJ8gWJB0T2QdsBuR+bpDyTse0h31F+5o5pXZ8OeHEOsMQBsl1Qy02RMk/yfgKMic11utUDB53bgj9joFQwbuFLzrirSsR6ErCg/qsO/D532UE3a5EV4gHqp8gmeAmlGmOVgmuI6iM880PM/iyW347i0SiY3OMOc= aegir@devaegirhostmaster*

The public SSH key of the hostmaster server, **very important if you want aegir to control your web server with ease !**

# USAGE

# Aegir on Docker / Rancher

This project is aimed to get Aegir working *inside* Docker.

An official Aegir docker image will make it really easy to fire up an aegir instance for production or just to try.

This image will also make contributing and testing much, much easier.

## Launching

### Requirements:

 - [Docker](https://docs.docker.com/engine/installation/) & [Docker Compose 2](https://docs.docker.com/compose/install/).
 - Optional : [Rancher](https://rancher.com/)
 - A functional aegir hostmaster (you can use pmietlicki/aegir for that)

### Launching:

1. Run docker pull

    docker pull pmietlicki/aegir-web-server

2. Add the new server to your aegir instance (Server / Add server) using the hostname you defined (devwebsrv.local.computer or using [xip.io](http://xip.io/))

  That's it!