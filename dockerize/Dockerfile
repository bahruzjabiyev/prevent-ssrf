# (RUN on the host) sudo apt install module-init-tools; sudo modprobe ip6table_filter
# Dockerfile --build-arg `ip route | grep -o "via [^ ]*" | cut -d" " -f2`
FROM ubuntu:latest

RUN apt update -y
RUN apt install nginx -y
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt install php-fpm -y
RUN apt install php-curl -y
COPY index.php /var/www/html/
COPY default.conf /etc/nginx/sites-available/default
COPY netstat_output /
COPY harden.sh /
COPY localhost.key /
COPY localhost.crt /

RUN apt install net-tools -y
RUN apt install iputils-ping -y
RUN apt install netcat-openbsd -y
RUN apt install ufw -y

CMD chmod a+x /harden.sh && /harden.sh && tail -F /var/log/nginx/error.log

