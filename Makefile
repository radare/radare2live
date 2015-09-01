LOCAL_PACKAGES=lzo-32bit squashfs-tools xz

#PACKAGES=radare2
#PACKAGES=radare2-git binutils gcc gdb
#PACKAGES=radare2-git 

PACKAGES=gdb strace ltrace binutils gcc git
#PACKAGES+=radare2
PACKAGES+=radare2-git

# X11
#PACKAGES+=obconf openbox xorg-minimal xf86-video-vesa xterm 
#PACKAGES+=xf86-video-modesetting

USERNAME=r2
USERSHELL=/bin/r2sh
USERSHELL=/bin/bash
#BASESYSTEM=base-system-systemd (190MB)
#BASESYSTEM=base-system-systemd
#BASESYSTEM=base-system

KEYMAP=us
LOCALE=en_US.UTF-8
TITLE="Void GNU/Linux"

RAMFS_SIZE=768
#RAMFS_SIZE=256
KEYMAP=es
LOCALE=es_ES.UTF-8
TITLE="radare2 live - Void GNU/Linux"

TODAY=$(shell date +%Y%m%d)

ARCH=linux32

# known to work on this commit
MKLIVETIP=851c861cfd046e354cfd9ce8ce4b92fdfb4dc323
LOCALREPO=$(shell pwd)/xbps-packages/hostdir/binpkgs/${HOME}/prg/xbps-packages/
R2PKG=$(LOCALREPO)/radare2-git-20150831_1.i686.xbps

SETTINGS="nomodeset verbose live.user=$(USERNAME) live.shell=$(USERSHELL)"

all: void-mklive/mklive.sh
	[ -n "`${ARCH} xbps-query --repository=$(LOCALREPO) radare2-git`" ] || ${MAKE} pkg
	-sudo xbps-install -Sy ${LOCAL_PACKAGES}
	cd void-mklive ; git pull
	cp -f motd void-mklive/data/motd
	cp -f issue void-mklive/data/issue
	cp -f splash.png void-mklive/data/splash.png
	#cp -f splash-securizame.png void-mklive/data/splash.png
	#cp -f splash-void.png void-mklive/data/splash.png
	sudo rm -f void-mklive/*.iso
	echo ./mklive.sh -a i686 \
		-C "${SETTINGS}" \
		-r "$(LOCALREPO)" \
		-S $(RAMFS_SIZE) \
		-b $(BASESYSTEM)
		-T $(TITLE) \
		-k $(KEYMAP) \
		-l $(LOCALE) \
		-p "$(PACKAGES)"
	-cd void-mklive ; sudo ${ARCH} \
	./mklive.sh -a i686 \
		-C "${SETTINGS}" \
		-r "$(LOCALREPO)" \
		-S $(RAMFS_SIZE) \
		-b $(BASESYSTEM)
		-T $(TITLE) \
		-k $(KEYMAP) \
		-l $(LOCALE) \
		-p "$(PACKAGES)"
	mv -f void-mklive/*.iso r2live-${TODAY}.iso
	ln -fs r2live-${TODAY}.iso r2live.iso

$(R2PKG):
	[ -n "`xbps-query --repository=$(LOCALREPO) radare2-git`" ] || $(MAKE) -C xbps-packages`" ]
	[ -n "`xbps-query --repository=$(LOCALREPO) radare2-git`" ]

pkg: $(R2PKG)

void-mklive:
	git clone https://github.com/voidlinux/void-mklive

void-mklive/mklive.sh: pkg void-mklive
	$(MAKE) -C void-mklive

boot run:
	$(SUDO) qemu-system-i386 --enable-kvm -cdrom r2live.iso
	#qemu-system-x86_64 -cdrom r2live.iso
