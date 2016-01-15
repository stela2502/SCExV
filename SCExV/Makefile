# This Makefile is for the HTpcrA extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.66 (Revision: 66600) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     ABSTRACT => q[Catalyst based application]
#     AUTHOR => [q[Stefan Lang]]
#     BUILD_REQUIRES => { Test::More=>q[0.88], ExtUtils::MakeMaker=>q[6.36], jQuery::File::Upload=>q[0] }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[HTpcrA]
#     EXE_FILES => [q[script/capture_rgl_javascript.pl], q[script/CleanTemp.pl], q[script/htpcra_cgi.pl], q[script/htpcra_create.pl], q[script/htpcra_fastcgi.pl], q[script/htpcra_server.pl], q[script/htpcra_test.pl], q[script/install.pl], q[script/libPatcher.pl], q[script/minimize_css.pl]]
#     LICENSE => q[perl]
#     NAME => q[HTpcrA]
#     NO_META => q[1]
#     PREREQ_PM => { Moose=>q[0], Catalyst::Plugin::Session=>q[0], GD::SVG=>q[0], jQuery::File::Upload=>q[0], Catalyst::Plugin::Static::Simple=>q[0], Catalyst::Plugin::ErrorCatcher=>q[0], Catalyst::Plugin::SecureCookies=>q[0], Catalyst::Action::RenderView=>q[0], Date::Simple=>q[0], namespace::autoclean=>q[0], Catalyst::Runtime=>q[5.90019], ExtUtils::MakeMaker=>q[6.36], Catalyst::Plugin::ConfigLoader=>q[0], Catalyst::Plugin::Session::Store::FastMmap=>q[0], Number::Format=>q[0], Catalyst::Plugin::Session::State::Cookie=>q[0], Catalyst::View::TT=>q[0], Catalyst::Plugin::FormBuilder=>q[0], Catalyst::Model::Factory::PerRequest=>q[0], Statistics::Descriptive=>q[0], Test::More=>q[0.88], Catalyst::Plugin::RequireSSL=>q[0], Config::General=>q[0], HTML::Template=>q[0], DateTime::Format::MySQL=>q[0] }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.90]
#     VERSION_FROM => q[lib/HTpcrA.pm]
#     dist => {  }
#     realclean => { FILES=>q[MYMETA.yml] }
#     test => { TESTS=>q[t/01app.t t/02_1_app_RandomForest.t t/02_3_dropSamples_only.t t/02_4_check_analysis_page.t t/02pod.t t/03podcoverage.t t/Check_01.1_input_multiple_files_R.t t/Check_01_input_files_R.t t/Check_04_analysis_R.t t/controller_analyse.t t/controller_Coexpression.t t/controller_Error.t t/controller_fluidigm_analysis.t t/controller_gene_group.t t/controller_grouping_2d.t t/controller_help.t t/controller_PValues.t t/controller_RandomForest.t t/controller_test.t t/data_table_2.t t/help_data.t t/model_Coexpr.t t/model_java_splicer.t t/model_mechanize.t t/model_PValues.t t/model_RandomForest_recieve.t t/model_RandomForest_send.t t/model_RandomForest_x_send_to_server.t t/model_rgl3dplots.t t/regroup_logics.t t/simpleBarGraph.t t/stefans_libs_Description.t t/stefans_libs_file_readers_Fluidigm_Raw_Tables.t t/stefans_libs_GeneGroup_4_newInitialPlot.t t/stefans_libs_GeneGroups.t t/stefans_libs_GeneGroups_2.t t/stefans_libs_GeneGroups_3.t t/stefans_libs_GeneGroups_R_table.t t/stefans_libs_GeneGroups_Set.t t/stefans_libs_HTpcrA_Menus.t t/stefans_libs_HTpcrA_methods.t t/stefans_libs_HTpcrA_ScrapBook.t t/view_TT.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/perl/5.18/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = cc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = cc
LDDLFLAGS = -shared -L/usr/local/lib -fstack-protector
LDFLAGS =  -fstack-protector -L/usr/local/lib
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 3.2.0-58-generic
RANLIB = :
SITELIBEXP = /usr/local/share/perl/5.18.2
SITEARCHEXP = /usr/local/lib/perl/5.18.2
SO = so
VENDORARCHEXP = /usr/lib/perl5
VENDORLIBEXP = /usr/share/perl5


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = HTpcrA
NAME_SYM = HTpcrA
VERSION = 0.90
VERSION_MACRO = VERSION
VERSION_SYM = 0_90
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.90
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1p
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = /usr
PERLPREFIX = $(PREFIX)
SITEPREFIX = $(PREFIX)/local
VENDORPREFIX = $(PREFIX)
INSTALLPRIVLIB = $(PERLPREFIX)/share/perl/5.18
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(SITEPREFIX)/share/perl/5.18.2
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = $(VENDORPREFIX)/share/perl5
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(PERLPREFIX)/lib/perl/5.18
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(SITEPREFIX)/lib/perl/5.18.2
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = $(VENDORPREFIX)/lib/perl5
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(PERLPREFIX)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(SITEPREFIX)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(VENDORPREFIX)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(PERLPREFIX)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = $(SITEPREFIX)/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = $(VENDORPREFIX)/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = $(PERLPREFIX)/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(SITEPREFIX)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(VENDORPREFIX)/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(PERLPREFIX)/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(SITEPREFIX)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(VENDORPREFIX)/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /usr/lib/perl/5.18
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/perl/5.18/CORE
PERL = /usr/bin/perl "-Iinc"
FULLPERL = /usr/bin/perl "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/share/perl/5.18/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.66
MM_REVISION = 66600

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = HTpcrA
BASEEXT = HTpcrA
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/HTpcrA.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = script/CleanTemp.pl \
	script/htpcra_cgi.pl \
	script/htpcra_create.pl \
	script/htpcra_fastcgi.pl \
	script/htpcra_server.pl \
	script/htpcra_test.pl \
	script/install.pl \
	script/libPatcher.pl \
	script/minimize_css.pl
