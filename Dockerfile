# samba_strainer
# Version 0.0.2

FROM ubuntu:16.04
MAINTAINER Brad Woodward <brad@bradwoodward.io>

ADD files/start.sh /root/start.sh

RUN \
   apt-get update; \
   apt-get install -y samba dsyslog fail2ban vim; \
   mkdir /samba; \
   useradd sharemgr; chown -R sharemgr:sambashare /samba; \
   useradd smbmedia; \
   useradd smbadmin; usermod -a -G sambashare smbadmin; \
   (echo mediapass; echo mediapass) | smbpasswd -a -s smbmedia; \
   (echo adminpass; echo adminpass) | smbpasswd -a -s smbadmin;

ADD files/smb.conf /etc/samba/smb.conf
ADD files/dsyslog.conf /etc/dsyslog.conf

RUN \
   rm -Rf /etc/fail2ban; \
   touch /var/log/samba/log.audit;

ADD files/fail2ban.tgz /

ENV HOME /root

VOLUME /samba
EXPOSE 139 445

CMD ["bash"]
