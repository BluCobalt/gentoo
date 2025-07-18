# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake flag-o-matic python-any-r1

DESCRIPTION="A linkable library for Git"
HOMEPAGE="https://libgit2.org/"
SRC_URI="
	https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
"
S=${WORKDIR}/${P/_/-}

LICENSE="GPL-2-with-linking-exception"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="amd64 arm arm64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="examples gssapi +ssh test +threads trace"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libpcre2:=
	net-libs/llhttp:=
	sys-libs/zlib
	dev-libs/openssl:0=
	gssapi? ( virtual/krb5 )
	ssh? ( net-libs/libssh2 )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

src_prepare() {
	cmake_src_prepare

	# https://bugs.gentoo.org/948941
	sed -i -e 's:-Werror::' tests/headertest/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DUSE_SSH=$(usex ssh libssh2 OFF)
		-DUSE_GSSAPI=$(usex gssapi ON OFF)
		-DUSE_HTTP_PARSER=llhttp
		-DREGEX_BACKEND=pcre2
	)
	# https://bugs.gentoo.org/925207
	append-lfs-flags
	cmake_src_configure
}

src_test() {
	if [[ ${EUID} -eq 0 ]] ; then
		# repo::iterator::fs_preserves_error fails if run as root
		# since root can still access dirs with 0000 perms
		ewarn "Skipping tests: non-root privileges are required for all tests to pass"
	else
		local TEST_VERBOSE=1
		cmake_src_test -R offline
	fi
}

src_install() {
	cmake_src_install
	dodoc docs/*.{md,txt}

	if use examples ; then
		find examples -name '.gitignore' -delete || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
