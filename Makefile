PACKAGES=radare2
KEYMAP=en
LOCALE=C

all: void-mklive/mklive.sh
	# fix motd by replacing the whole script !!!
	cp mklive.sh.orig void-mklive/mklive.sh
	cp -f splash.png void-mklive/isolinux/splash.png
	cp -f grub_void.cfg.in void-mklive/grub/grub_void.cfg.in
	sudo rm -f void-mklive/*.iso
	cd void-mklive ; sudo linux32 ./mklive.sh -k $(KEYMAP) -l $(LOCALE) -p $(PACKAGES)
	cp void-mklive/*.iso r2live.iso

void-mklive:
	git clone https://github.com/voidlinux/void-mklive

void-mklive/mklive.sh: void-mklive
	$(MAKE) -C void-mklive

boot run:
	qemu-system-i386 -cdrom r2live.iso