MAN3PODS = lib/CatalystX/Profile_SL.pm \
	lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm \
	lib/HTpcrA.pm \
	lib/HTpcrA/Controller/Coexpression.pm \
	lib/HTpcrA/Controller/DropGenes.pm \
	lib/HTpcrA/Controller/DropSamples.pm \
	lib/HTpcrA/Controller/Error.pm \
	lib/HTpcrA/Controller/Filemerger.pm \
	lib/HTpcrA/Controller/Files.pm \
	lib/HTpcrA/Controller/PValues.pm \
	lib/HTpcrA/Controller/RandomForest.pm \
	lib/HTpcrA/Controller/Regroup.pm \
	lib/HTpcrA/Controller/Root.pm \
	lib/HTpcrA/Controller/Scrapbook.pm \
	lib/HTpcrA/Controller/analyse.pm \
	lib/HTpcrA/Controller/gene_group.pm \
	lib/HTpcrA/Controller/grouping_2d.pm \
	lib/HTpcrA/Controller/help.pm \
	lib/HTpcrA/EnableFiles.pm \
	lib/HTpcrA/Model/Coexpr.pm \
	lib/HTpcrA/Model/GeneGroups.pm \
	lib/HTpcrA/Model/HelpFile.pm \
	lib/HTpcrA/Model/Menu.pm \
	lib/HTpcrA/Model/MethodsSection.pm \
	lib/HTpcrA/Model/PCR_Raw_Files.pm \
	lib/HTpcrA/Model/PValues.pm \
	lib/HTpcrA/Model/RandomForest.pm \
	lib/HTpcrA/Model/java_splicer.pm \
	lib/HTpcrA/Model/mech.pm \
	lib/HTpcrA/Model/rgl3dplots.pm \
	lib/HTpcrA/Model/scrapbook.pm \
	lib/HTpcrA/View/HTML.pm \
	lib/stefans_libs/Description.pm \
	lib/stefans_libs/GeneGroups.pm \
	lib/stefans_libs/GeneGroups/R_table.pm \
	lib/stefans_libs/GeneGroups/Set.pm \
	lib/stefans_libs/HTpcrA/Menue.pm \
	lib/stefans_libs/HTpcrA/ScrapBook.pm \
	lib/stefans_libs/HTpcrA/methods.pm \
	lib/stefans_libs/file_readers/PCR_Raw_Tables.pm \
	lib/stefans_libs/file_readers/Patcher.pm \
	lib/stefans_libs/flexible_data_structures/BinList.pm \
	lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm \
	lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm \
	lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm \
	lib/stefans_libs/plot_old/axis.pm \
	lib/stefans_libs/root.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/.gitignore \
	lib/CatalystX/Profile_SL.pm \
	lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm \
	lib/CatalystX/Profile_SL/Controller/nytprof.out \
	lib/CatalystX/nytprof.out \
	lib/HTpcrA.pm \
	lib/HTpcrA/Controller/Coexpression.pm \
	lib/HTpcrA/Controller/DropGenes.pm \
	lib/HTpcrA/Controller/DropSamples.pm \
	lib/HTpcrA/Controller/Error.pm \
	lib/HTpcrA/Controller/Filemerger.pm \
	lib/HTpcrA/Controller/Files.pm \
	lib/HTpcrA/Controller/PValues.pm \
	lib/HTpcrA/Controller/RandomForest.pm \
	lib/HTpcrA/Controller/Regroup.pm \
	lib/HTpcrA/Controller/Root.pm \
	lib/HTpcrA/Controller/Scrapbook.pm \
	lib/HTpcrA/Controller/analyse.pm \
	lib/HTpcrA/Controller/gene_group.pm \
	lib/HTpcrA/Controller/grouping_2d.pm \
	lib/HTpcrA/Controller/help.pm \
	lib/HTpcrA/EnableFiles.pm \
	lib/HTpcrA/Model/Coexpr.pm \
	lib/HTpcrA/Model/GeneGroups.pm \
	lib/HTpcrA/Model/HelpFile.pm \
	lib/HTpcrA/Model/Menu.pm \
	lib/HTpcrA/Model/MethodsSection.pm \
	lib/HTpcrA/Model/PCR_Raw_Files.pm \
	lib/HTpcrA/Model/PValues.pm \
	lib/HTpcrA/Model/RandomForest.pm \
	lib/HTpcrA/Model/java_splicer.pm \
	lib/HTpcrA/Model/mech.pm \
	lib/HTpcrA/Model/rgl3dplots.pm \
	lib/HTpcrA/Model/scrapbook.pm \
	lib/HTpcrA/View/HTML.pm \
	lib/htpcr.conf.useless \
	lib/htpcra.conf \
	lib/stefans_libs/Description.pm \
	lib/stefans_libs/GeneGroups.pm \
	lib/stefans_libs/GeneGroups/R_table.pm \
	lib/stefans_libs/GeneGroups/Set.pm \
	lib/stefans_libs/HTpcrA/Menue.pm \
	lib/stefans_libs/HTpcrA/ScrapBook.pm \
	lib/stefans_libs/HTpcrA/methods.pm \
	lib/stefans_libs/file_readers/PCR_Raw_Tables.pm \
	lib/stefans_libs/file_readers/Patcher.pm \
	lib/stefans_libs/file_readers/help_data.pm \
	lib/stefans_libs/flexible_data_structures/BinList.pm \
	lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm \
	lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm \
	lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm \
	lib/stefans_libs/plot_old/Font.pm \
	lib/stefans_libs/plot_old/axis.pm \
	lib/stefans_libs/plot_old/color.pm \
	lib/stefans_libs/root.pm

