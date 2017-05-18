all:
	(cd SCExV && perl Makefile.PL)
	make -C SCExV
install:
	make -C SCExV install 
