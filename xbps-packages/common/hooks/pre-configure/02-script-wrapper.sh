# This hook creates wrappers for foo-config scripts in cross builds.
#
# Wrappers are created in ${wrksrc}/.xbps/bin and this path is appended
# to make configure scripts find them.

generic_wrapper() {
	local wrapper="$1"
	[ ! -x ${XBPS_CROSS_BASE}/usr/bin/${wrapper} ] && return 0
	[ -x ${XBPS_WRAPPERDIR}/${wrapper} ] && return 0

	echo "#!/bin/sh" >> ${XBPS_WRAPPERDIR}/${wrapper}
	echo "exec ${XBPS_CROSS_BASE}/usr/bin/${wrapper} --prefix=${XBPS_CROSS_BASE}/usr \"\$@\"" >> ${XBPS_WRAPPERDIR}/${wrapper}
	chmod 755 ${XBPS_WRAPPERDIR}/${wrapper}
}

generic_wrapper2() {
	local wrapper="$1"

	[ ! -x ${XBPS_CROSS_BASE}/usr/bin/${wrapper} ] && return 0
	[ -x ${XBPS_WRAPPERDIR}/${wrapper} ] && return 0

	cat >>${XBPS_WRAPPERDIR}/${wrapper}<<_EOF
#!/bin/sh
if [ "\$1" = "--prefix" ]; then
	echo "${XBPS_CROSS_BASE}/usr"
elif [ "\$1" = "--cflags" ]; then
	${XBPS_CROSS_BASE}/usr/bin/${wrapper} --cflags | sed -e "s,-I/usr/include,-I${XBPS_CROSS_BASE}/usr/include,g"
elif [ "\$1" = "--libs" ]; then
	${XBPS_CROSS_BASE}/usr/bin/${wrapper} --libs | sed -e "s,-L/usr/lib,-L${XBPS_CROSS_BASE}/usr/lib,g"
else
	exec ${XBPS_CROSS_BASE}/usr/bin/${wrapper} "\$@"
fi
exit \$?
_EOF
	chmod 755 ${XBPS_WRAPPERDIR}/${wrapper}
}

generic_wrapper3() {
	local wrapper="$1"
	[ ! -x ${XBPS_CROSS_BASE}/usr/bin/${wrapper} ] && return 0
	[ -x ${XBPS_WRAPPERDIR}/${wrapper} ] && return 0

	cp ${XBPS_CROSS_BASE}/usr/bin/${wrapper} ${XBPS_WRAPPERDIR}
	sed -e "s,^libdir=.*,libdir=${XBPS_CROSS_BASE}/usr/lib,g" -i ${XBPS_WRAPPERDIR}/${wrapper}
	sed -e "s,^prefix=.*,prefix=${XBPS_CROSS_BASE}/usr," -i ${XBPS_WRAPPERDIR}/${wrapper}

	chmod 755 ${XBPS_WRAPPERDIR}/${wrapper}
}

python_wrapper() {
	local wrapper="$1" version="$2"

	[ -x ${XBPS_WRAPPERDIR}/${wrapper} ] && return 0
	cat >>${XBPS_WRAPPERDIR}/${wrapper}<<_EOF
#!/bin/sh
if [ "\$1" = "--includes" ]; then
	echo "-I${XBPS_CROSS_BASE}/usr/include/python${version}"
fi
exit \$?
_EOF
	chmod 755 ${XBPS_WRAPPERDIR}/${wrapper}
}

pkgconfig_wrapper() {
	if [ ! -x /usr/bin/pkg-config ]; then
		return 0
	fi
	[ -x ${XBPS_WRAPPERDIR}/${XBPS_CROSS_TRIPLET}-pkg-config ] && return 0
	cat >>${XBPS_WRAPPERDIR}/${XBPS_CROSS_TRIPLET}-pkg-config<<_EOF
#!/bin/sh

export PKG_CONFIG_SYSROOT_DIR="$XBPS_CROSS_BASE"
export PKG_CONFIG_PATH="$XBPS_CROSS_BASE/lib/pkgconfig:$XBPS_CROSS_BASE/usr/share/pkgconfig"
export PKG_CONFIG_LIBDIR="$XBPS_CROSS_BASE/lib/pkgconfig"
exec /usr/bin/pkg-config "\$@"
_EOF
	chmod 755 ${XBPS_WRAPPERDIR}/${XBPS_CROSS_TRIPLET}-pkg-config
	ln -sf ${XBPS_CROSS_TRIPLET}-pkg-config ${XBPS_WRAPPERDIR}/pkg-config
}

install_wrappers() {
	for f in ${XBPS_COMMONDIR}/wrappers/*.sh; do
		install -m0755 ${f} ${XBPS_WRAPPERDIR}/$(basename ${f%.sh})
	done
}

hook() {
	export PATH="$XBPS_WRAPPERDIR:$PATH"

	install_wrappers

	[ -z "$CROSS_BUILD" ] && return 0

	pkgconfig_wrapper
	generic_wrapper icu-config
	generic_wrapper libgcrypt-config
	generic_wrapper freetype-config
	generic_wrapper sdl-config
	generic_wrapper sdl2-config
	generic_wrapper gpgme-config
	generic_wrapper imlib2-config
	generic_wrapper libmikmod-config
	generic_wrapper pcre-config
	generic_wrapper net-snmp-config
	generic_wrapper2 curl-config
	generic_wrapper2 gpg-error-config
	generic_wrapper2 libassuan-config
	generic_wrapper2 mysql_config
	generic_wrapper2 taglib-config
	generic_wrapper2 nspr-config
	generic_wrapper3 libpng-config
	generic_wrapper3 xmlrpc-c-config
	generic_wrapper3 krb5-config
	generic_wrapper3 cups-config
	generic_wrapper3 Magick-config
	generic_wrapper3 fltk-config
	generic_wrapper3 xslt-config
	generic_wrapper3 xml2-config
	generic_wrapper3 fox-config
	generic_wrapper3 xapian-config
	generic_wrapper3 ncurses5-config
	generic_wrapper3 ncursesw5-config
	generic_wrapper3 libetpan-config
	python_wrapper python-config 2.7
	python_wrapper python3.4-config 3.4m
}
