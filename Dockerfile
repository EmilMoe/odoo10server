FROM amd64/ubuntu:latest
MAINTAINER Emil Moe
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y software-properties-common
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install systemd sudo cron git gdebi-core nodejs npm libsasl2-dev default-jre bzr wkhtmltopdf libgconf-2-4
RUN npm install -g less less-plugin-clean-css
RUN ln -sf /usr/local/bin/wkhtmltopdf /usr/bin
RUN ln -sf /usr/local/bin/wkhtmltoimage /usr/bin

RUN adduser odoo --disabled-password
RUN echo "local ALL = NOPASSWD: ALL" >> /etc/sudoers

# POSTGRESSQL
RUN apt-get install -y postgresql postgresql-contrib

USER postgres

RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER odoo WITH SUPERUSER PASSWORD 'odoo';" &&\
    createdb -O odoo odoo

USER root

RUN sed -i "s/^#listen_addresses.*/listen_addresses = '*'/" /etc/postgresql/10/main/postgresql.conf 
RUN sh -c 'echo "host  all   all   all     password" >> /etc/postgresql/10/main/pg_hba.conf'
RUN sh -c 'echo "local  all   odoo   all     trust" >> /etc/postgresql/10/main/pg_hba.conf'

# PYTHON 2
RUN apt-get install -y libxml2-dev libxslt1-dev zlib1g-dev libldap2-dev libssl-dev
RUN apt-get install -y libjpeg-dev libfreetype6 libfreetype6-dev zlib1g-dev
RUN apt-get install -y python2.7 python-pip 
# python-imaging python-ebaysdk python-jcconv python-pyserial python-pytz python-pyusb
RUN apt-get install -y python-pil idle python-babel python-dateutil python-decorator python-docutils python-feedparser python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-requests python-suds python-tz python-vatnumber python-vobject python-werkzeug python-xlsxwriter python-xlwt python-yaml python-gevent python-greenlet python-markupsafe python-ofxparse python-pillow python-psycogreen python-qrcode python-six python-xlrd python-wsgiref python-pypdf2 python-simplejson python-webdav python-zsi python-unittest2 python-pil python-libsass
RUN pip install pillow suds-jurko Python-Chart num2words pyPdf pyyaml html2text ninja2 gdata chardet libsass ebaysdk jcconv pyserial pytz pyusb

# PYTHON 3
#RUN apt-get install -y python3-pip python3.6
#RUN apt-get install -y python3-pydot  python3-pyldap  python3-pyparsing python3-vatnumber  python3-vobject  python3-werkzeug  python3-xlrd  python3-xlwt python3-pytz  python3-pyusb  python3-qrcode  python3-reportlab	 python3-stdnum  python3-suds python3-mako  python3-mock  python3-num2words python3-ofxparse  python3-passlib  python3-psycopg2 babel libxslt-python nodejs-less pychart pyparsing  python3-babel python3-decorator python3-docutils  python3-feedparser  python3-gevent  python3-greenlet  python3-html2text  python3-lxml python3-pypdf2 python3-psycopg2 python3-psutil python3-jinja2 python3-libsass
#RUN pip3 install num2words phonenumbers

# ODOO 10
RUN git clone --depth 1 --branch 10.0 https://github.com/odoo/odoo.git /var/odoo10/odoo10-server
RUN touch /etc/odoo10-server.conf
RUN mkdir /home/odoo/addons_10
RUN su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'admin_passwd = admin\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'xmlrpc_port = 8069\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'logfile = /var/log/odoo10.log\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'addons_path=/home/odoo/addons_10,/var/odoo10/odoo10-server/addons,$/var/odoo10/odoo10-server/custom/addons\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'db_name=odoo10\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'db_user=odoo\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'dbfilter=odoo10\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'db_host=False\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'db_port=False\n' >> /etc/odoo10-server.conf"
RUN su root -c "printf 'db_password=False\n' >> /etc/odoo10-server.conf"

RUN chown odoo:odoo /etc/odoo10-server.conf
RUN chmod 640 /etc/odoo10-server.conf
RUN chown -R odoo:odoo /var/odoo10/odoo10-server
RUN chown -R odoo:odoo /var/odoo10/odoo10-server/*
RUN chown -R odoo:odoo /home/odoo/addons_10

#COPY ./entrypoint.sh /
EXPOSE 8069 8071
ENV ODOO_RC /etc/odoo10-server.conf
USER odoo

ENTRYPOINT /var/odoo10/odoo10-server/odoo-bin

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["odoo"]