PM_TO_BLIB = lib/CatalystX/nytprof.out \
	blib/lib/CatalystX/nytprof.out \
	lib/HTpcrA/Controller/DropSamples.pm \
	blib/lib/HTpcrA/Controller/DropSamples.pm \
	lib/HTpcrA/EnableFiles.pm \
	blib/lib/HTpcrA/EnableFiles.pm \
	lib/HTpcrA/Model/Menu.pm \
	blib/lib/HTpcrA/Model/Menu.pm \
	lib/CatalystX/Profile_SL/Controller/nytprof.out \
	blib/lib/CatalystX/Profile_SL/Controller/nytprof.out \
	lib/HTpcrA/Controller/Regroup.pm \
	blib/lib/HTpcrA/Controller/Regroup.pm \
	lib/stefans_libs/root.pm \
	blib/lib/stefans_libs/root.pm \
	lib/stefans_libs/file_readers/Patcher.pm \
	blib/lib/stefans_libs/file_readers/Patcher.pm \
	lib/HTpcrA/Model/mech.pm \
	blib/lib/HTpcrA/Model/mech.pm \
	lib/HTpcrA/Model/rgl3dplots.pm \
	blib/lib/HTpcrA/Model/rgl3dplots.pm \
	lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm \
	blib/lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm \
	lib/stefans_libs/plot_old/color.pm \
	blib/lib/stefans_libs/plot_old/color.pm \
	lib/HTpcrA/Controller/Filemerger.pm \
	blib/lib/HTpcrA/Controller/Filemerger.pm \
	lib/HTpcrA/Controller/PValues.pm \
	blib/lib/HTpcrA/Controller/PValues.pm \
	lib/htpcra.conf \
	blib/lib/htpcra.conf \
	lib/HTpcrA/Controller/gene_group.pm \
	blib/lib/HTpcrA/Controller/gene_group.pm \
	lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm \
	blib/lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm \
	lib/HTpcrA/Model/PCR_Raw_Files.pm \
	blib/lib/HTpcrA/Model/PCR_Raw_Files.pm \
	lib/HTpcrA/Controller/help.pm \
	blib/lib/HTpcrA/Controller/help.pm \
	lib/stefans_libs/Description.pm \
	blib/lib/stefans_libs/Description.pm \
	lib/HTpcrA/Model/scrapbook.pm \
	blib/lib/HTpcrA/Model/scrapbook.pm \
	lib/HTpcrA/Controller/RandomForest.pm \
	blib/lib/HTpcrA/Controller/RandomForest.pm \
	lib/stefans_libs/plot_old/axis.pm \
	blib/lib/stefans_libs/plot_old/axis.pm \
	lib/HTpcrA/Model/RandomForest.pm \
	blib/lib/HTpcrA/Model/RandomForest.pm \
	lib/.gitignore \
	blib/lib/.gitignore \
	lib/stefans_libs/GeneGroups.pm \
	blib/lib/stefans_libs/GeneGroups.pm \
	lib/stefans_libs/HTpcrA/ScrapBook.pm \
	blib/lib/stefans_libs/HTpcrA/ScrapBook.pm \
	lib/HTpcrA.pm \
	blib/lib/HTpcrA.pm \
	lib/HTpcrA/View/HTML.pm \
	blib/lib/HTpcrA/View/HTML.pm \
	lib/HTpcrA/Controller/Files.pm \
	blib/lib/HTpcrA/Controller/Files.pm \
	lib/htpcr.conf.useless \
	blib/lib/htpcr.conf.useless \
	lib/HTpcrA/Model/java_splicer.pm \
	blib/lib/HTpcrA/Model/java_splicer.pm \
	lib/stefans_libs/plot_old/Font.pm \
	blib/lib/stefans_libs/plot_old/Font.pm \
	lib/HTpcrA/Model/GeneGroups.pm \
	blib/lib/HTpcrA/Model/GeneGroups.pm \
	lib/stefans_libs/file_readers/help_data.pm \
	blib/lib/stefans_libs/file_readers/help_data.pm \
	lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm \
	blib/lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm \
	lib/stefans_libs/HTpcrA/methods.pm \
	blib/lib/stefans_libs/HTpcrA/methods.pm \
	lib/stefans_libs/flexible_data_structures/BinList.pm \
	blib/lib/stefans_libs/flexible_data_structures/BinList.pm \
	lib/HTpcrA/Model/HelpFile.pm \
	blib/lib/HTpcrA/Model/HelpFile.pm \
	lib/CatalystX/Profile_SL.pm \
	blib/lib/CatalystX/Profile_SL.pm \
	lib/HTpcrA/Model/MethodsSection.pm \
	blib/lib/HTpcrA/Model/MethodsSection.pm \
	lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm \
	blib/lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm \
	lib/HTpcrA/Controller/Error.pm \
	blib/lib/HTpcrA/Controller/Error.pm \
	lib/stefans_libs/GeneGroups/R_table.pm \
	blib/lib/stefans_libs/GeneGroups/R_table.pm \
	lib/stefans_libs/file_readers/PCR_Raw_Tables.pm \
	blib/lib/stefans_libs/file_readers/PCR_Raw_Tables.pm \
	lib/stefans_libs/GeneGroups/Set.pm \
	blib/lib/stefans_libs/GeneGroups/Set.pm \
	lib/HTpcrA/Controller/Scrapbook.pm \
	blib/lib/HTpcrA/Controller/Scrapbook.pm \
	lib/HTpcrA/Controller/grouping_2d.pm \
	blib/lib/HTpcrA/Controller/grouping_2d.pm \
	lib/HTpcrA/Controller/Root.pm \
	blib/lib/HTpcrA/Controller/Root.pm \
	lib/HTpcrA/Model/PValues.pm \
	blib/lib/HTpcrA/Model/PValues.pm \
	lib/HTpcrA/Controller/Coexpression.pm \
	blib/lib/HTpcrA/Controller/Coexpression.pm \
	lib/HTpcrA/Model/Coexpr.pm \
	blib/lib/HTpcrA/Model/Coexpr.pm \
	lib/HTpcrA/Controller/DropGenes.pm \
	blib/lib/HTpcrA/Controller/DropGenes.pm \
	lib/HTpcrA/Controller/analyse.pm \
	blib/lib/HTpcrA/Controller/analyse.pm \
	lib/stefans_libs/HTpcrA/Menue.pm \
	blib/lib/stefans_libs/HTpcrA/Menue.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.66
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = HTpcrA
DISTVNAME = HTpcrA-0.90


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	LD="$(LD)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	script/htpcra_create.pl \
	script/libPatcher.pl \
	script/htpcra_fastcgi.pl \
	script/minimize_css.pl \
	script/htpcra_test.pl \
	script/CleanTemp.pl \
	script/htpcra_server.pl \
	script/install.pl \
	script/htpcra_cgi.pl \
	lib/HTpcrA/Model/Menu.pm \
	lib/HTpcrA/EnableFiles.pm \
	lib/HTpcrA/Controller/DropSamples.pm \
	lib/HTpcrA/Model/rgl3dplots.pm \
	lib/HTpcrA/Model/mech.pm \
	lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm \
	lib/stefans_libs/file_readers/Patcher.pm \
	lib/stefans_libs/root.pm \
	lib/HTpcrA/Controller/Regroup.pm \
	lib/HTpcrA/Controller/help.pm \
	lib/HTpcrA/Model/PCR_Raw_Files.pm \
	lib/HTpcrA/Controller/gene_group.pm \
	lib/HTpcrA/Controller/PValues.pm \
	lib/HTpcrA/Controller/Filemerger.pm \
	lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm \
	lib/stefans_libs/plot_old/axis.pm \
	lib/stefans_libs/GeneGroups.pm \
	lib/HTpcrA/Model/RandomForest.pm \
	lib/HTpcrA/Model/scrapbook.pm \
	lib/stefans_libs/Description.pm \
	lib/HTpcrA/Controller/RandomForest.pm \
	lib/HTpcrA/Controller/Files.pm \
	lib/HTpcrA/View/HTML.pm \
	lib/HTpcrA.pm \
	lib/HTpcrA/Model/java_splicer.pm \
	lib/stefans_libs/HTpcrA/ScrapBook.pm \
	lib/HTpcrA/Model/HelpFile.pm \
	lib/stefans_libs/flexible_data_structures/BinList.pm \
	lib/CatalystX/Profile_SL.pm \
	lib/HTpcrA/Model/MethodsSection.pm \
	lib/HTpcrA/Model/GeneGroups.pm \
	lib/stefans_libs/HTpcrA/methods.pm \
	lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm \
	lib/HTpcrA/Controller/grouping_2d.pm \
	lib/HTpcrA/Controller/Scrapbook.pm \
	lib/stefans_libs/file_readers/PCR_Raw_Tables.pm \
	lib/stefans_libs/GeneGroups/R_table.pm \
	lib/stefans_libs/GeneGroups/Set.pm \
	lib/HTpcrA/Controller/Root.pm \
	lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm \
	lib/HTpcrA/Controller/Error.pm \
	lib/stefans_libs/HTpcrA/Menue.pm \
	lib/HTpcrA/Controller/analyse.pm \
	lib/HTpcrA/Model/PValues.pm \
	lib/HTpcrA/Controller/DropGenes.pm \
	lib/HTpcrA/Model/Coexpr.pm \
	lib/HTpcrA/Controller/Coexpression.pm
	$(NOECHO) $(POD2MAN) --section=$(MAN1EXT) --perm_rw=$(PERM_RW) \
	  script/htpcra_create.pl $(INST_MAN1DIR)/htpcra_create.pl.$(MAN1EXT) \
	  script/libPatcher.pl $(INST_MAN1DIR)/libPatcher.pl.$(MAN1EXT) \
	  script/htpcra_fastcgi.pl $(INST_MAN1DIR)/htpcra_fastcgi.pl.$(MAN1EXT) \
	  script/minimize_css.pl $(INST_MAN1DIR)/minimize_css.pl.$(MAN1EXT) \
	  script/htpcra_test.pl $(INST_MAN1DIR)/htpcra_test.pl.$(MAN1EXT) \
	  script/CleanTemp.pl $(INST_MAN1DIR)/CleanTemp.pl.$(MAN1EXT) \
	  script/htpcra_server.pl $(INST_MAN1DIR)/htpcra_server.pl.$(MAN1EXT) \
	  script/install.pl $(INST_MAN1DIR)/install.pl.$(MAN1EXT) \
	  script/htpcra_cgi.pl $(INST_MAN1DIR)/htpcra_cgi.pl.$(MAN1EXT) 
	$(NOECHO) $(POD2MAN) --section=$(MAN3EXT) --perm_rw=$(PERM_RW) \
	  lib/HTpcrA/Model/Menu.pm $(INST_MAN3DIR)/HTpcrA::Model::Menu.$(MAN3EXT) \
	  lib/HTpcrA/EnableFiles.pm $(INST_MAN3DIR)/HTpcrA::EnableFiles.$(MAN3EXT) \
	  lib/HTpcrA/Controller/DropSamples.pm $(INST_MAN3DIR)/HTpcrA::Controller::DropSamples.$(MAN3EXT) \
	  lib/HTpcrA/Model/rgl3dplots.pm $(INST_MAN3DIR)/HTpcrA::Model::rgl3dplots.$(MAN3EXT) \
	  lib/HTpcrA/Model/mech.pm $(INST_MAN3DIR)/HTpcrA::Model::mech.$(MAN3EXT) \
	  lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm $(INST_MAN3DIR)/CatalystX::Profile_SL::Controller::ControlProfiling.$(MAN3EXT) \
	  lib/stefans_libs/file_readers/Patcher.pm $(INST_MAN3DIR)/stefans_libs::file_readers::Patcher.$(MAN3EXT) \
	  lib/stefans_libs/root.pm $(INST_MAN3DIR)/stefans_libs::root.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Regroup.pm $(INST_MAN3DIR)/HTpcrA::Controller::Regroup.$(MAN3EXT) \
	  lib/HTpcrA/Controller/help.pm $(INST_MAN3DIR)/HTpcrA::Controller::help.$(MAN3EXT) \
	  lib/HTpcrA/Model/PCR_Raw_Files.pm $(INST_MAN3DIR)/HTpcrA::Model::PCR_Raw_Files.$(MAN3EXT) \
	  lib/HTpcrA/Controller/gene_group.pm $(INST_MAN3DIR)/HTpcrA::Controller::gene_group.$(MAN3EXT) \
	  lib/HTpcrA/Controller/PValues.pm $(INST_MAN3DIR)/HTpcrA::Controller::PValues.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Filemerger.pm $(INST_MAN3DIR)/HTpcrA::Controller::Filemerger.$(MAN3EXT) \
	  lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm $(INST_MAN3DIR)/stefans_libs::flexible_data_structures::BinList::Histogram.$(MAN3EXT) \
	  lib/stefans_libs/plot_old/axis.pm $(INST_MAN3DIR)/stefans_libs::plot_old::axis.$(MAN3EXT) \
	  lib/stefans_libs/GeneGroups.pm $(INST_MAN3DIR)/stefans_libs::GeneGroups.$(MAN3EXT) \
	  lib/HTpcrA/Model/RandomForest.pm $(INST_MAN3DIR)/HTpcrA::Model::RandomForest.$(MAN3EXT) \
	  lib/HTpcrA/Model/scrapbook.pm $(INST_MAN3DIR)/HTpcrA::Model::scrapbook.$(MAN3EXT) \
	  lib/stefans_libs/Description.pm $(INST_MAN3DIR)/stefans_libs::Description.$(MAN3EXT) \
	  lib/HTpcrA/Controller/RandomForest.pm $(INST_MAN3DIR)/HTpcrA::Controller::RandomForest.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Files.pm $(INST_MAN3DIR)/HTpcrA::Controller::Files.$(MAN3EXT) \
	  lib/HTpcrA/View/HTML.pm $(INST_MAN3DIR)/HTpcrA::View::HTML.$(MAN3EXT) \
	  lib/HTpcrA.pm $(INST_MAN3DIR)/HTpcrA.$(MAN3EXT) \
	  lib/HTpcrA/Model/java_splicer.pm $(INST_MAN3DIR)/HTpcrA::Model::java_splicer.$(MAN3EXT) \
	  lib/stefans_libs/HTpcrA/ScrapBook.pm $(INST_MAN3DIR)/stefans_libs::HTpcrA::ScrapBook.$(MAN3EXT) \
	  lib/HTpcrA/Model/HelpFile.pm $(INST_MAN3DIR)/HTpcrA::Model::HelpFile.$(MAN3EXT) \
	  lib/stefans_libs/flexible_data_structures/BinList.pm $(INST_MAN3DIR)/stefans_libs::flexible_data_structures::BinList.$(MAN3EXT) \
	  lib/CatalystX/Profile_SL.pm $(INST_MAN3DIR)/CatalystX::Profile_SL.$(MAN3EXT) \
	  lib/HTpcrA/Model/MethodsSection.pm $(INST_MAN3DIR)/HTpcrA::Model::MethodsSection.$(MAN3EXT) 
	$(NOECHO) $(POD2MAN) --section=$(MAN3EXT) --perm_rw=$(PERM_RW) \
	  lib/HTpcrA/Model/GeneGroups.pm $(INST_MAN3DIR)/HTpcrA::Model::GeneGroups.$(MAN3EXT) \
	  lib/stefans_libs/HTpcrA/methods.pm $(INST_MAN3DIR)/stefans_libs::HTpcrA::methods.$(MAN3EXT) \
	  lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm $(INST_MAN3DIR)/stefans_libs::flexible_data_structures::BinList::XY_Group.$(MAN3EXT) \
	  lib/HTpcrA/Controller/grouping_2d.pm $(INST_MAN3DIR)/HTpcrA::Controller::grouping_2d.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Scrapbook.pm $(INST_MAN3DIR)/HTpcrA::Controller::Scrapbook.$(MAN3EXT) \
	  lib/stefans_libs/file_readers/PCR_Raw_Tables.pm $(INST_MAN3DIR)/stefans_libs::file_readers::PCR_Raw_Tables.$(MAN3EXT) \
	  lib/stefans_libs/GeneGroups/R_table.pm $(INST_MAN3DIR)/stefans_libs::GeneGroups::R_table.$(MAN3EXT) \
	  lib/stefans_libs/GeneGroups/Set.pm $(INST_MAN3DIR)/stefans_libs::GeneGroups::Set.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Root.pm $(INST_MAN3DIR)/HTpcrA::Controller::Root.$(MAN3EXT) \
	  lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm $(INST_MAN3DIR)/stefans_libs::flexible_data_structures::data_table::arraySorter.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Error.pm $(INST_MAN3DIR)/HTpcrA::Controller::Error.$(MAN3EXT) \
	  lib/stefans_libs/HTpcrA/Menue.pm $(INST_MAN3DIR)/stefans_libs::HTpcrA::Menue.$(MAN3EXT) \
	  lib/HTpcrA/Controller/analyse.pm $(INST_MAN3DIR)/HTpcrA::Controller::analyse.$(MAN3EXT) \
	  lib/HTpcrA/Model/PValues.pm $(INST_MAN3DIR)/HTpcrA::Model::PValues.$(MAN3EXT) \
	  lib/HTpcrA/Controller/DropGenes.pm $(INST_MAN3DIR)/HTpcrA::Controller::DropGenes.$(MAN3EXT) \
	  lib/HTpcrA/Model/Coexpr.pm $(INST_MAN3DIR)/HTpcrA::Model::Coexpr.$(MAN3EXT) \
	  lib/HTpcrA/Controller/Coexpression.pm $(INST_MAN3DIR)/HTpcrA::Controller::Coexpression.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = script/capture_rgl_javascript.pl script/CleanTemp.pl script/htpcra_cgi.pl script/htpcra_create.pl script/htpcra_fastcgi.pl script/htpcra_server.pl script/htpcra_test.pl script/install.pl script/libPatcher.pl script/minimize_css.pl

