# samba_strainer
# Version 0.0.2

FROM ubuntu:16.04
MAINTAINER Brad Woodward <brad@bradwoodward.io>

ADD files/start.sh /root/start.sh

RUN \
   apt-get update; \
   apt-get install -y samba dsyslog fail2ban vim php7.0-cli; \
   mkdir /samba; \
   useradd sharemgr; chown -R sharemgr:sambashare /samba; \
   useradd smbmedia; \
   useradd smbadmin; usermod -a -G sambashare brad; \
   (echo mediapass; echo mediapass) | smbpasswd -a -s smbmedia; \
   (echo adminpass; echo adminpass) | smbpasswd -a -s smbadmin;

ADD files/smb.conf /etc/samba/smb.conf.tpl
ADD files/dsyslog.conf /etc/dsyslog.conf

RUN \
   rm -Rf /etc/fail2ban; \
   touch /var/log/samba/log.audit;

ADD files/fail2ban /etc/fail2ban

RUN \
   php /etc/fail2ban/scripts/samba-denyuser.php genfile;

ENV HOME /root

VOLUME /samba
EXPOSE 139 445

CMD ["bash"]
