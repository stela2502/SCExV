set PERL_MM_USE_DEFAULT=1
perl -MCPAN -e "notest('install', 'HTTP::Server::Simple', 'WWW::Mechanize');"
cpan Moose
## I had to force moose!
cpan 'Catalyst::Runtime Catalyst::Devel'

## install ssh development files

yum install libssh2-devel.x86_64

## now get the source files for the server and run a 
perl Makefile.PL 
## in its source folder followed by 
make
## which will install all missing prerequistes for you using cpan.


##copy the psgi script to /var/www/cgi-bin/
cp ../htpcra.psgi /var/www/cgi-bin/

cpan 'Catalyst::Runtime Catalyst::Devel'

