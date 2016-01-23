# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGO_PN="github.com/github/${PN}"

inherit eutils

DESCRIPTION="Git extension for versioning large files"
HOMEPAGE="https://${EGO_PN}"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""

DEPEND="|| ( sys-devel/gcc[go] dev-lang/go )"
RDEPEND="${DEPEND}"

src_compile() {
	./script/bootstrap || die "bootstrap failed"
}

src_install() {
	dobin bin/git-lfs
	dodoc docs/README.md
}
