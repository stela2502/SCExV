all:
	(cd SCExV && perl Makefile.PL --defaultdeps)
	make -C SCExV
install:
	make -C SCExV install
