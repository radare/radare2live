PACKAGES=radare2-git
USERNAME=r2
#BASESYSTEM=base-system-systemd (190MB)
#BASESYSTEM=base-system-busybox (50MB - crash )
BASESYSTEM=base-system
KEYMAP=en
LOCALE=en_US.UTF-8
TITLE="radare2 live - Void GNU/Linux"
TODAY=$(shell date +%Y%m%d)

# known to work on this commit
MKLIVETIP=8c91dea923aa2d5909771dfacb51168b7294f4ad

all: void-mklive/mklive.sh
	cd void-mklive ; git pull
	cp -f motd void-mklive/data/motd
	cp -f splash.png void-mklive/data/splash.png
	sudo rm -f void-mklive/*.iso
	cd void-mklive ; sudo linux32 ./mklive.sh \
		-C "nomodeset verbose live.user=$(USERNAME)" \
		-b $(BASESYSTEM) \
		-T $(TITLE) \
		-k $(KEYMAP) \
		-l $(LOCALE) \
		-p $(PACKAGES)
	mv void-mklive/*.iso r2live-${TODAY}.iso
	ln -fs r2live-${TODAY}.iso r2live.iso

void-mklive:
	git clone https://github.com/voidlinux/void-mklive

void-mklive/mklive.sh: void-mklive
	$(MAKE) -C void-mklive

boot run:
	qemu-system-i386 -cdrom r2live.iso
	#qemu-system-x86_64 -cdrom r2live.iso
