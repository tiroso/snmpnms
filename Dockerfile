FROM ubuntu

MAINTAINER Tim Sobisch

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm


RUN touch /sbin/init
RUN apt-get update
RUN apt-get -y install \
		apt-utils  \
		procps \
		wget \
		git \
		gnupg \
		build-essential \
     libperl-dev \
		snmp \
		snmpd \
    gcc \
    file \
    make \
		apt-transport-https  \
		cpanminus \
						apt-utils  \
						procps \
						wget \
						python \
						gnupg \
						build-essential \
						dfu-programmer \
						etherwake \
						snmp \
						snmpd \
						usbutils \
						apt-transport-https  \
						telnet  \
						sqlite3  \
						libdbi-perl \ 
						libdbd-sqlite3-perl \
						cpanminus \
						libwww-perl\
						libsoap-lite-perl \
						libxml-parser-perl \
						libxml-parser-lite-perl \
						libnet-telnet-perl \
						libsnmp-perl
RUN wget -qO - https://debian.fhem.de/archive.key | apt-key add -
RUN echo "deb http://debian.fhem.de/nightly/ /" | tee -a /etc/apt/sources.list.d/fhem.list
RUN apt-get update
RUN apt-get -y install fhem 
 
RUN pkill -f "fhem.pl" \
	&& update-rc.d -f fhem remove \
	&& userdel fhem \
	&& rm /opt/fhem/log/*.log \
	&& mkdir /backup \
	&& usermod -aG dialout root \
	&& chmod -R a+w /opt \
	&& chown -R root:dialout /opt \ 
	&& apt-get clean  \
	&& apt-get autoclean  \
	&& apt-get autoremove -y  \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i '/global nofork/d' /opt/fhem/fhem.cfg \
	&& sed -i "1iattr global nofork 1" /opt/fhem/fhem.cfg



ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

COPY ./mibs /usr/share/snmp/mibs


CMD ["snmp-run"]
