# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2 mate optfeature

MINOR=$(($(ver_cut 2) % 2))
if [[ ${MINOR} -eq 0 ]]; then
	KEYWORDS="amd64 ~arm ~arm64 ~loong ~riscv x86"
fi

DESCRIPTION="The MATE image viewer"
LICENSE="FDL-1.1+ GPL-2+ IJG LGPL-2+"
SLOT="0"

IUSE="X debug exif imagemagick +introspection nls jpeg lcms svg tiff xmp"

COMMON_DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0
	>=dev-libs/glib-2.52:2
	>=dev-libs/libpeas-1.8.0:0[gtk]
	>=dev-libs/libxml2-2:2=
	gnome-base/dconf
	>=mate-base/mate-desktop-$(ver_cut 1-2)
	sys-libs/zlib
	x11-libs/cairo
	>=x11-libs/gdk-pixbuf-2.36.5:2[introspection?,jpeg?,tiff?]
	>=x11-libs/gtk+-3.22:3[introspection?]
	x11-libs/libX11
	>=x11-misc/shared-mime-info-0.20
	exif? (
		>=media-libs/libexif-0.6.22
		media-libs/libjpeg-turbo:=
	)
	imagemagick? ( >=media-gfx/imagemagick-6.2.6 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.3:= )
	jpeg? ( media-libs/libjpeg-turbo:= )
	lcms? ( media-libs/lcms:2 )
	svg? ( >=gnome-base/librsvg-2.36.2:2 )
	xmp? ( >=media-libs/exempi-1.99.5:2= )
"

RDEPEND="${COMMON_DEPEND}
	virtual/libintl
"

BDEPEND="${COMMON_DEPEND}
	app-text/yelp-tools
	dev-util/glib-utils
	dev-util/gtk-doc
	dev-build/gtk-doc-am
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_configure() {
	mate_src_configure \
		--enable-thumbnailer \
		$(use_enable debug) \
		$(use_enable introspection) \
		$(use_with X x) \
		$(use_with exif libexif) \
		$(usex imagemagick \
			--without-gdk-pixbuf-thumbnailer \
			--with-gdk-pixbuf-thumbnailer \
		) \
		$(use_with jpeg libjpeg) \
		$(use_with lcms cms) \
		$(use_with svg librsvg) \
		$(use_with xmp)
}

pkg_postinst() {
	gnome2_pkg_postinst
	optfeature "webp support" gui-libs/gdk-pixbuf-loader-webp
}
