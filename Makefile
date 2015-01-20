PACKAGES=radare2-git
#PACKAGES=radare2-git binutils gcc gdb
PACKAGES=radare2-git 
# vim
PACKAGES=gdb strace ltrace binutils gcc 
PACKAGES+=obconf openbox xorg-minimal xf86-video-vesa xterm 
PACKAGES+=xf86-video-modesetting

USERNAME=r2
USERSHELL=/bin/r2sh
USERSHELL=/bin/bash
#BASESYSTEM=base-system-systemd (190MB)
BASESYSTEM=base-system-busybox
BASESYSTEM=base-system

KEYMAP=us
LOCALE=en_US.UTF-8
TITLE="Void GNU/Linux"

RAMFS_SIZE=512
KEYMAP=es
LOCALE=es_ES.UTF-8
TITLE="radare2 live - Void GNU/Linux"

TODAY=$(shell date +%Y%m%d)

ARCH=linux32
ARCH=

# known to work on this commit
MKLIVETIP=8c91dea923aa2d5909771dfacb51168b7294f4ad

all: void-mklive/mklive.sh
	cd void-mklive ; git pull
	cp -f motd void-mklive/data/motd
	:> void-mklive/data/motd
	cp -f issue void-mklive/data/issue
	cp -f motd void-mklive/data/motd
	:> void-mklive/data/motd
	cp -f splash.png void-mklive/data/splash.png
	cp -f splash-securizame.png void-mklive/data/splash.png
	#cp -f splash-void.png void-mklive/data/splash.png
	sudo rm -f void-mklive/*.iso
	cd void-mklive ; sudo ${ARCH} ./mklive.sh \
		-C "nomodeset verbose live.user=$(USERNAME) live.shell=$(USERSHELL)" \
		-b $(BASESYSTEM) \
		-S $(RAMFS_SIZE) \
		-T $(TITLE) \
		-k $(KEYMAP) \
		-l $(LOCALE) \
		-p "$(PACKAGES)"
	mv void-mklive/*.iso r2live-${TODAY}.iso
	ln -fs r2live-${TODAY}.iso r2live.iso

void-mklive:
	git clone https://github.com/voidlinux/void-mklive

void-mklive/mklive.sh: void-mklive
	$(MAKE) -C void-mklive

boot run:
	qemu-system-i386 -cdrom r2live.iso
	#qemu-system-x86_64 -cdrom r2live.iso
