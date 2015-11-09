#!/bin/bash

if [ -d /var/www/cron.d ]; then
    cp /var/www/cron.d/* /etc/cron.d/
    chown -R root:root /etc/cron.d
    chmod 0644 /etc/cron.d/*
fi

if [ -d /var/www/supervisor.d ]; then
    cp /var/www/supervisor.d/* /etc/supervisor/conf.d/
    chown -R root:root /etc/supervisor/conf.d/
fi

if [ -d /var/www/storage ]; then
    chmod -R o+w /var/www/storage
fi

/sbin/my_init
