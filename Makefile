PACKAGES=radare2
USERNAME=r2
KEYMAP=en
LOCALE=en_US.UTF-8
TITLE="radare2 live - Void GNU/Linux i686"
TODAY=$(shell date +%Y%m%d)

MKLIVETIP=620883f9b252645524d93f414a82c2a662091de7

all: void-mklive/mklive.sh
	cd void-mklive ; git pull
	cp -f motd void-mklive/data/motd
	cp -f splash.png void-mklive/data/splash.png
	sudo rm -f void-mklive/*.iso
	cd void-mklive ; sudo linux32 ./mklive.sh \
		-C "nomodeset live.user=$(USERNAME)" \
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
