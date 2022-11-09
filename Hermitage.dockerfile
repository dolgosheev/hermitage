##################################################################
#   Base System
##################################################################
FROM nginx:1.21.6 AS base
LABEL admin="izumroot@deeplay.io"
WORKDIR /app

##################################################################
#   Set Enviroment
#   Set the SHELL to bash with pipefail option
##################################################################
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND noninteractive

# Install apt packages
RUN apt-get -o Acquire::Check-Valid-Until=false update -qq                                          && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"    && \
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"       \
        bash-completion                         \
        bsdutils                                \
        build-essential                         \
        coreutils                               \
        curl                                    \
        dstat                                   \
        file                                    \
        git                                     \
        htop                                    \
        jq                                      \
        ksh                                     \
        libbz2-dev                              \
        libssl-dev                              \
        locales                                 \
        openssl                                 \
        patch                                   \
        software-properties-common              \
        ssh                                     \
        sudo                                    \
        tmux                                    \
        util-linux                              \
        vim                                     \
        wget                                    \
        mc                                      \
        xz-utils                                \
        zsh                                  && \
        apt-get clean && rm -r /var/lib/apt/lists /var/cache/apt/archives

RUN apt-get clean && apt-get update && apt install -y \
    mc \
    nano \
    php7.4 \
    php7.4-common \
    php7.4-mysql \
    php7.4-gmp \
    php7.4-curl \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-xmlrpc \
    php7.4-gd \
    php7.4-xml \
    php7.4-cli \
    php7.4-zip \
    php7.4-soap \
    php7.4-imap \
    php7.4-fpm && \
    apt-get clean && rm -r /var/lib/apt/lists /var/cache/apt/archives

RUN apt-get clean && apt-get update && apt install -y \
    php7.4-dev && \
    apt-get clean && rm -r /var/lib/apt/lists /var/cache/apt/archives

RUN pecl channel-update pecl.php.net

RUN pecl install apcu -n

RUN echo "extension=apcu.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

##################################################################
#   Install Composer
##################################################################
RUN apt-get -o Acquire::Check-Valid-Until=false update -qq                                          && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"    && \
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"       \
        composer                               && \
        apt-get clean && rm -r /var/lib/apt/lists /var/cache/apt/archives

##################################################################
#   Install Hermitage
##################################################################
RUN composer create-project livetyping/hermitage-skeleton hermitage
RUN apt-get -y autoclean
RUN cp -r ./hermitage /usr/share/nginx/hermitage

RUN apt-get -y autoclean

##################################################################
#   Nginx manipulations
##################################################################

#Change owner
RUN sed -i 's/user  nginx/user  www-data/g ' /etc/nginx/nginx.conf

RUN \
echo $'\
server {                                                                        \n\
    listen 80 default_server;                                                   \n\
    listen [::]:80 default_server;                                              \n\
    server_name localhost;                                                      \n\
    root /usr/share/nginx/hermitage/public;                                     \n\
    location / {                                                                \n\
        try_files $uri /index.php$is_args$args;                                 \n\
    }                                                                           \n\
location ~ ^/index\.php(/|$) {                                                  \n\
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;                             \n\
        fastcgi_split_path_info ^(.+\.php)(/.*)$;                               \n\
        include fastcgi_params;                                                 \n\
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;       \n\
        fastcgi_param DOCUMENT_ROOT $realpath_root;                             \n\
    }                                                                           \n\
    location ~ \.php$ {                                                         \n\
        return 404;                                                             \n\
    }                                                                           \n\
    error_log /var/log/nginx/project_error.log;                                 \n\
    access_log /var/log/nginx/project_access.log;                               \n\
}                                                                               \n\
'\
> /etc/nginx/conf.d/default.conf

RUN \
echo $'extension=apcu.so' > /etc/php/7.4/fpm/conf.d/apcu.ini

RUN sed -i 's/set -e/set -e\nservice php7.4-fpm start/g ' /docker-entrypoint.sh

RUN chown -R www-data:www-data /usr/share/nginx/hermitage

EXPOSE 80
EXPOSE 443