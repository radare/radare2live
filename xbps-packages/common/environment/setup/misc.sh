#
# Common variables that can be used by xbps-src.
#
# SITE used for ditfiles mirrors. For use in $distfiles.
set -a

SOURCEFORGE_SITE="http://downloads.sourceforge.net/sourceforge"
NONGNU_SITE="http://download.savannah.nongnu.org/releases"
UBUNTU_SITE="http://archive.ubuntu.com/ubuntu/pool"
XORG_SITE="http://xorg.freedesktop.org/releases/individual"
DEBIAN_SITE="http://ftp.debian.org/debian/pool"
GNOME_SITE="http://ftp.gnome.org/pub/GNOME/sources"
KERNEL_SITE="http://www.kernel.org/pub/linux"
#KERNEL_SITE="http://mirror.be.gbxs.net/pub/linux"
CPAN_SITE="http://cpan.perl.org/modules/by-module"
PYPI_SITE="http://pypi.python.org/packages/source"
MOZILLA_SITE="http://ftp.mozilla.org/pub/mozilla.org"
GNU_SITE="http://ftp.gnu.org/gnu"
FREEDESKTOP_SITE="http://freedesktop.org/software"

# Repetitive sub homepage's with no real project page
# ie. some gnome and xorg projects. For use in $homepage.
XORG_HOME="http://xorg.freedesktop.org/wiki/"

set +a
