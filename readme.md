# Docker: Ubuntu, Nginx and PHP Stack

You can build this yourself after cloning the project (assuming you have Docker installed).

```bash
cd /path/to/repo/docker-nginx-php
docker build -t webapp . # Build a Docker image named "webapp" from this location "."
# wait for it to build...

# Run the docker container
docker run -v /path/to/local/web/files:/var/www:rw -p 80:80 -d webapp
```

- Supervisor configs: `/var/www/supervisor.d/*.conf`
- Crontabs :`/var/www/cron.d/*`