pure_all :: $(INST_SCRIPT)/minimize_css.pl $(INST_SCRIPT)/htpcra_test.pl $(INST_SCRIPT)/htpcra_fastcgi.pl $(INST_SCRIPT)/htpcra_create.pl $(INST_SCRIPT)/capture_rgl_javascript.pl $(INST_SCRIPT)/libPatcher.pl $(INST_SCRIPT)/htpcra_cgi.pl $(INST_SCRIPT)/CleanTemp.pl $(INST_SCRIPT)/install.pl $(INST_SCRIPT)/htpcra_server.pl
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/minimize_css.pl $(INST_SCRIPT)/htpcra_test.pl \
	  $(INST_SCRIPT)/htpcra_fastcgi.pl $(INST_SCRIPT)/htpcra_create.pl \
	  $(INST_SCRIPT)/capture_rgl_javascript.pl $(INST_SCRIPT)/libPatcher.pl \
	  $(INST_SCRIPT)/htpcra_cgi.pl $(INST_SCRIPT)/CleanTemp.pl \
	  $(INST_SCRIPT)/install.pl $(INST_SCRIPT)/htpcra_server.pl 

$(INST_SCRIPT)/minimize_css.pl : script/minimize_css.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/minimize_css.pl
	$(CP) script/minimize_css.pl $(INST_SCRIPT)/minimize_css.pl
	$(FIXIN) $(INST_SCRIPT)/minimize_css.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/minimize_css.pl

