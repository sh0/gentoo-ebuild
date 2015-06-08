# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic qt4-r2 versionator toolchain-funcs cmake-utils

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="http://www.vtk.org/"

SPV="$(get_version_component_range 1-2)"
if [[ ${PV} == *9999* ]]; then
	inherit git-2
        EGIT_REPO_URI="git://vtk.org/VTK.git"
        SRC_URI=""
        KEYWORDS=""
else
	SRC_URI="http://www.${PN}.org/files/release/${SPV}/VTK-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="BSD LGPL-2"
SLOT="0"
IUSE="
	boost cg examples imaging ffmpeg mpi mysql odbc
	offscreen postgres qt4 rendering test theora
	video_cards_nvidia views +X"

REQUIRED_USE="^^ ( X offscreen )"

RDEPEND="dev-libs/expat
	dev-libs/libxml2:2
	media-libs/freetype
	media-libs/libpng
	media-libs/mesa
	media-libs/libtheora
	media-libs/tiff
	sci-libs/exodusii
	sci-libs/hdf5
	sci-libs/netcdf-cxx:3
	sys-libs/zlib
	virtual/jpeg
	virtual/opengl
	>=x11-libs/gl2ps-1.3.8
	x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXt
	boost? ( >=dev-libs/boost-1.40.0[mpi?] )
	cg? ( media-gfx/nvidia-cg-toolkit )
	examples? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		sci-libs/vtkdata
	)
	ffmpeg? ( virtual/ffmpeg )
	mpi? ( virtual/mpi[cxx,romio] )
	mysql? ( virtual/mysql )
	odbc? ( dev-db/unixODBC )
	offscreen? ( media-libs/mesa[osmesa] )
	postgres? ( dev-db/postgresql-base )
	qt4? (
		dev-qt/designer:4
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		dev-qt/qtopengl:4
		dev-qt/qtsql:4
		dev-qt/qtwebkit:4
	)
	video_cards_nvidia? ( media-video/nvidia-settings )"

DEPEND="${RDEPEND}"

S="${WORKDIR}"/VTK-${PV}

RESTRICT=test

pkg_setup() {
	append-cppflags -D__STDC_CONSTANT_MACROS -D_UNICODE
}

src_prepare() {
	sed \
		-e 's:libproj4:libproj:g' \
		-e 's:lib_proj.h:lib_abi.h:g' \
		-i CMake/FindLIBPROJ4.cmake || die

	local x
	for x in expat freetype gl2ps hdf5 jpeg libxml2 netcdf oggtheora png tiff zlib; do
		rm -r ThirdParty/${x}/vtk${x} || die
	done

	if use examples || use test; then
		# Replace relative path ../../../VTKData with
		# otherwise it will break on symlinks.
		grep -rl '\.\./\.\./\.\./\.\./VTKData' . | xargs \
			sed \
				-e "s|\.\./\.\./\.\./\.\./VTKData|${EPREFIX}/usr/share/vtk/data|g" \
				-e "s|\.\./\.\./\.\./\.\./\.\./VTKData|${EPREFIX}/usr/share/vtk/data|g" \
				-i || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	# general configuration
	local mycmakeargs=(
		-Wno-dev
		-DVTK_DIR="${S}"
		-DVTK_INSTALL_LIBRARY_DIR=$(get_libdir)
		-DVTK_DATA_ROOT:PATH="${EPREFIX}/usr/share/${PN}/data"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DVTK_CUSTOM_LIBRARY_SUFFIX=""
		-DBUILD_SHARED_LIBS=ON
		-DVTK_USE_SYSTEM_EXPAT=ON
		-DVTK_USE_SYSTEM_FREETYPE=ON
		-DVTK_USE_SYSTEM_FreeType=ON
		-DVTK_USE_SYSTEM_GL2PS=ON
		-DVTK_USE_SYSTEM_HDF5=ON
		-DVTK_USE_SYSTEM_JPEG=ON
		-DVTK_USE_SYSTEM_LIBPROJ4=OFF
		-DVTK_USE_SYSTEM_LIBXML2=ON
		-DVTK_USE_SYSTEM_LibXml2=ON
		-DVTK_USE_SYSTEM_NETCDF=ON
		-DVTK_USE_SYSTEM_OGGTHEORA=ON
		-DVTK_USE_SYSTEM_PNG=ON
		-DVTK_USE_SYSTEM_TIFF=ON
		-DVTK_USE_SYSTEM_ZLIB=ON
		-DVTK_USE_SYSTEM_LIBRARIES=ON
		-DVTK_USE_GL2PS=ON
		-DVTK_USE_PARALLEL=ON
	)

	mycmakeargs+=(
		-DVTK_EXTRA_COMPILER_WARNINGS=ON
		-DVTK_Group_StandAlone=ON
	)

	mycmakeargs+=(
		$(cmake-utils_use_build examples EXAMPLES)
		$(cmake-utils_use_build test TESTING)
		$(cmake-utils_use_build test VTK_BUILD_ALL_MODULES_FOR_TESTS)
		$(cmake-utils_use imaging VTK_Group_Imaging)
		$(cmake-utils_use mpi VTK_Group_MPI)
		$(cmake-utils_use qt4 VTK_Group_Qt)
		$(cmake-utils_use rendering VTK_Group_Rendering)
		$(cmake-utils_use views VTK_Group_Views)
		-DVTK_Group_Tk=OFF
	)

	mycmakeargs+=(
		$(cmake-utils_use boost VTK_USE_BOOST)
		$(cmake-utils_use cg VTK_USE_CG_SHADERS)
		$(cmake-utils_use odbc VTK_USE_ODBC)
		$(cmake-utils_use offscreen VTK_USE_OFFSCREEN)
		$(cmake-utils_use offscreen VTK_OPENGL_HAS_OSMESA)
		$(cmake-utils_use theora VTK_USE_OGGTHEORA_ENCODER)
		$(cmake-utils_use ffmpeg VTK_USE_FFMPEG_ENCODER)
		$(cmake-utils_use video_cards_nvidia VTK_USE_NVCONTROL)
		$(cmake-utils_use X VTK_USE_X)
	)

	if use qt4; then
		mycmakeargs+=(
			-DVTK_USE_QVTK=ON
			-DVTK_USE_QVTK_OPENGL=ON
			-DVTK_USE_QVTK_QTOPENGL=ON
			-DQT_WRAP_CPP=ON
			-DQT_WRAP_UI=ON
			-DVTK_INSTALL_QT_DIR=/$(get_libdir)/qt4/plugins/designer
			-DDESIRED_QT_VERSION=4
			-DQT_MOC_EXECUTABLE="${EPREFIX}/usr/bin/moc"
			-DQT_UIC_EXECUTABLE="${EPREFIX}/usr/bin/uic"
			-DQT_INCLUDE_DIR="${EPREFIX}/usr/include/qt4"
			-DQT_QMAKE_EXECUTABLE="${EPREFIX}/usr/bin/qmake"
		)
	fi

	cmake-utils_src_configure
}

src_install() {
	# install docs
	#HTML_DOCS=( "${S}"/README.html )

	# install package
	cmake-utils_src_install

	# install examples
	if use examples; then
		insinto /usr/share/${PN}
		mv -v Examples examples || die
		doins -r examples
	fi

	# environment
	cat >> "${T}"/40${PN} <<- EOF
	VTK_DATA_ROOT=${EPREFIX}/usr/share/${PN}/data
	VTK_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}-${SPV}
	VTKHOME=${EPREFIX}/usr
	EOF
	doenvd "${T}"/40${PN}
}
