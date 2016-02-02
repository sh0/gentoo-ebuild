# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit toolchain-funcs cmake-utils

# Package version
SPV="$(get_version_component_range 1-2)"
LPV="$(get_version_component_range 1-3)rc1"

DESCRIPTION="The Point Cloud Library (or PCL) is a large scale, open project for 3D point cloud processing."
HOMEPAGE="http://www.pointclouds.org"
SRC_URI="https://github.com/PointCloudLibrary/${PN}/archive/${PN}-${LPV}.tar.gz"

LICENSE="BSD"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="cuda +tools +vtk"

REQUIRED_USE=""

RDEPEND="
    >=dev-libs/boost-1.47
    dev-cpp/eigen:3
    >=sci-libs/flann-1.7.1
    >=media-libs/qhull-2010.1
    cuda? ( >=dev-util/nvidia-cuda-toolkit-4 )
    vtk? ( >=sci-libs/vtk-7.0.0 )
    dev-qt/qtcore:5
    dev-qt/qtgui:5
"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE="RelWithDebInfo"

S="${WORKDIR}"/${PN}-${PN}-${LPV}

src_configure() {
    local mycmakeargs=(
        $(cmake-utils_use_with cuda)
        -DWITH_DAVIDSDK=OFF
        -DWITH_DOCS=OFF
        -DWITH_DSSDK=OFF
        -DWITH_ENSENSO=OFF
        -DWITH_FZAPI=OFF
        -DWITH_LIBUSB=ON
        -DWITH_OPENGL=ON
        -DWITH_OPENNI=OFF
        -DWITH_OPENNI2=OFF
        -DWITH_PCAP=OFF
        -DWITH_PNG=ON
        -DWITH_QHULL=ON
        -DWITH_QT=ON
        -DWITH_RSSDK=OFF
        $(cmake-utils_use_with vtk)
        $(cmake-utils_use_build cuda CUDA)
        $(cmake-utils_use_build cuda GPU)
        $(cmake-utils_use_build tools)
    )

    mycmakeargs+=(
        -DPCL_QT_VERSION=5
        -DPCL_SHARED_LIBS=ON
    )

    cmake-utils_src_configure
}