$(INST_SCRIPT)/htpcra_test.pl : script/htpcra_test.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/htpcra_test.pl
	$(CP) script/htpcra_test.pl $(INST_SCRIPT)/htpcra_test.pl
	$(FIXIN) $(INST_SCRIPT)/htpcra_test.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/htpcra_test.pl

$(INST_SCRIPT)/htpcra_fastcgi.pl : script/htpcra_fastcgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/htpcra_fastcgi.pl
	$(CP) script/htpcra_fastcgi.pl $(INST_SCRIPT)/htpcra_fastcgi.pl
	$(FIXIN) $(INST_SCRIPT)/htpcra_fastcgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/htpcra_fastcgi.pl

$(INST_SCRIPT)/htpcra_create.pl : script/htpcra_create.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/htpcra_create.pl
	$(CP) script/htpcra_create.pl $(INST_SCRIPT)/htpcra_create.pl
	$(FIXIN) $(INST_SCRIPT)/htpcra_create.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/htpcra_create.pl

$(INST_SCRIPT)/capture_rgl_javascript.pl : script/capture_rgl_javascript.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/capture_rgl_javascript.pl
	$(CP) script/capture_rgl_javascript.pl $(INST_SCRIPT)/capture_rgl_javascript.pl
	$(FIXIN) $(INST_SCRIPT)/capture_rgl_javascript.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/capture_rgl_javascript.pl

