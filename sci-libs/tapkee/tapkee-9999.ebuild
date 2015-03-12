# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils cmake-utils git-2

DESCRIPTION="A flexible and efficient С++ template library for dimension reduction"
HOMEPAGE="http://tapkee.lisitsyn.me/"

EGIT_REPO_URI="https://github.com/sh0/tapkee.git"
SRC_URI=""
KEYWORDS="~amd64 ~x86"

LICENSE="BSD LGPL-2"
SLOT="0"
IUSE="examples"

RDEPEND="
    dev-cpp/eigen
    sci-libs/arpack
    virtual/opencl"

DEPEND="${RDEPEND}"

src_configure() {
    mycmakeargs+=(
        $(cmake-utils_use_build examples EXAMPLES)
    )
    cmake-utils_src_configure
}
