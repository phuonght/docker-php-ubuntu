FROM phusion/baseimage:0.9.17

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

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
nginx supervisor php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl \
php5-imagick php5-mcrypt php5-intl php5-imap php5-tidy php5-mongo php5-redis

RUN rm -fr /etc/php5/fpm/pool.d/www.conf

# Add config
ADD ./php-conf/php.ini /etc/php5/cli/php.ini
ADD ./php-conf/php.ini /etc/php5/fpm/php.ini
ADD ./php-conf/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD ./php-conf/pool.d /etc/php5/fpm/pool.d
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p        /var/www && \
	mkdir -p        /etc/service/supervisord && \
	mkdir -p 		/etc/service/php-fpm && \
	mkdir -p 		/etc/service/nginx

ADD build/default   /etc/nginx/sites-available/default
ADD nginx.conf		/etc/nginx/nginx.conf
ADD build/supervisor.sh  /etc/service/supervisord/run
ADD build/nginx.sh 	/etc/service/nginx/run
ADD build/phpfpm.sh /etc/service/php-fpm/run

RUN chmod +x 		/etc/service/supervisord/run \
					/etc/service/nginx/run \
					/etc/service/php-fpm/run

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD init.sh /sbin/init.sh
RUN chmod +x /sbin/init.sh
ENV TERM xterm

CMD ["/sbin/init.sh"]
