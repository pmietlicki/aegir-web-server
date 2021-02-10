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
*Default: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbsKy0p+/hd+nT1ArljTAJGlwSVWbOx+oZfhO/IY3MLzp3DNq9Y7pT3S7FTSAvVIU/NezxfUCY459mBQ6DaKXozf1Lv27qaVEp7329ukCDDhlYdodHTMBjCcLsGyaYIl9jeamTUIOjnj2rMMXnB9rH4g65wJ/owjGxkfN2i7oho4+uOO8WIcjjR9maySP5KnP8aedGSImGvkWLkmpWev91qoFkBvD3ReYdD5Rm7uS2WgICQx030XxwxCPXZAycN8r3cvb0f0zXpTelOtRI7cGrrxtq/Ql+6kGH++x/wrjanVlWcnM5OLMzf+s/YbidctbxqtVcD94o6KfjLzQ+de8CVL8OmFFlg6GLNIkUqHfhYzgfE9eC8Kog1Hr795H51z3zOGs57oDQLZQQmuQzt5N2PN/C3YQm5B6B9k0H8658rCkPqiQCmvazg7HP5hhs6GOJp4XqmW2MVlHYzaSYaGRY+7nAJZEzsguSV15vZhgMOZ3EtVdMvvt5gGnHJsU1AQM= root@ssh-dff584fc-9qjjp aegir@devaegirhostmaster*

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