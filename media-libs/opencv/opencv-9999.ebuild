# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/opencv/opencv-2.4.9.ebuild,v 1.2 2014/08/26 22:10:36 amynka Exp $

EAPI=5
PYTHON_COMPAT=( python2_{6,7} )

inherit base toolchain-funcs cmake-utils python-single-r1 java-pkg-opt-2 java-ant-2 git-r3

DESCRIPTION="A collection of algorithms and sample code for various computer vision problems"
HOMEPAGE="http://opencv.willowgarage.com"

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/Itseez/opencv.git"
	SRC_URI=""
else
	SRC_URI="mirror://sourceforge/opencvlibrary/opencv-unix/${PV}/${P}.zip"
fi

LICENSE="BSD"
SLOT="0/3.0"
KEYWORDS=""
IUSE="cuda doc +eigen examples ffmpeg gstreamer gtk ieee1394 ipp jpeg jpeg2k webp opencl openexr opengl openmp pch png +python qt4 testprograms threads tiff v4l vtk xine clp gdal"
REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
"

# The following logic is intrinsic in the build system, but we do not enforce
# it on the useflags since this just blocks emerging pointlessly:
#	gtk? ( !qt4 )
#	opengl? ( || ( gtk qt4 ) )
#	openmp? ( !threads )

RDEPEND="
	app-arch/bzip2
	sys-libs/zlib
	cuda? ( >=dev-util/nvidia-cuda-toolkit-5.5 )
	ffmpeg? ( virtual/ffmpeg )
	gstreamer? (
		media-libs/gstreamer:0.10
		media-libs/gst-plugins-base:0.10
	)
	gtk? (
		dev-libs/glib:2
		x11-libs/gtk+:2
		opengl? ( x11-libs/gtkglext )
	)
	java? ( >=virtual/jre-1.6 )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/jasper )
	webp? ( media-libs/libwebp )
	ieee1394? (
		media-libs/libdc1394
		sys-libs/libraw1394
	)
	ipp? ( sci-libs/ipp )
	opencl? ( virtual/opencl )
	openexr? ( media-libs/openexr )
	opengl? ( virtual/opengl virtual/glu )
	png? ( media-libs/libpng:0= )
	python? ( ${PYTHON_DEPS} dev-python/numpy[${PYTHON_USEDEP}] )
	qt4? (
		dev-qt/qtgui:4
		dev-qt/qttest:4
		opengl? ( dev-qt/qtopengl:4 )
	)
	threads? ( dev-cpp/tbb )
	tiff? ( media-libs/tiff )
	v4l? ( >=media-libs/libv4l-0.8.3 )
	vtk? ( sci-libs/vtk )
	xine? ( media-libs/xine-lib )
	clp? ( sci-libs/coinor-clp )
	gdal? ( sci-libs/gdal )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	eigen? ( dev-cpp/eigen:3 )
	java? ( >=virtual/jdk-1.6 )
"

#PATCHES=(
#	"${FILESDIR}/${PN}-2.3.1a-libav-0.7.patch"
#	"${FILESDIR}/${PN}-2.4.3-gcc47.patch"
#	"${FILESDIR}/${PN}-2.4.2-cflags.patch"
#	"${FILESDIR}/${PN}-2.4.8-javamagic.patch"
#	"${FILESDIR}/${PN}-2.4.9-cuda.patch"
#)

pkg_setup() {
	use python && python-single-r1_pkg_setup
	java-pkg-opt-2_pkg_setup

	git-r3_fetch https://github.com/Itseez/opencv.git HEAD
	git-r3_fetch https://github.com/Itseez/opencv_contrib.git HEAD
	git-r3_checkout https://github.com/Itseez/opencv_contrib.git ${WORKDIR}/${P}/contrib
	chown -R portage:portage ${WORKDIR}/${P}
}

src_prepare() {
	base_src_prepare

	#if [ -d "${S}/contrib" ]; then
	#	(cd "${S}/contrib" && git pull)
	#else
	#	git clone https://github.com/Itseez/opencv.git ${S}/contrib
	#fi

	# remove bundled stuff
	rm -rf 3rdparty
	sed -i \
		-e '/add_subdirectory(3rdparty)/ d' \
		CMakeLists.txt || die

	java-pkg-opt-2_src_prepare
}