$(INST_SCRIPT)/libPatcher.pl : script/libPatcher.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/libPatcher.pl
	$(CP) script/libPatcher.pl $(INST_SCRIPT)/libPatcher.pl
	$(FIXIN) $(INST_SCRIPT)/libPatcher.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/libPatcher.pl

$(INST_SCRIPT)/htpcra_cgi.pl : script/htpcra_cgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/htpcra_cgi.pl
	$(CP) script/htpcra_cgi.pl $(INST_SCRIPT)/htpcra_cgi.pl
	$(FIXIN) $(INST_SCRIPT)/htpcra_cgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/htpcra_cgi.pl

$(INST_SCRIPT)/CleanTemp.pl : script/CleanTemp.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/CleanTemp.pl
	$(CP) script/CleanTemp.pl $(INST_SCRIPT)/CleanTemp.pl
	$(FIXIN) $(INST_SCRIPT)/CleanTemp.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/CleanTemp.pl

$(INST_SCRIPT)/install.pl : script/install.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/install.pl
	$(CP) script/install.pl $(INST_SCRIPT)/install.pl
	$(FIXIN) $(INST_SCRIPT)/install.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/install.pl

$(INST_SCRIPT)/htpcra_server.pl : script/htpcra_server.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/htpcra_server.pl
	$(CP) script/htpcra_server.pl $(INST_SCRIPT)/htpcra_server.pl
	$(FIXIN) $(INST_SCRIPT)/htpcra_server.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/htpcra_server.pl



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  core.[0-9][0-9] lib$(BASEEXT).def \
	  $(INST_ARCHAUTODIR)/extralibs.all *perl.core \
	  $(BOOTSTRAP) core.*perl.*.? \
	  *$(OBJ_EXT) blibdirs.ts \
	  core.[0-9][0-9][0-9][0-9] pm_to_blib \
	  perl$(EXE_EXT) core.[0-9] \
	  tmon.out so_locations \
	  mon.out perl \
	  *$(LIB_EXT) $(BASEEXT).x \
	  perlmain.c pm_to_blib.ts \
	  perl.exe $(BASEEXT).def \
	  MYMETA.json core \
	  $(MAKE_APERL_FILE) core.[0-9][0-9][0-9] \
	  MYMETA.yml $(BASEEXT).exp \
	  core.[0-9][0-9][0-9][0-9][0-9] $(INST_ARCHAUTODIR)/extralibs.ld \
	  $(BASEEXT).bso 
	- $(RM_RF) \
	  blib 
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  $(DISTVNAME) MYMETA.yml 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old 



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) umask 022; $(MOD_INSTALL) \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install :: all
	$(NOECHO) umask 02; $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install :: all
	$(NOECHO) umask 022; $(MOD_INSTALL) \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install :: all

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLSITEARCH)/perllocal.pod
	-$(NOECHO) umask 02; $(MKPATH) $(DESTINSTALLSITEARCH)
	-$(NOECHO) umask 02; $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLSITEARCH)/perllocal.pod

