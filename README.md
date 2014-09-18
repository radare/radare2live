radare2iso
==========

How to create the ISO file from voidlinux:

	$ make

Flash in a pendrive, CD-ROM or boot it like this:

	$ qemu-system-i386 -cdrom r2live.iso
	$ qemu-system-x86_64 -cdrom r2live.iso

![img](img/r2live.png)

![img](img/r2live2.png)

TODO
----

* include radare2-git package
* change default user name
* do not use vga mode? 80x25 ftw
* shrink filesystem contents
* append timestamp to r2live iso filename?
