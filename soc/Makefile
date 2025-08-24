all:
	arm-linux-gnueabihf-gcc -Dsoc_cv_av -O2 -o aesa_radar soc.c
	arm-linux-gnueabihf-strip -s aesa_radar

clean:
	rm -rf aesa_radar