doc_vendor_install :: all


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::



# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/01app.t t/02_1_app_RandomForest.t t/02_3_dropSamples_only.t t/02_4_check_analysis_page.t t/02pod.t t/03podcoverage.t t/Check_01.1_input_multiple_files_R.t t/Check_01_input_files_R.t t/Check_04_analysis_R.t t/controller_analyse.t t/controller_Coexpression.t t/controller_Error.t t/controller_fluidigm_analysis.t t/controller_gene_group.t t/controller_grouping_2d.t t/controller_help.t t/controller_PValues.t t/controller_RandomForest.t t/controller_test.t t/data_table_2.t t/help_data.t t/model_Coexpr.t t/model_java_splicer.t t/model_mechanize.t t/model_PValues.t t/model_RandomForest_recieve.t t/model_RandomForest_send.t t/model_RandomForest_x_send_to_server.t t/model_rgl3dplots.t t/regroup_logics.t t/simpleBarGraph.t t/stefans_libs_Description.t t/stefans_libs_file_readers_Fluidigm_Raw_Tables.t t/stefans_libs_GeneGroup_4_newInitialPlot.t t/stefans_libs_GeneGroups.t t/stefans_libs_GeneGroups_2.t t/stefans_libs_GeneGroups_3.t t/stefans_libs_GeneGroups_R_table.t t/stefans_libs_GeneGroups_Set.t t/stefans_libs_HTpcrA_Menus.t t/stefans_libs_HTpcrA_methods.t t/stefans_libs_HTpcrA_ScrapBook.t t/view_TT.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>Catalyst based application</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Stefan Lang</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Action::RenderView" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Model::Factory::PerRequest" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::ConfigLoader" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::ErrorCatcher" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::FormBuilder" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::RequireSSL" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::SecureCookies" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::State::Cookie" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::Store::FastMmap" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Static::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Runtime" VERSION="5.90019" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::View::TT" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Config::General" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Date::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DateTime::Format::MySQL" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="GD::SVG" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="HTML::Template" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Number::Format" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Statistics::Descriptive" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="namespace::autoclean" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux-gnu-thread-multi-5.18" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/CatalystX/nytprof.out blib/lib/CatalystX/nytprof.out \
	  lib/HTpcrA/Controller/DropSamples.pm blib/lib/HTpcrA/Controller/DropSamples.pm \
	  lib/HTpcrA/EnableFiles.pm blib/lib/HTpcrA/EnableFiles.pm \
	  lib/HTpcrA/Model/Menu.pm blib/lib/HTpcrA/Model/Menu.pm \
	  lib/CatalystX/Profile_SL/Controller/nytprof.out blib/lib/CatalystX/Profile_SL/Controller/nytprof.out \
	  lib/HTpcrA/Controller/Regroup.pm blib/lib/HTpcrA/Controller/Regroup.pm \
	  lib/stefans_libs/root.pm blib/lib/stefans_libs/root.pm \
	  lib/stefans_libs/file_readers/Patcher.pm blib/lib/stefans_libs/file_readers/Patcher.pm \
	  lib/HTpcrA/Model/mech.pm blib/lib/HTpcrA/Model/mech.pm \
	  lib/HTpcrA/Model/rgl3dplots.pm blib/lib/HTpcrA/Model/rgl3dplots.pm \
	  lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm blib/lib/CatalystX/Profile_SL/Controller/ControlProfiling.pm \
	  lib/stefans_libs/plot_old/color.pm blib/lib/stefans_libs/plot_old/color.pm \
	  lib/HTpcrA/Controller/Filemerger.pm blib/lib/HTpcrA/Controller/Filemerger.pm \
	  lib/HTpcrA/Controller/PValues.pm blib/lib/HTpcrA/Controller/PValues.pm \
	  lib/htpcra.conf blib/lib/htpcra.conf \
	  lib/HTpcrA/Controller/gene_group.pm blib/lib/HTpcrA/Controller/gene_group.pm \
	  lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm blib/lib/stefans_libs/flexible_data_structures/BinList/Histogram.pm \
	  lib/HTpcrA/Model/PCR_Raw_Files.pm blib/lib/HTpcrA/Model/PCR_Raw_Files.pm \
	  lib/HTpcrA/Controller/help.pm blib/lib/HTpcrA/Controller/help.pm \
	  lib/stefans_libs/Description.pm blib/lib/stefans_libs/Description.pm \
	  lib/HTpcrA/Model/scrapbook.pm blib/lib/HTpcrA/Model/scrapbook.pm \
	  lib/HTpcrA/Controller/RandomForest.pm blib/lib/HTpcrA/Controller/RandomForest.pm \
	  lib/stefans_libs/plot_old/axis.pm blib/lib/stefans_libs/plot_old/axis.pm \
	  lib/HTpcrA/Model/RandomForest.pm blib/lib/HTpcrA/Model/RandomForest.pm \
	  lib/.gitignore blib/lib/.gitignore \
	  lib/stefans_libs/GeneGroups.pm blib/lib/stefans_libs/GeneGroups.pm \
	  lib/stefans_libs/HTpcrA/ScrapBook.pm blib/lib/stefans_libs/HTpcrA/ScrapBook.pm \
	  lib/HTpcrA.pm blib/lib/HTpcrA.pm \
	  lib/HTpcrA/View/HTML.pm blib/lib/HTpcrA/View/HTML.pm \
	  lib/HTpcrA/Controller/Files.pm blib/lib/HTpcrA/Controller/Files.pm \
	  lib/htpcr.conf.useless blib/lib/htpcr.conf.useless \
	  lib/HTpcrA/Model/java_splicer.pm blib/lib/HTpcrA/Model/java_splicer.pm \
	  lib/stefans_libs/plot_old/Font.pm blib/lib/stefans_libs/plot_old/Font.pm \
	  lib/HTpcrA/Model/GeneGroups.pm blib/lib/HTpcrA/Model/GeneGroups.pm \
	  lib/stefans_libs/file_readers/help_data.pm blib/lib/stefans_libs/file_readers/help_data.pm \
	  lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm blib/lib/stefans_libs/flexible_data_structures/BinList/XY_Group.pm 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/stefans_libs/HTpcrA/methods.pm blib/lib/stefans_libs/HTpcrA/methods.pm \
	  lib/stefans_libs/flexible_data_structures/BinList.pm blib/lib/stefans_libs/flexible_data_structures/BinList.pm \
	  lib/HTpcrA/Model/HelpFile.pm blib/lib/HTpcrA/Model/HelpFile.pm \
	  lib/CatalystX/Profile_SL.pm blib/lib/CatalystX/Profile_SL.pm \
	  lib/HTpcrA/Model/MethodsSection.pm blib/lib/HTpcrA/Model/MethodsSection.pm \
	  lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm blib/lib/stefans_libs/flexible_data_structures/data_table/arraySorter.pm \
	  lib/HTpcrA/Controller/Error.pm blib/lib/HTpcrA/Controller/Error.pm \
	  lib/stefans_libs/GeneGroups/R_table.pm blib/lib/stefans_libs/GeneGroups/R_table.pm \
	  lib/stefans_libs/file_readers/PCR_Raw_Tables.pm blib/lib/stefans_libs/file_readers/PCR_Raw_Tables.pm \
	  lib/stefans_libs/GeneGroups/Set.pm blib/lib/stefans_libs/GeneGroups/Set.pm \
	  lib/HTpcrA/Controller/Scrapbook.pm blib/lib/HTpcrA/Controller/Scrapbook.pm \
	  lib/HTpcrA/Controller/grouping_2d.pm blib/lib/HTpcrA/Controller/grouping_2d.pm \
	  lib/HTpcrA/Controller/Root.pm blib/lib/HTpcrA/Controller/Root.pm \
	  lib/HTpcrA/Model/PValues.pm blib/lib/HTpcrA/Model/PValues.pm \
	  lib/HTpcrA/Controller/Coexpression.pm blib/lib/HTpcrA/Controller/Coexpression.pm \
	  lib/HTpcrA/Model/Coexpr.pm blib/lib/HTpcrA/Model/Coexpr.pm \
	  lib/HTpcrA/Controller/DropGenes.pm blib/lib/HTpcrA/Controller/DropGenes.pm \
	  lib/HTpcrA/Controller/analyse.pm blib/lib/HTpcrA/Controller/analyse.pm \
	  lib/stefans_libs/HTpcrA/Menue.pm blib/lib/stefans_libs/HTpcrA/Menue.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 1.12
