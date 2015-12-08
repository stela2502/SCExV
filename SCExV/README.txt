Installation:

You need:
  - a working X system (Xvfb does work for headless servers)
  - R and several R packages described in scripts/Install.R
  - Perl Catalyst
  - apache2 web server (untested with other configurations)
 

INSTALLATION TESTED USING CentOS 6.5 !! NOTHING ELSE

Install the server files:

perl script/install.pl -install_path <your path> -server_user <the httpd user>

The server user for Ubuntu 12.04 is www-data CentOD 6.5 uses apache





The apache2 configuration:

For my installation on CentOS 6.5 I placed this file into /etc/httpd/conf.d/001_Fluedigm_Analysis.conf

<VirtualHost *:80>
        ServerName localhost
        ServerAdmin email@host
        HostnameLookups Off
        UseCanonicalName Off
        DocumentRoot    <your path>/root/
        <Location />
                SetHandler modperl
                PerlResponseHandler Plack::Handler::Apache2
                PerlSetVar psgi_app "<your path>/PCR_analysis.psgi"
        </Location>
</VirtualHost>


Installation of the Xvfb Xserver
yum install xorg-x11-server-Xvfb xorg-x11-server-Xorg xorg-x11-fonts*

The Xvfb process needs to be started with every reboot

create a file  /etc/init.d/Xvfb 

#!/bin/bash
#chkconfig: 345 95 50
#description: Starts xvfb on display 99
if [ -z "$1" ]; then
    echo "`basename $0` {start|stop}"
    exit
fi

case "$1" in
  start)
     /usr/bin/Xvfb :7 -screen 0 1280x1024x24 &
 ;;

 stop)
     killall Xvfb
 ;;
esac

ln -s /etc/init.d/Xvfb /etc/rc0.d/K14xvfb
ln -s /etc/init.d/Xvfb /etc/rc3.d/S81xvfb

Working

Check it by setting the 
DISPLAY=:7
Shell varable and execute
xdpyinfo




SElinunx configuration:

Some helpful commands:

show the SElinux properties of files
ls -Z 

list recent problems with SElinux:
ausearch -m avc --start recent

setenforce 1 0


getsebool -a

sesearch --allow --source httpd_t


Two problems arise using this server in a none standard server path

(1) httpd is not allowed to access this path

Easy fix:
chcon -R system_u:object_r:httpd_sys_content_t:s0 <your path>
chcon -R system_u:object_r:httpd_sys_rw_content_t:s0 <your path>/root/tmp/

(2) httpd must not connect to the X server

That is more complicated - solution found on http://www.city-fan.org/tips/BuildSeLinuxPolicyModules

you need the policycoreutils-devel package

become root
cd /root
mkdir selinux.local
cd selinux.local
chcon -R -t usr_t .
ln -s /usr/share/selinux/devel/Makefile . 
yum update selinux-policy\* libse\* policycoreutils
grep 'comm="R"' /var/log/audit/audit.log | grep unix_stream_socket | tail -n2 |  grep 'comm="R"' /var/log/audit/audit.log | grep unix_stream_socket | tail -n2 | audit2allow -R > httpd_allow_x_connect.te
make
semodule -i httpd_allow_x_connect.pp

After that the server did work

Not the second time....
ausearch -c R | tail -n2 | audit2allow -R > httpd_allow_xserver_port.te
## I found out, that I am missing some unconfined_stream_connect ability
## add the line 'policy_module(httpd_allow_xserver_port, 0.1.0)'
## to the file httpd_allow_xserver_port.te
make
semodule -i httpd_allow_xserver_port.pp


Further configuration:

The server contains an inbuilt error reporting function. Whenever a user identifies an error he/she should use the Menu->'Go To'->'Error Report' page to report this error.
The page will ask the user about the last step taken and produce a snapshot error report.

The server has no inbuilt reporting system, but checks for a executable in /usr/local/bin named 'report_SCexV_error.pl'.
The server will call this script with the -error_file option giving the absolute location on the server.
Implement your own error reporting functionality for your server installation if you want to get the error report.
Otherwise you can periodically check the <server path>/tmp/ path for new Error_report_*.zip files.
