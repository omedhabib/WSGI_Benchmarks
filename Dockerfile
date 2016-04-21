FROM debian
MAINTAINER Peter Naudus <uselinux@gmail.com>
RUN apt-get -y update
RUN apt-get -y install python python-dev python-pip apache2 apache2-dev libev-dev gcc
RUN pip install cherrypy tornado uwsgi gunicorn bjoern meinheld mod_wsgi
RUN mkdir -p /home/www
COPY src /home/www/wsgi_benchmark
RUN chown -R www-data:www-data /home/www/wsgi_benchmark
