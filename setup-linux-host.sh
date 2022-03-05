#!/bin/bash
# Version: 0.1.0 2022-03-05
# Apply some very basic settings to a Linux host 

# Settings to disable IPv6
if [ ! -f /etc/sysctl.d/99-IPv6-disable.conf ]; then
  echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/99-IPv6-disable.conf
  sysctl --system
else
  echo "  WARNING: Check that net.ipv6.conf.all.disable_ipv6 is set to 1:"
  cat /etc/sysctl.d/99-IPv6-disable.conf
fi

# Create user group used for users that are allowed to SSH into this host
if [ `getent group sshUsers` ]; then
  echo "  INFO:    Group sshUsers already exists!"
else
  echo "  INFO:    Group sshUsers does not exist"
  sshGroupId=888
  sshGroup="sshUsers"
  if [ ! $(getent group | grep ":${sshGroupId}:") ]; then
    echo "  INFO:    Add group sshUsers"
    groupadd -g ${sshGroupId} ${sshGroup}
  fi
fi


# Apply some OpenSSH settings
if [ ! -f /etc/ssh/sshd_config ]; then
  if [ -f /usr/etc/ssh/sshd_config ]; then
    cp /usr/etc/ssh/sshd_config /etc/ssh/
  else
    echo "  ERROR:   No sshd_config file found!"
  fi
fi

if [ -f /etc/ssh/sshd_config ]; then
  grep "^PermitRootLogin yes" /etc/ssh/sshd_config > /dev/null
  result=$?
  if [ ! "$result" -eq 0 ]; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  fi
  grep "AllowGroups sshUsers" /etc/ssh/sshd_config > /dev/null
  result=$?
  if [ ! "$result" -eq 0 ]; then
    echo "#AllowGroups sshUsers" >> /etc/ssh/sshd_config
  fi
  systemctl restart sshd
fi
