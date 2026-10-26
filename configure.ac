dnl Copyright (C) 2026  Barry Schwartz

dnl Permission is hereby granted, free of charge, to any person obtaining a copy
dnl of this software and associated documentation files (the "Software"), to deal
dnl in the Software without restriction, including without limitation the rights
dnl to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
dnl copies of the Software, and to permit persons to whom the Software is
dnl furnished to do so, subject to the following conditions:
dnl The above copyright notice and this permission notice shall be included in
dnl all copies or substantial portions of the Software.

dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
dnl IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
dnl FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
dnl AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
dnl LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
dnl OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
dnl THE SOFTWARE.

AC_PREREQ([2.72])
AC_INIT([gaigen-flake],[1.0.0])

AC_CONFIG_SRCDIR([this.is.gaigen-flake])
AC_CONFIG_AUX_DIR([build-aux])

AC_PROG_MKDIR_P
AC_PROG_SED
AC_CHECK_PROGS([NIXFMT],[nixfmt])

nixpkgs_versions='release-26.05 nixos-unstable'
systems='x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin'

AC_ARG_VAR([SYSTEM],[such as "x86_64-linux aarch64-linux" (space separated)])
if test "${ac_cv_env_SYSTEM_set}" != set; then
   SYSTEM="${systems}"
fi

AC_ARG_VAR([NIXPKGS_VERSION],[such as "release-26.05 nixos-unstable" (space separated)])
if test "${ac_cv_env_NIXPKGS_VERSION_set}" != set; then
   NIXPKGS_VERSION="${nixpkgs_versions}"
fi

AC_CONFIG_COMMANDS([flake-diversification],
[
  for system in ${system_list}; do
    for nixpkgs in ${nixpkgs_list}; do
      destdir="${builddir}/${system}/${nixpkgs}"
      ${MKDIR_P} "${destdir}"
      ${SED} < "${srcdir}"/flake.nix.in > "${destdir}"/flake.nix \
        -e "s/@SYSTEM@/${system}/g" \
        -e "s/@NIXPKGS_VERSION@/${nixpkgs}/g"
      ${NIXFMT} "${destdir}"/flake.nix
    done
  done
],
[
  MKDIR_P="${MKDIR_P}"
  SED="${SED}"
  NIXFMT="${NIXFMT}"
  srcdir=`realpath "${srcdir}"`
  builddir=`realpath "$(pwd)"`
  system_list="${SYSTEM}"
  nixpkgs_list="${NIXPKGS_VERSION}"
])

AC_OUTPUT

# local variables:
# coding: utf-8
# end:
