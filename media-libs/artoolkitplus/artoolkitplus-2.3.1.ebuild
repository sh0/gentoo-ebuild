# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit base cmake-utils

DESCRIPTION="ARToolKitPlus library"
HOMEPAGE="https://launchpad.net/artoolkitplus"
SRC_URI="https://launchpad.net/artoolkitplus/trunk/${PV}/+download/ARToolKitPlus-${PV}.tar.bz2"

S="${WORKDIR}/ARToolKitPlus-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+boost examples"
RDEPEND=""
DEPEND="boost? ( dev-libs/boost )"

src_unpack() {
    local old
    old=$((${#S}-${#P}+${#PN}))
    unpack ${A}
    mv "${S:0:${old}}" "${S}"
    cd "${S}"
    sed -i 's/protected:/public:/g' include/ARToolKitPlus/Camera.h || die
}

src_configure() {
    local mycmakeargs=( )
    if use boost; then
        mycmakeargs+=( "-DARTK_USE_BOOST=TRUE" )
    fi
    if use examples; then
        mycmakeargs+=( "-DARTK_BUILD_EXAMPLES=TRUE" )
    fi
    cmake-utils_src_configure
}