catalyst_par :: all
	$(NOECHO) $(PERL) -Ilib -Minc::Module::Install -MModule::Install::Catalyst -e"Catalyst::Module::Install::_catalyst_par( '', 'HTpcrA', { CLASSES => [], PAROPTS =>  {}, ENGINE => 'CGI', SCRIPT => '', USAGE => q## } )"
# --- Module::Install::AutoInstall section:

config :: installdeps
	$(NOECHO) $(NOOP)

checkdeps ::
	$(PERL) Makefile.PL --checkdeps

installdeps ::
	$(NOECHO) $(NOOP)

installdeps_notest ::
	$(NOECHO) $(NOOP)

upgradedeps ::
	$(PERL) Makefile.PL --config= --upgradedeps=Test::More,0.88,jQuery::File::Upload,0,Catalyst::Runtime,5.90019,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Plugin::ErrorCatcher,0,Catalyst::Action::RenderView,0,Moose,0,namespace::autoclean,0,Config::General,0,Catalyst::Plugin::SecureCookies,0,Catalyst::Plugin::RequireSSL,0,Catalyst::Plugin::Session,0,Catalyst::Plugin::Session::State::Cookie,0,Catalyst::Plugin::Session::Store::FastMmap,0,HTML::Template,0,Catalyst::Model::Factory::PerRequest,0,Date::Simple,0,Statistics::Descriptive,0,GD::SVG,0,Number::Format,0,Catalyst::Plugin::FormBuilder,0,Catalyst::View::TT,0,DateTime::Format::MySQL,0

upgradedeps_notest ::
	$(PERL) Makefile.PL --config=notest,1 --upgradedeps=Test::More,0.88,jQuery::File::Upload,0,Catalyst::Runtime,5.90019,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Plugin::ErrorCatcher,0,Catalyst::Action::RenderView,0,Moose,0,namespace::autoclean,0,Config::General,0,Catalyst::Plugin::SecureCookies,0,Catalyst::Plugin::RequireSSL,0,Catalyst::Plugin::Session,0,Catalyst::Plugin::Session::State::Cookie,0,Catalyst::Plugin::Session::Store::FastMmap,0,HTML::Template,0,Catalyst::Model::Factory::PerRequest,0,Date::Simple,0,Statistics::Descriptive,0,GD::SVG,0,Number::Format,0,Catalyst::Plugin::FormBuilder,0,Catalyst::View::TT,0,DateTime::Format::MySQL,0

listdeps ::
	@$(PERL) -le "print for @ARGV" 

listalldeps ::
	@$(PERL) -le "print for @ARGV" Test::More jQuery::File::Upload Catalyst::Runtime Catalyst::Plugin::ConfigLoader Catalyst::Plugin::Static::Simple Catalyst::Plugin::ErrorCatcher Catalyst::Action::RenderView Moose namespace::autoclean Config::General Catalyst::Plugin::SecureCookies Catalyst::Plugin::RequireSSL Catalyst::Plugin::Session Catalyst::Plugin::Session::State::Cookie Catalyst::Plugin::Session::Store::FastMmap HTML::Template Catalyst::Model::Factory::PerRequest Date::Simple Statistics::Descriptive GD::SVG Number::Format Catalyst::Plugin::FormBuilder Catalyst::View::TT DateTime::Format::MySQL

