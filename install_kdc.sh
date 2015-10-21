#!/bin/sh

# Install packages
echo "Installing Kerberos Packages"
yum install -y krb5-server krb5-libs krb5-workstation

# #################################
# Assming default configuration!!!!
# #################################

# Create krb5.conf file
HOSTNAME=`hostname`
echo "Creating krb5.conf file, assuming KDC host is ${HOSTNAME}"
cat >/etc/krb5.conf <<EOF
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = EXAMPLE.COM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 EXAMPLE.COM = {
  kdc = ${HOSTNAME}
  admin_server = ${HOSTNAME}
 }

[domain_realm]
 .${HOSTNAME} = EXAMPLE.COM
 ${HOSTNAME} = EXAMPLE.COM
EOF

# Create KDC database
echo "Created KDC database, this could take some time"
kdb5_util create -s -P hadoop

# Create admistrative user
echo "Creating administriative account:"
echo "  principal:  admin/admin"
echo "  password:   hadoop"
kadmin.local -q 'addprinc -pw hadoop admin/admin'

# Starting services
echo "Starting services"
service krb5kdc start
service kadmin start

chkconfig krb5kdc on
chkconfig kadmin on
