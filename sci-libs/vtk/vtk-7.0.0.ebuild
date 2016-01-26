# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/vtk/vtk-6.0.0.ebuild,v 1.6 2014/02/03 12:30:03 jlec Exp $

EAPI=5

inherit eutils flag-o-matic qt4-r2 versionator toolchain-funcs cmake-utils

# Short package version
SPV="$(get_version_component_range 1-2)"
LPV="$(get_version_component_range 1-3)"

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="http://www.vtk.org/"
SRC_URI="http://www.${PN}.org/files/release/${SPV}/VTK-${LPV}.rc2.tar.gz"

LICENSE="BSD LGPL-2"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="examples cg video_cards_nvidia"

REQUIRED_USE=""

RDEPEND="
    dev-libs/expat
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
    >=dev-libs/boost-1.40.0
    cg? ( media-gfx/nvidia-cg-toolkit )
    virtual/ffmpeg
    examples? (
        dev-qt/qtcore:4
        dev-qt/qtgui:4
        sci-libs/vtkdata
    )
    dev-qt/designer:4
    dev-qt/qtcore:4
    dev-qt/qtgui:4
    dev-qt/qtopengl:4
    dev-qt/qtsql:4
    dev-qt/qtwebkit:4"
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
    mycmakeargs+=(
        -DVTK_DIR="${S}"
        -DVTK_INSTALL_LIBRARY_DIR=$(get_libdir)
        -DVTK_DATA_ROOT:PATH="${EPREFIX}/usr/share/${PN}/data"
        -DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
    )

    local mycmakeargs=(
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_EXAMPLES=ON
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_TESTING=OFF
        -DBUILD_USER_DEFINED_LIBS=OFF
    )

    mycmakeargs+=(
        -DVTK_Group_Imaging=ON
        -DVTK_Group_MPI=OFF
        -DVTK_Group_Qt=ON
        -DVTK_Group_Rendering=ON
        -DVTK_Group_StandAlone=ON
        -DVTK_Group_Tk=OFF
        -DVTK_Group_Views=OFF
        -DVTK_Group_Web=OFF
    )

    mycmakeargs+=(
        -DVTK_EXTRA_COMPILER_WARNINGS=ON
        -DVTK_USE_CXX11_FEATURES=ON
        -DVTK_USE_OFFSCREEN=OFF
        -DVTK_USE_OFFSCREEN_EGL=OFF
        -DVTK_USE_SYSTEM_EXPAT=ON
        -DVTK_USE_SYSTEM_FREETYPE=ON
        -DVTK_USE_SYSTEM_GLEW=ON
        -DVTK_USE_SYSTEM_HDF5=ON
        -DVTK_USE_SYSTEM_JPEG=ON
        -DVTK_USE_SYSTEM_JSONCPP=ON
        -DVTK_USE_SYSTEM_LIBPROJ4=ON
        -DVTK_USE_SYSTEM_LIBRARIES=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        -DVTK_USE_SYSTEM_NETCDF=ON
        -DVTK_USE_SYSTEM_OGGTHEORA=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_USE_X=ON
    )

    mycmakeargs+=(
        -DVTK_WRAP_JAVA=OFF
        -DVTK_WRAP_PYTHON=OFF
        -DVTK_WRAP_TCL=OFF
    )

    cmake-utils_src_configure
}


src_install() {
    cmake-utils_src_install

    # install examples
    if use examples; then
        insinto /usr/share/${PN}
        mv -v Examples examples || die
        doins -r examples
    fi

    # environment
    #cat >> "${T}"/40${PN} <<- EOF
    #VTK_DATA_ROOT=${EPREFIX}/usr/share/${PN}/data
    #VTK_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}-${SPV}
    #VTKHOME=${EPREFIX}/usr
    #EOF
    #doenvd "${T}"/40${PN}
}
