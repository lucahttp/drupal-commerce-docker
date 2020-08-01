FROM ubuntu:latest


# File Author / Maintainer
LABEL author="lukaneco"
LABEL maintainer="luca.sain@outlook.com"


## seteando lenguaje
ENV OS_LOCALE="es_AR.UTF-8"
RUN apt-get update && apt-get install -y apt-utils locales && locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    DEBIAN_FRONTEND=noninteractive


# ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=America/Argentina/Buenos_Aires

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update the repository sources list
# RUN apt-get update

# Install and run apache
RUN apt-get install -y apache2 php php-mysql php-mbstring php-xml php-gd wget curl unzip zip && apt-get clean


# delete all file of the html folder
RUN rm -R /var/www/html/*

# set permisions on the html folder
RUN	chown www-data:www-data /var/www/html/ -Rf

#ENTRYPOINT ["/usr/sbin/apache2", "-k", "start"]
#RUN service apache2 restart


# https://projects.raspberrypi.org/en/projects/lamp-web-server-with-wordpress/4
# https://pimylifeup.com/raspberry-pi-wordpress/

#RUN cd /var/www/html
#RUN wget http://wordpress.org/latest.tar.gz
#RUN tar xzf latest.tar.gz
#RUN mv wordpress/* ./
#RUN rm -rf wordpress latest.tar.gz
#RUN usermod -a -G www-data pi
#RUN chown -R -f www-data:www-data /var/www/html



# https://raspberrytips.com/wordpress-on-raspberry-pi/
# RUN wget https://wordpress.org/latest.zip -O /var/www/html/wordpress.zip


# install the PHP extensions we need
RUN apt-get update \
  && apt-get install -y git \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-install bcmath

# install Composer globally
RUN curl -sS https://getcomposer.org/installer | php \
     && mv composer.phar /usr/local/bin/composer \
     && php -r "echo ini_get('memory_limit').PHP_EOL;" \
     ##&& php -d memory_limit=2G /usr/local/bin/composer require hwi/oauth-bundle php-http/guzzle6-adapter php-http/httplug-bundle \
     && php -d memory_limit=2G /usr/local/bin/composer install \
     && php --ini
# install Drupal Commerce 2.x https://docs.drupalcommerce.org/commerce2/developer-guide/install-update/installation

WORKDIR /var/www/
RUN rm -rf /var/www/html/
RUN  composer create-project drupalcommerce/project-base html --stability dev


# WORKDIR /var/www/html/
EXPOSE 80
# EXPOSE 443

# By default, simply start apache.
CMD apachectl -D FOREGROUND