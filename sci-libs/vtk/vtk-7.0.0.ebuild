# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils flag-o-matic versionator toolchain-funcs cmake-utils python-single-r1

SPV="$(get_version_component_range 1-2)"
LPV="$(get_version_component_range 1-3)"

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="http://www.vtk.org/"
SRC_URI="http://www.${PN}.org/files/release/${SPV}/VTK-${LPV}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD LGPL-2"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="cg examples python"

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
    sci-libs/proj
    virtual/jpeg
    virtual/opengl
    >=x11-libs/gl2ps-1.3.8
    x11-libs/libX11
    x11-libs/libXmu
    x11-libs/libXt
    >=dev-libs/boost-1.40.0
    virtual/ffmpeg
    cg? ( media-gfx/nvidia-cg-toolkit )
    examples? ( >=sci-libs/vtkdata-7.0.0 )
    python? (
        ${PYTHON_DEPS}
        dev-python/autobahn[${PYTHON_USEDEP}]
        dev-python/six[${PYTHON_USEDEP}]
        dev-python/twisted-core
        dev-python/zope-interface[${PYTHON_USEDEP}]
    )
    dev-qt/designer:5
    dev-qt/qtcore:5
    dev-qt/qtgui:5
    dev-qt/qtopengl:5
    dev-qt/qtsql:5
    dev-qt/qtwebkit:5
    dev-qt/qtconcurrent:5"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE="RelWithDebInfo"

S="${WORKDIR}"/VTK-${LPV}

pkg_setup() {
    append-cppflags -D__STDC_CONSTANT_MACROS -D_UNICODE
}

src_prepare() {
    # Fix PROJ.4 library code
    #sed \
    #    -e 's:proj4:proj:g' \
    #    -e 's:libproj4:libproj:g' \
    #    -e 's:lib_proj.h:proj_api.h:g' \
    #    -i CMake/FindLIBPROJ4.cmake || die
    #sed \
    #    -e 's:lib_proj.h:proj_api.h:g' \
    #    -i ThirdParty/libproj4/vtk_libproj4.h.in || die

    # Remove third party libs
    local x
    for x in expat freetype gl2ps hdf5 jpeg libxml2 netcdf oggtheora png tiff zlib; do # libproj4
        rm -r ThirdParty/${x}/vtk${x} || die
    done

    # Replace relative path ../../../VTKData with absloute path
    # otherwise it will break on symlinks.
    grep -rl '\.\./\.\./\.\./\.\./VTKData' . | xargs \
        sed \
            -e "s|\.\./\.\./\.\./\.\./VTKData|${EPREFIX}/usr/share/vtk/data|g" \
            -e "s|\.\./\.\./\.\./\.\./\.\./VTKData|${EPREFIX}/usr/share/vtk/data|g" \
            -i || die

    cmake-utils_src_prepare
}

src_configure() {
    local mycmakeargs=(
        -DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
        -DVTK_DIR="${S}"
        -DVTK_INSTALL_LIBRARY_DIR=$(get_libdir)
        -DVTK_DATA_ROOT:PATH="${EPREFIX}/usr/share/${PN}/data"
        -DVTK_RENDERING_BACKEND="OpenGL"
        -DVTK_QT_VERSION=5
    )

    mycmakeargs+=(
        -DBUILD_DOCUMENTATION=OFF
        $(cmake-utils_use_build examples EXAMPLES)
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
        -DVTK_Group_Views=ON
        -DVTK_Group_Web=ON
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
        -DVTK_USE_SYSTEM_LIBPROJ4=OFF
        -DVTK_USE_SYSTEM_LIBRARIES=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        -DVTK_USE_SYSTEM_NETCDF=ON
        -DVTK_USE_SYSTEM_OGGTHEORA=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_USE_SYSTEM_AUTOBAHN=ON
        -DVTK_USE_SYSTEM_SIX=ON
        -DVTK_USE_SYSTEM_TWISTED=ON
        -DVTK_USE_SYSTEM_ZOPE=ON
        -DVTK_USE_X=ON
    )

    mycmakeargs+=(
        -DVTK_WRAP_JAVA=OFF
        $(cmake-utils_use python VTK_WRAP_PYTHON)
        -DVTK_WRAP_TCL=OFF
    )

    cmake-utils_src_configure
}


src_install() {
    cmake-utils_src_install

    # Examples
    if use examples; then
        insinto /usr/share/${PN}
        mv -v Examples examples || die
        doins -r examples
    fi

    # Environment
    echo "VTK_DATA_ROOT=${EPREFIX}/usr/share/${PN}/data" > "${T}"/40${PN}
    echo "VTK_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}-${SPV}" >> "${T}"/40${PN}
    echo "VTKHOME=${EPREFIX}/usr" >> "${T}"/40${PN}
    doenvd "${T}"/40${PN}
}
