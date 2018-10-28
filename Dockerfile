FROM debian:9.5
MAINTAINER Peter Naudus <uselinux@gmail.com>
RUN apt-get -y update
RUN apt-get -y  --no-install-recommends install python python-dev python-pip apache2 apache2-dev libev-dev gcc python-setuptools

# NginX Unit part, start:
RUN apt-get -y  --no-install-recommends install software-properties-common apt-transport-https gnupg2 dirmngr curl
RUN add-apt-repository 'deb https://packages.nginx.org/unit/debian/ stretch unit'
RUN apt-key adv --fetch-keys https://nginx.org/keys/nginx_signing.key
RUN apt-get -y update
RUN apt-get -y  --no-install-recommends install unit-python2.7
# NginX Unit part, end.

RUN rm -rf /var/lib/apt/lists/*
RUN pip install \
                cherrypy==17.4.0    \
                uwsgi==2.0.17.1     \
                gunicorn==19.9.0    \
                bjoern==2.2.3       \
                meinheld==0.6.1     \
                mod_wsgi==4.6.5
RUN mkdir -p /home/www
COPY src /home/www/wsgi_benchmark
RUN chown -R www-data:www-data /home/www/wsgi_benchmark
