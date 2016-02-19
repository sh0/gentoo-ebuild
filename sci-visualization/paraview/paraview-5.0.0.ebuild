# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils flag-o-matic multilib versionator cmake-utils python-single-r1

MAIN_PV=$(get_major_version)
MAJOR_PV=$(get_version_component_range 1-2)
MY_P="ParaView-v${PV}-source"

DESCRIPTION="ParaView is a powerful scientific data visualization application"
HOMEPAGE="http://www.paraview.org"
SRC_URI="http://www.paraview.org/files/v${MAJOR_PV}/${MY_P}.tar.gz"
RESTRICT="mirror"

LICENSE="paraview GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="doc examples python"

REQUIRED_USE=""

RDEPEND="
    dev-libs/expat
    >=dev-libs/jsoncpp-0.10.1
    dev-libs/libxml2:2
    dev-libs/protobuf
    media-libs/freetype
    media-libs/libpng:0
    media-libs/libtheora
    media-libs/tiff:0=
    sci-libs/hdf5
    >=sci-libs/netcdf-4.2[hdf5]
    >=sci-libs/netcdf-cxx-4.2:3
    sys-libs/zlib
    virtual/jpeg:0
    virtual/opengl
    virtual/ffmpeg
    >=x11-libs/gl2ps-1.3.8
    x11-libs/libX11
    x11-libs/libXext
    x11-libs/libXmu
    x11-libs/libXt
    dev-libs/pugixml
    dev-db/sqlite:3
    python? (
        ${PYTHON_DEPS}
        dev-python/autobahn[${PYTHON_USEDEP}]
        dev-python/six[${PYTHON_USEDEP}]
        dev-python/twisted-core
        dev-python/zope-interface[${PYTHON_USEDEP}]
        dev-python/matplotlib[${PYTHON_USEDEP}]
        dev-python/numpy[${PYTHON_USEDEP}]
        dev-python/sip[${PYTHON_USEDEP}]
        dev-python/PyQt5[opengl,webkit,${PYTHON_USEDEP}]
    )
    dev-qt/designer:5
    dev-qt/qtgui:5
    dev-qt/qtopengl:5
    dev-qt/qthelp:5
    dev-qt/qtsql:5
    dev-qt/qtwebkit:5
    dev-qt/qttest:5"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE="RelWithDebInfo"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
    python-single-r1_pkg_setup
    PVLIBDIR=$(get_libdir)/${PN}-${MAJOR_PV}
}

src_configure() {
    local mycmakeargs=(
        # Build
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_TESTING=OFF
        # Paraview
        -DPARAVIEW_BUILD_QT_GUI=ON
        -DPARAVIEW_QT_VERSION=5
        -DPARAVIEW_ENABLE_CATALYST=ON
        -DPARAVIEW_ENABLE_FFMPEG=ON
        # VTK
        -DVTK_QT_VERSION=5
        -DVTK_RENDERING_BACKEND="OpenGL2"
    )

    mycmakeargs+=(
        -DVTK_USE_SYSTEM_EXPAT=ON
        -DVTK_USE_SYSTEM_FREETYPE=ON
        -DVTK_USE_SYSTEM_GL2PS=ON
        -DVTK_USE_SYSTEM_GLEW=ON
        -DVTK_USE_SYSTEM_HDF5=ON
        -DVTK_USE_SYSTEM_JPEG=ON
        -DVTK_USE_SYSTEM_JSONCPP=ON
        -DVTK_USE_SYSTEM_LIBRARIES=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        -DVTK_USE_SYSTEM_NETCDF=ON
        -DVTK_USE_SYSTEM_OGGTHEORA=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_PROTOBUF=ON
        -DVTK_USE_SYSTEM_PUGIXML=ON
        -DVTK_USE_SYSTEM_QTTESTING=OFF
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_XDMF2=OFF
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_USE_SYSTEM_AUTOBAHN=ON
        -DVTK_USE_SYSTEM_SIX=ON
        -DVTK_USE_SYSTEM_TWISTED=ON
        -DVTK_USE_SYSTEM_ZOPE=ON
    )

    mycmakeargs+=(
        # Paths
        -DPV_INSTALL_LIB_DIR="${PVLIBDIR}"
        -DCMAKE_INSTALL_PREFIX="${EPREFIX}"/usr
        # Expat
        -DEXPAT_INCLUDE_DIR="${EPREFIX}"/usr/include
        -DEXPAT_LIBRARY="${EPREFIX}"/usr/$(get_libdir)/libexpat.so
        # OpenGL
        -DOPENGL_gl_LIBRARY="${EPREFIX}"/usr/$(get_libdir)/libGL.so
        -DOPENGL_glu_LIBRARY="${EPREFIX}"/usr/$(get_libdir)/libGLU.so
    )

    cmake-utils_src_configure
}

src_install() {
    cmake-utils_src_install

    # Environment
    echo "LDPATH=${EPREFIX}/usr/${PVLIBDIR}" > "${T}"/40${PN}

    # Desktop
    newicon "${S}"/Applications/ParaView/pvIcon-96x96.png paraview.png
    make_desktop_entry paraview "Paraview" paraview
}
