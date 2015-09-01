LOCALREPO=$(shell pwd)/xbps-packages/hostdir/binpkgs/${HOME}/prg/xbps-packages/
XBPS_PACKAGES=${HOME}/prg/xbps-packages

all:
	cd srcpkgs/radare2-git ; linux32 \
	../../xbps-src -a i686 -r $(LOCALREPO) -j10 pkg
