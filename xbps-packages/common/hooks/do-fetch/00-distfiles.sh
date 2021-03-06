# This hook downloads the distfiles specified in a template by
# the $distfiles variable and then verifies its sha256 checksum comparing
# its value with the one stored in the $checksum variable.

# Get the checksum for $curfile at index $dfcount
get_cksum() {
	local curfile="$1" dfcount="$2" ckcount cksum i

	ckcount=0
	cksum=0
	for i in ${checksum}; do
		if [ $dfcount -eq $ckcount -a -n "$i" ]; then
			cksum=$i
		fi
		ckcount=$((ckcount + 1))
	done
	if [ -z "$cksum" ]; then
		msg_error "$pkgver: cannot find checksum for $curfile.\n"
	fi
	echo "$cksum"
}

# Verify the checksum for $curfile stored at $distfile and index $dfcount
verify_cksum() {
	local curfile="$1" distfile="$2" dfcount="$3" filesum cksum

	cksum=$(get_cksum $curfile $dfcount)
	msg_normal "$pkgver: verifying checksum for distfile '$curfile'... "
	filesum=$(${XBPS_DIGEST_CMD} $distfile)
	if [ "$cksum" != "$filesum" ]; then
		echo
		msg_red "SHA256 mismatch for '$curfile:'\n$filesum\n"
		errors=$(($errors + 1))
	else
		if [ ! -f "$XBPS_SRCDISTDIR/by_sha256/${cksum}_${curfile}" ]; then
			mkdir -p "$XBPS_SRCDISTDIR/by_sha256"
			ln -f "$distfile" "$XBPS_SRCDISTDIR/by_sha256/${cksum}_${curfile}"
		fi
		msg_normal_append "OK.\n"
	fi
}

# Link an existing cksum $distfile for $curfile at index $dfcount
link_cksum() {
	local curfile="$1" distfile="$2" dfcount="$3" filesum cksum

	cksum=$(get_cksum $curfile $dfcount)
	if [ -n "$cksum" -a -f "$XBPS_SRCDISTDIR/by_sha256/${cksum}_${curfile}" ]; then
		ln -f "$XBPS_SRCDISTDIR/by_sha256/${cksum}_${curfile}" "$distfile"
		msg_normal "$pkgver: using known distfile $curfile.\n"
	fi
}

try_mirrors() {
	local curfile="$1" distfile="$2" dfcount="$3" subdir="$4" f="$5"
	local filesum cksum basefile mirror path scheme
	[ -z "$XBPS_DISTFILES_MIRROR" ] && return
	basefile="$(basename $f)"
	cksum=$(get_cksum $curfile $dfcount)
	for mirror in $XBPS_DISTFILES_MIRROR; do
		scheme="file"
		if [[ $mirror == *://* ]]; then
			scheme="${mirror%%:/*}"
			path="${mirror#${scheme}://}"
		else
			path="$mirror"
		fi
		if [ "$scheme" == "file" ]; then
			# Skip file:// mirror locations (/some/where or file:///some/where)
			# where the specified directory does not exist
			if [ ! -d "$path" ]; then
				msg_warn "$pkgver: mount point $path does not exist...\n"
				continue
			fi
		fi
		if [[ "$mirror" == *voidlinux* ]]; then
			# For distfiles.voidlinux.* append the subdirectory
			mirror="$mirror/$subdir"
		fi
		msg_normal "$pkgver: fetching distfile '$curfile' from '$mirror'...\n"
		$XBPS_FETCH_CMD "$mirror/$basefile"
		# If basefile was not found, but a curfile file may exist, try to fetch it
		if [ ! -f "$distfile" -a "$basefile" != "$curfile" ]; then
			$XBPS_FETCH_CMD "$mirror/$curfile"
		fi
		[ ! -f "$distfile" ] && continue
		flock -n ${distfile}.part rm -f ${distfile}.part
		filesum=$(${XBPS_DIGEST_CMD} "$distfile")
		[ "$cksum" == "$filesum" ] && break
		msg_normal "$pkgver: checksum failed - removing '$curfile'...\n"
		rm -f ${distfile}
	done
}

hook() {
	local srcdir="$XBPS_SRCDISTDIR/$pkgname-$version"
	local dfcount=0 errors=0

	if [ ! -d "$srcdir" ]; then
		mkdir -p -m775 "$srcdir"
		chgrp $(id -g) "$srcdir"
	fi

	cd $srcdir || msg_error "$pkgver: cannot change dir to $srcdir!\n"

	# Disable trap on ERR; the code is smart enough to report errors and abort.
	trap - ERR

	for f in ${distfiles}; do
		curfile=$(basename "${f#*>}")
		distfile="$srcdir/$curfile"

		# If file lock cannot be acquired wait until it's available.
		while true; do
			flock -w 1 ${distfile}.part true
			[ $? -eq 0 ] && break
			msg_warn "$pkgver: ${curfile} is being already downloaded, waiting for 1s ...\n"
		done
		# If distfile does not exist, try to link to it.
		if [ ! -f "$distfile" ]; then
			link_cksum $curfile $distfile $dfcount
		fi
		# If distfile does not exist, download it from a mirror location.
		if [ ! -f "$distfile" ]; then
			try_mirrors $curfile $distfile $dfcount $pkgname-$version $f
		fi
		# If distfile does not exist, download it from the original location.
		if [ ! -f "$distfile" ]; then
			msg_normal "$pkgver: fetching distfile '$curfile'...\n"
			flock "${distfile}.part" $XBPS_FETCH_CMD "$f"
		fi
		if [ ! -f "$distfile" ]; then
			msg_error "$pkgver: failed to fetch $curfile.\n"
		fi
		# distfile downloaded, verify sha256 hash.
		flock -n ${distfile}.part rm -f ${distfile}.part
		verify_cksum $curfile $distfile $dfcount
		dfcount=$(($dfcount + 1))
	done

	if [ $errors -gt 0 ]; then
		msg_error "$pkgver: couldn't verify distfiles, exiting...\n"
	fi
}
