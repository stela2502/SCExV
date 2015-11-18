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
<ol><li>cd &#60;path to the source&#62; </li><li>perl Makefile.PL </li><li>make </li><li>make install </li></ol>
To install the server files to your web path you should use the SCexV install.pl script scripts/install.pl. This script will take care of access rights, copy all required files and changes all links inside the server files to support install into a subpath. In other words it is absolutely not recommended to copy the source files to your web path by hand. 
</p>
## install.pl usage

<p>command line switches for install.pl</p>

<table>
<tr><td>-install_path</td><td>your server path</td></tr>
<tr><td>-server_user</td><td>the system user that needs to have access to all files</td></tr>
<tr><td>-web_root</td><td>the root of the web server - css and jscript files are installed there (default to '/var/www/html/')</td></tr>
<tr><td>-options</td><td>additional option for the SCexV server like  randomForest 1 ncore 4 </td></tr>
<tr><td>-help</td><td>print this help </td></tr>
<tr><td>-debug</td><td>verbose output </td></tr></table>

<p>This script will copy the required files from &#60;path to the source&#62;/root into the install_path. If the web_root is not the same as the install_path all internal links are changed.</p>

# Troubleshooting

<p>If the installed server does not work I recommend using the t/001app.t test script:
<ol><li>cd &#60;path to the source&#62;</li><li>perl -I lib t/001app.t </li></ol>
The output from this script should help to pinpoint the missing parts. If this test script does work without error the problem is web server specific and I can not help you.</p>

# Example installation

<p>You can access our installation at <a href="http://stemsysbio.bmc.lu.se/SCexV/">stemsysbio.bmc.lu.se/SCexV/</a>. For more help on the usage please check out our instructional videos on <a href="https://www.youtube.com/channel/UC8NmNbIEkMt4sjWxgL8_aEw">our YouTube channel</a>.</p>
