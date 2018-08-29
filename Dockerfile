FROM debian:stretch

MAINTAINER Tim Sobisch

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm


RUN touch /sbin/init
RUN apt-get update
RUN apt-get -y install \
		apt-utils  \
		procps \
		wget \
		gnupg \
		build-essential \
     libperl-dev \
    gcc \
    file \
    make \
		apt-transport-https  \
		cpanminus
RUN echo "deb http://debian.fhem.de/nightly/ /" | tee -a /etc/apt/sources.list.d/fhem.list
RUN apt-get update
RUN apt-get -y install \
		fhem 
 
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

RUN wget http://sourceforge.net/projects/net-snmp/files/net-snmp/5.8/net-snmp-5.8.tar.gz

RUN tar -xvzf net-snmp-5.8.tar.gz

RUN mv net-snmp-5.8 net-snmp

WORKDIR ("net-snmp")

RUN ./configure --with-perl-modules

RUN make

RUN make install

WORKDIR ("perl")

RUN cp MakefileSubs.pm /etc/perl/MakefileSubs.pm

RUN perl Makefile.PL

RUN make

RUN make test

RUN make install
WORKDIR ("/opt/fhem")
CMD ("perl fhem.pl fhem.cfg")
