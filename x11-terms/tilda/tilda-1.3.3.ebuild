# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils autotools

DESCRIPTION="A Gtk based drop down terminal for Linux and Unix"
GITHUB_USER="lanoxx"
HOMEPAGE="https://github.com/${GITHUB_USER}/${PN}"
SRC_URI="https://github.com/${GITHUB_USER}/${PN}/archive/${P}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 ~ppc64 ~arm"
IUSE=""

RDEPEND=">=x11-libs/gtk+-3.10.0:3
	gnome-base/libglade
	x11-libs/vte:0
	dev-libs/confuse
	x11-libs/libX11"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${PN}-${PN}-${PV}"

src_prepare() {
	eautoreconf
}
