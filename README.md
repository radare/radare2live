Radare2 Live
============

This repository contains all the necessary stuff to construct a livecd image using the Void linux distribution.

To create a [voidlinux](http://voidlinux.eu) live image with r2:

	$ make

Flash in a pendrive, CD-ROM or boot it like this:

	$ qemu-system-i386 -cdrom r2live.iso
	$ qemu-system-x86_64 -cdrom r2live.iso

![img](img/r2live.png)

![img](img/r2live2.png)

TODO
----

* include radare2-git package
* shrink filesystem contents
  - create new base pkg (base-system-r2) without the firmware files