src_configure() {
	if use openmp; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi

	JAVA_ANT_ENCODING="iso-8859-1"
	# set encoding so even this cmake build will pick it up.
	export ANT_OPTS+=" -Dfile.encoding=iso-8859-1"
	java-ant-2_src_configure

	# please dont sort here, order is the same as in CMakeLists.txt
	local mycmakeargs=(
	# the optinal dependency libraries
		-DOPENCV_EXTRA_MODULES_PATH="${S}/contrib/modules"
		-DCUDA_ARCH_BIN="3.0 3.5"
		-DCUDA_ARCH_PTX="3.0 3.5"
		$(cmake-utils_use_with ieee1394 1394)
		-DWITH_AVFOUNDATION=OFF
		-DWITH_CARBON=OFF
		$(cmake-utils_use_with vtk VTK)
		# cuda
		$(cmake-utils_use_with eigen)
		$(cmake-utils_use_with ffmpeg)
		$(cmake-utils_use_with gstreamer)
		$(cmake-utils_use_with gtk)
		$(cmake-utils_use_with ipp)
		$(cmake-utils_use_with jpeg2k JASPER)
		$(cmake-utils_use_with jpeg)
		$(cmake-utils_use_with webp)
		$(cmake-utils_use_with openexr)
		$(cmake-utils_use_with opengl)
		-DWITH_OPENNI=OFF					# not packaged
		-DWITH_OPENNI2=OFF					# not packaged
		$(cmake-utils_use_with png)
		-DWITH_PVAPI=OFF					# not packaged
		-DWITH_GIGEAPI=OFF					# not packaged
		# qt
		-DWITH_QUICKTIME=OFF
		$(cmake-utils_use_with threads TBB)
		$(cmake-utils_use_with openmp)
		$(cmake-utils_use_with tiff)
		-DWITH_UNICAP=OFF					# not packaged
		$(cmake-utils_use_with v4l V4L)
		$(cmake-utils_use_with v4l LIBV4L)
		-DWITH_XIMEA=OFF
		$(cmake-utils_use_with xine)
		$(cmake-utils_use_with clp)
		$(cmake-utils_use_with opencl)
		$(cmake-utils_use_with opencl OPENCLAMDFFT)
		$(cmake-utils_use_with opencl OPENCLAMDBLAS)
		-DWITH_IPP_A=OFF
		$(cmake-utils_use_with gdal)
	# bindings
		$(cmake-utils_use_build java opencv_java)
		$(cmake-utils_use_build python opencv_python2)
	# the build components
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_ANDROID_EXAMPLES=OFF
		$(cmake-utils_use_build doc DOCS)
		$(cmake-utils_use_build examples)
		-DBUILD_PERF_TESTS=OFF
		$(cmake-utils_use_build testprograms TESTS)
	# install examples, tests etc
		$(cmake-utils_use examples INSTALL_C_EXAMPLES)
		$(cmake-utils_use testprograms INSTALL_TESTS)
	# build options
		$(cmake-utils_use_enable pch PRECOMPILED_HEADERS)
		-DENABLE_OMIT_FRAME_POINTER=OFF				#
		-DENABLE_FAST_MATH=OFF					#
		-DENABLE_SSE=OFF					# these options do nothing but
		-DENABLE_SSE2=OFF					# add params to CFLAGS
		-DENABLE_SSE3=OFF
		-DENABLE_SSSE3=OFF
		-DENABLE_SSE41=OFF
		-DENABLE_SSE42=OFF
		-DOPENCV_EXTRA_FLAGS_RELEASE=""				# black magic
	)

	if use qt4; then
		mycmakeargs+=( "-DWITH_QT=4" )
	else
		mycmakeargs+=( "-DWITH_QT=OFF" )
	fi

	if use cuda; then
		mycmakeargs+=( "-DWITH_CUDA=ON" )
		mycmakeargs+=( "-DWITH_CUBLAS=ON" )
		mycmakeargs+=( "-DWITH_CUFFT=ON" )
		mycmakeargs+=( "-DWITH_NVCUVID=ON" )
	else
		mycmakeargs+=( "-DWITH_CUDA=OFF" )
		mycmakeargs+=( "-DWITH_CUBLAS=OFF" )
		mycmakeargs+=( "-DWITH_CUFFT=OFF" )
		mycmakeargs+=( "-DWITH_NVCUVID=OFF" )
	fi

	if use examples && use python; then
		mycmakeargs+=( "-DINSTALL_PYTHON_EXAMPLES=ON" )
	else
		mycmakeargs+=( "-DINSTALL_PYTHON_EXAMPLES=OFF" )
	fi

	# things we want to be hard off or not yet figured out
	mycmakeargs+=(
		"-DOPENCV_BUILD_3RDPARTY_LIBS=OFF"
		"-DBUILD_LATEX_DOCS=OFF"
		"-DBUILD_PACKAGE=OFF"
		"-DENABLE_PROFILING=OFF"
	)

	# things we want to be hard enabled not worth useflag
	mycmakeargs+=(
		"-DCMAKE_SKIP_RPATH=ON"
		"-DOPENCV_DOC_INSTALL_PATH=${EPREFIX}/usr/share/doc/${PF}"
	)

	# hardcode cuda paths
	mycmakeargs+=(
		"-DCUDA_NPP_LIBRARY_ROOT_DIR=/opt/cuda"
	)

        # conflicts
        mycmakeargs+=(
                "-DBUILD_opencv_dnn=OFF"
        )

	# workaround for bug 413429
	tc-export CC CXX

	cmake-utils_src_configure
}
