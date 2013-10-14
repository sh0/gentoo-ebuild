# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

DESCRIPTION="A collection of computer vision algorithms"
HOMEPAGE="http://www.vlfeat.org"
SRC_URI="http://www.vlfeat.org/download/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="octave debug"

RDEPEND=""
DEPEND="${RDEPEND}
    octave? ( sci-mathematics/octave )"

src_compile() {
    if use x86 ; then
        ARCH_VL="glnx86"
    elif use amd64 ; then
        ARCH_VL="glnxa64"
    else
        die "unknown archtecture"
    fi

    sed -i -e "s:-lpthread:-lpthread -Wl,-soname,libvl.so:" make/dll.mak

    emake -j1 CC=$(tc-getCC) ARCH=${ARCH_VL} $(usex octave "MKOCTFILE=mkoctfile" "") $(usex debug "DEBUG" "")
}

src_install() {
    newlib.so bin/${ARCH_VL}/libvl.so libvl.so.${PV}
    dosym libvl.so.${PV} /usr/$(get_libdir)/libvl.so || die "failed to create libvl.so symlink"

    newbin bin/${ARCH_VL}/sift vlfeat-sift
    newbin bin/${ARCH_VL}/mser vlfeat-mser

    insinto /usr/include/vl
    doins vl/*.h

    if use octave ; then
        insinto /usr/share/octave/site/m/${PN}
        doins toolbox/mex/octave/*/vl_*.mex
    fi

    dodoc COPYING README
}
