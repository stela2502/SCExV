# SCExV
SCExV: a webtool for the analysis and visualisation of single cell qRT-PCR data
# Requirements
All required Perl packages are installed from cpan during the install procedure, but my Stefans_Libs_Essentials which you can get from github.
R packages:
abind, boot, cluster, ggplot2, gplots, Hmisc, MASS, MAST, RDRToolbox, reshape, rgl, RSvgDevice, stringr, survival, vioplot
Apache or any other supported web server.
# Install
<p>The software is tested on Fedora 20 and CentOS 7.0 using apache2, but should install on any other linux distribution.</p>
<p>Obtain and install <a hrep="https://github.com/stela2502/Stefans_Lib_Esentials">my Stefans_Lib_Essentials Perl library</a>.</p>
<p>Download this source and install it using the Perl make procedure: 
1. cd <path to the source> 
2. perl Makefile.PL 
3. make 
4. make install 
To install the server files to your web path you should use the SCexV install.pl script scripts/install.pl. This script will take care of access rights, copy all required files and changes all links inside the server files to support install into a subpath. In other words it is absolutely not recommended to copy the source files to your web path by hand. 
</p>

# Troubleshooting

<p>If the installed server does not work I recommend using the t/001app.t test script:
1. cd <path to the source> 
2. perl -I lib t/001app.t 
The output from this script should help to pinpoint the missing parts. If this test script does work without error the problem is web server specific and I can not help you.</p>
