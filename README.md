# SambaStrainer Container

## Purpose
This project was created to add a protective barrier between clients and data made available through a network share. Specifically to combat ransomware.

## Method
This container bundles samba-vfs, dsyslog, and fail2ban to monitor for, and automatically terminate, excessive modifications to the filesystem.

### Samba-vfs
Samba-vfs extends the logging of samba to include certain activities. By default, the Samba Strainer container is configured to monitor 'rename', 'create_file', 'unlink' (delete), 'rmdir', and 'mkdir' calls. This can be configured by modifying the settings for 'full_audit:success' in 'files/smb.conf'.

### dsyslog
Receives events from samba-vfs, specifically using the 'local7' facility to output to /var/log/samba/log.audit. You shouldn't ever need to modify this.

### fail2ban
This is where the magic happens. Fail2ban uses a custom filter to monitor the /var/log/samba/log.audit. If too many actions occur from a single IP, fail2ban will identify the offending user, and disable their samba account and terminate all connections from the offending IP. If multiple users originate from the same IP, the SMB client should automatically reconnect without any persistent issue. The offending user, however, will received an 'access denied' until the ban expires, or until their samba account is enabled manually.

- Filter: /etc/fail2ban/filter.d/samba-vfs.conf
  - All all logged actions for a particular IP will count toward the action limit.

- Jail:   /etc/fail2ban/jail.local
  - maxretries: Action limit, if exceeded within the findtime window, the banaction will occur. Default: 20 actions.
  - findtime:   The scrolling window of time within which <maxretries> actions must occur. Default: 60 seconds.
  - bantime:    The amount of time that will pass before the unbanaction will occur. Default: 30 seconds.

- Action: /etc/fail2ban/action.d/samba-disableuser.conf
- Script: /etc/fail2ban/script/samba-disableuser.sh

## How to use
1. Clone the repo, and cd into the repo folder.
2. Edit the 'continer.sh' file to suit your needs.
  - Change 'EXTIFACE' to your bridge interface.
  - Change 'HOSTDATA' to the folder to be shared via Samba.
3. Change the default users and passwords in the Dockerfile
  - Edit/Clone the 'smbadmin' line for users that will have write access.
  - Edit/Clone the 'smbmedia' line for users that will never have write access.
4. Edit your shares in files/smb.conf
5. Build the container image with './container.sh build'.
6. Run the container with './container.sh run'.
7. Connect to the container's IP via UNC or SMB://, and enter the credentials you entered into the Dockerfile.

## Caveats
This has only been tested (and is only currently configured to work) with a local user database, but the framework is there to test with a back-end LDAP store.
