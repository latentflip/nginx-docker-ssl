#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
FROM dockerfile/ubuntu

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

RUN \
  mkdir -p /etc/nginx/sites-enabled \
  mkdir -p /etc/nginx/certs

COPY ./sites-enabled/default.tmpl /etc/nginx/default.tmpl
COPY ./certs/cowboy.io.pem /etc/nginx/certs/cowboy.io.pem
COPY ./certs/cowboy.io.key /etc/nginx/certs/cowboy.io.key

COPY ./boot.sh /etc/nginx/boot.sh
RUN chmod +x /etc/nginx/boot.sh

# Define mountable directories.
# VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["./boot.sh"]
