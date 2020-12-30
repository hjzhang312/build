boardtype :=snapav51
deletedatabase :=false

app:=snapavapp
rootfspath:=hs_rootfs_51
appsrc:=snapav_app
appproname:=snapavapp

grepname=V51_

ifeq ($(boardtype), snapav16d)
	apptype:= "CONFIG+=SNAPAV_SIXTEEN"
	rootfspath:=hs_rootfs_16d
	grepname=V16_
else ifeq ($(boardtype), snapav12d)
	apptype:= "CONFIG+=SNAPAV_TWELVE"
	rootfspath:=hs_rootfs_12d
	grepname=V12_
else ifeq ($(boardtype), snapav8d)
	apptype:= "CONFIG+=SNAPAV_EIGHT"
	rootfspath:=hs_rootfs_8d
	grepname=V8_
else ifeq ($(boardtype), snapav2d)
	apptype:= "CONFIG+=SNAPAV_TWO"
	rootfspath:=hs_rootfs
	grepname=V2_
else ifeq ($(boardtype), snapav51)
	apptype:= "CONFIG+=SNAPAV_FIVENONE"
	app:=snapavapp51
	appsrc:=snapavapp5.1
	appproname:=snapavapp5.1
else
	echo "boardtype error !!"
	exit ;
endif

appversion :=$(shell  cat ../$(appsrc)/main.cpp  | grep SoftwareVersion | awk '{print $$3}' | grep ${grepname} | sed -s "s/\.//g" | sed -s "s/$(grepname)//g" | sed -s "s/\"//g")
dspversion :=$(shell  cat ../$(appsrc)/main.cpp  | grep DSPVersion | awk '{print $$3}' | grep ${grepname} | sed -s "s/\.//g" | sed -s "s/$(grepname)//g" | sed -s "s/\"//g")
#dspversion :=100

fw: getappver getdspver 
	echo ${boardtype}
	./build.sh kernel $(boardtype)
	if [ -h ../nuc970_buildroot/output/target/etc/network/interfaces ] ;then \
		rm  ../nuc970_buildroot/output/target/etc/network/interfaces ;\
	fi
	if [ -d  ../nuc970_buildroot/output/target/etc/network/ ] ;then \
		cp ../nuc970_buildroot/board/nuvoton/hs_rootfs_common/etc/network/interfaces.bk ../nuc970_buildroot/output/target/etc/network/interfaces ;\
	fi
	./build.sh rootfs $(boardtype) ${appversion} ${dspversion}
	./build.sh fw $(boardtype) ${appversion}.${dspversion}_`date "+%Y%m%d"` ${deletedatabase}


toolchain:
	if [ ! -d ../image ];then mkdir ../image ;fi || true
	if [ -h ../nuc970_buildroot/output/target/etc/network/interfaces ] ;then \
		rm  ../nuc970_buildroot/output/target/etc/network/interfaces ;\
	fi
	if [ -d  ../nuc970_buildroot/output/target/etc/network/ ] ;then \
		cp ../nuc970_buildroot/board/nuvoton/hs_rootfs_common/etc/network/interfaces.bk ../nuc970_buildroot/output/target/etc/network/interfaces ;\
	fi
	./build.sh rootfs snapav51 100 100
	if [ -h ../host ];then rm ../host ;fi || true
	ln -s ./nuc970_buildroot/output/host ../host

app:
	cd ../$(appsrc)/;qmake -makefile $(appproname).pro -o Makefile $(apptype) 
	make -C ../$(appsrc)/ -f Makefile -j24
	arm-linux-strip ../$(appsrc)/$(app) 
	cp ../$(appsrc)/$(app) ../nuc970_buildroot/board/nuvoton/$(rootfspath)/root/snapav/

getappver:
	@echo appversion=$(appversion)

getdspver:
	@echo dspversion=$(dspversion)

cleanapp:
	make -C  ../$(appsrc)/ -f Makefile clean

cleanall:
	make -C  ../nuc970_buildroot/ -f Makefile clean
	make -C  ../linux3.10/ -f Makefile clean
	make -C  ../snapav_app/ -f Makefile clean
	make -C  ../snapav_app/ -f Makefile clean
	make -C  ../snapavapp5.1/ -f Makefile clean
