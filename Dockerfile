FROM phusion/baseimage:0.9.17

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Add VN repo
ADD sources.list /etc/apt/sources.list
ADD sysctl.conf /etc/sysctl.conf

ENV DEBIAN_FRONTEND noninteractive
ENV INI_FILE 		/etc/php5/fpm/php.ini

# Nginx-PHP Installation
RUN add-apt-repository -y ppa:ondrej/php5-5.6 && \
	add-apt-repository -y ppa:nginx/stable && \
# RUN add-apt-repository -y ppa:git-core/ppa
apt-get update && \
apt-get install -y --force-yes curl wget build-essential python-software-properties \
nginx php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl \
php5-imagick php5-mcrypt php5-intl php5-imap php5-tidy php5-mongo php5-redis && \
# Optimize PHP
sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini && \
sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini && \
echo "daemon off;" >> /etc/nginx/nginx.conf && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" $INI_FILE && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 256M/g" $INI_FILE && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 256M/g" $INI_FILE

RUN mkdir -p        /var/www && \
	mkdir           /etc/service/nginx && \
	mkdir           /etc/service/phpfpm

ADD build/default   /etc/nginx/sites-available/default
ADD nginx.conf		/etc/nginx/nginx.conf
ADD build/nginx.sh  /etc/service/nginx/run
ADD build/phpfpm.sh /etc/service/phpfpm/run

RUN chmod +x 		/etc/service/phpfpm/run && \
	chmod +x        /etc/service/nginx/run

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
