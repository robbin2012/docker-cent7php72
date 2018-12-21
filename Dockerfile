FROM centos/httpd:latest
MAINTAINER robbin

RUN yum clean all && yum makecache fast && yum -y update \
    && yum -y install epel-release 

RUN rpm -iUvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm

RUN rpm -iUvh http://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum install -y yum-utils mariadb-server mariadb httpd

RUN yum update -y && yum-config-manager --enable remi-php72 

RUN yum install -y php  php-opcache php-mysql php-mbstring  php-bcmath php-pdo php-xml php-mcrypt php-pecl-imagick php-pecl-memcached php-gd php-xmlrpc php-soap php-xmlrpc

RUN echo "Setting up SSH for GitHub Checkouts..." \
    && mkdir -p /root/.ssh && chmod 700 /root/.ssh \
    && touch /root/.ssh/known_hosts \
    && chmod 600 /root/.ssh/known_hosts \
    #&& echo "Setting up postfix and phpmail for outbound email.." \
    #&& touch /var/log/phpmail.log \
    #&& mkfifo /var/spool/postfix/public/pickup \
    && chown apache: /var/www/html

# Image optimization commands for drupal8
RUN yum -y install libjpeg-turbo-utils  pngquant optipng pngcrush jpegoptim 
# Composer 
COPY config/composer18.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
# Drupal console 
COPY config/drupal.phar /usr/local/bin/drupal
RUN chmod +x /usr/local/bin/drupal

# Speex convert wechat media 
ADD config/speex-1.2.0.tar.gz /root/
WORKDIR /root/speex-1.2.0
RUN yum install -y gcc gcc-c++ 
RUN ./configure 
RUN make && make install 
COPY config/speex_decode /usr/local/bin/speex2wav


#Convert word/ppt files to pdf
RUN yum -y install unoconv
RUN mkdir /usr/share/fonts/winfonts/
COPY config/fonts/* /usr/share/fonts/winfonts/
WORKDIR /usr/share/fonts/winfonts
RUN rm .git -rf #remove git file and dir
RUN mkfontscale && mkfontdir && fc-cache -fv


# Setup htaccess and apache conf
COPY config/main.cf /etc/postfix/main.cf
COPY config/php.ini /etc/php.ini

EXPOSE 80
#ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
