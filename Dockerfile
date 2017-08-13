FROM centos:latest

LABEL maintainer packetferret@gmail.com

WORKDIR /opt

ENV ANSIBLE_TOWER_VER 3.1.4
ENV PG_DATA /var/lib/postgresql/9.4/main

RUN yum -y update
RUN yum -y groupinstall "Development tools"
RUN yum -y install python-devel
RUN yum -y install openssl
RUN yum -y install gcc
RUN yum -y install zlib-devel
RUN yum -y install bzip2-devel
RUN yum -y install openssl-devel
RUN yum -y install ncurses-devel
RUN yum -y install sqlite-devel
RUN yum -y install wget
RUN yum -y install curl


# Use python >= 2.7.9
RUN wget --no-check-certificate https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz
RUN tar xf Python-2.7.13.tar.xz
WORKDIR Python-2.7.13
RUN ./configure --prefix=/usr/local --enable-shared --enable-unicode=ucs4
RUN make && make altinstall


# create /var/log/tower
RUN mkdir -p /var/log/tower

WORKDIR /tmp/
# Download & extract Tower tarball
ADD http://releases.ansible.com/awx/setup/ansible-tower-setup-3.1.4.tar.gz ansible-tower-setup-3.1.4.tar.gz

RUN mv ansible-tower-setup-3.1.4.tar.gz/ansible-tower-setup-3.1.4 /opt/
WORKDIR /opt/ansible-tower-setup-3.1.4
ADD inventory inventory

# Tower setup
RUN ./setup.sh

# Docker entrypoint script
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# volumes and ports
VOLUME ["${PG_DATA}", "/certs"]
EXPOSE 443

CMD ["/docker-entrypoint.sh", "ansible-tower"]
