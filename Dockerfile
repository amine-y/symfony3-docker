FROM ubuntu:20.04
USER root

ARG DEBIAN_FRONTEND=noninteractive


ENV SSHPASS_ENV="s654df65sd4f5s46df5"

WORKDIR /root


#Install basic environment
RUN apt-get -y update


RUN apt-get -y install software-properties-common

RUN add-apt-repository ppa:ondrej/php

RUN apt-get -y update

RUN apt-get -y install \
	subversion \ 
	curl \ 
    openssh-server \
	supervisor \
    git \
    htop \
    cron \
    nano \
    ffmpeg \
    mysql-client \
	php7.3 \
	php7.3-common \
	php7.3-mysql \
	php7.3-xml \
	php7.3-xmlrpc \
	php7.3-curl \
	php7.3-gd \
	php7.3-imagick \
	php7.3-cli \
	php7.3-dev \
	php7.3-imap \
	php7.3-sqlite3 \
	php7.3-mbstring \
	php7.3-opcache \
	php7.3-soap \
	php7.3-zip \
	php7.3-intl \
	php7.3-ctype \
	php7.3-dom \
	php7.3-iconv \
	php7.3-simplexml \
	php7.3-xsl \
	php7.3-ssh2 \
	php7.3-bcmath \
	ruby-full \
	libnss3 \
	libxss1 \
	libasound2 \
	libatk-bridge2.0-0 \
	libgtk-3-0 
	
RUN apt-get  install  -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget	
RUN  apt-get install -y libgbm-dev
RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install nodejs
RUN npm install -g requirejs
RUN npm install -g uglify-js


# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Set up SSH access
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


EXPOSE 22
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
