# Copyright 2008-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils toolchain-funcs cmake-utils

if [[ ${PV} == *9999* ]]; then
        inherit git-2
        EGIT_REPO_URI="https://github.com/PointCloudLibrary/pcl.git"
        SRC_URI=""
        KEYWORDS=""
else
        SRC_URI="mirror://sourceforge/pointclouds/${PV}/${MY_P}-Source.tar.bz2"
        KEYWORDS="~amd64 ~x86"
fi

MY_P=PCL-${PV}

DESCRIPTION="The Point Cloud Library (or PCL) is a large scale, open project for 3D point cloud processing."
HOMEPAGE="http://www.pointclouds.org"
LICENSE="BSD"
SLOT="0"
IUSE="cuda doc mpi +tools +vtk"

RDEPEND="
	>=dev-libs/boost-1.46
	dev-cpp/eigen:3
	>=sci-libs/flann-1.7.1
	>=media-libs/qhull-2010.1
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4 )
	mpi? ( virtual/mpi )
	vtk? ( >=sci-libs/vtk-5.6.0 )
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
"

CMAKE_BUILD_TYPE="Release"

S=${WORKDIR}/${MY_P}-Source

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with mpi)
		$(cmake-utils_use_with vtk)
		$(cmake-utils_use_with cuda)
		$(cmake-utils_use_build doc)
		$(cmake-utils_use_build tools)
		-DWITH_CUDA=ON -DBUILD_CUDA=ON -DBUILD_GPU=ON -DBUILD_apps=ON -DBUILD_cuda_common=ON -DBUILD_cuda_io=ON -DBUILD_cuda_apps=ON -DBUILD_gpu_tracking=ON -DBUILD_gpu_surface=ON
	)

	cmake-utils_src_configure
}
