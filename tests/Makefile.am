# Copyright (C) 2013-2017 PUC-Rio/Laboratorio TeleMidia
#
# This file is part of DietNCL.
#
# DietNCL is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DietNCL is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DietNCL.  If not, see <http://www.gnu.org/licenses/>.

include $(top_srcdir)/build-aux/Makefile.am.common

AM_CPPFLAGS= -I$(top_srcdir)/lib -I$(top_builddir)/lib\
  -DTOP_SRCDIR=\"$(top_srcdir)\" -DTOP_BUILDDIR=\"$(top_builddir)\"

AM_CFLAGS= $(WERROR_CFLAGS) $(LUA_CFLAGS)
AM_LDFLAGS= -static $(LUA_LIBS)

# Auxiliary programs.
noinst_PROGRAMS= lua
noinst_SCRIPTS=

# Generate env.sh, env.csh, and gdb.cfg.
include $(top_srcdir)/build-aux/Makefile.am.env

# Configure Valgrind and generate suppfile from suppfile.m4.
include $(top_srcdir)/build-aux/Makefile.am.valgrind

# Setup test framework.
AM_COLOR_TESTS= always
DISABLE_HARD_ERRORS= true
TEST_EXTENSIONS= .lua .sh
LOG_COMPILER= $(_VALGRIND)
LUA_LOG_COMPILER= $(_VALGRIND) $(builddir)/lua
SH_LOG_COMPILER= $(SHELL)

# Setup tests environment.
xmllib_so= xmllib$(SOEXT)
LD_PRELOAD= $(xmllib_so)
AM_TESTS_ENVIRONMENT=\
  export G_DEBUG="all";\
  export G_SLICE="always-malloc";\
  export LD_LIBRARY_PATH="$(top_builddir)/dietncl";\
  export LD_PRELOAD="$(LD_PRELOAD)";\
  export LUA_CPATH="$(builddir)/.libs/?$(SOEXT);$(top_builddir)/?$(SOEXT);;";\
  export LUA_PATH="$(top_srcdir)/?.lua;$(top_srcdir)/?/init.lua;$(top_srcdir)/tests/?.lua;;";\
  export MALLOC_CHECK_=1;\
  $(NULL)

# Test scripts.
scripts=
scripts+= test-filter-descriptor.lua
scripts+= test-filter-import.lua
scripts+= test-filter-norm1.lua
scripts+= test-filter-prenorm1.lua
scripts+= test-filter-prenorm2.lua
scripts+= test-filter-prenorm3.lua
scripts+= test-filter-prenorm4.lua
scripts+= test-filter-prenorm5.lua
scripts+= test-filter-region.lua
scripts+= test-filter-remove_component.lua
scripts+= test-filter-transition.lua
scripts+= test-init-parse.lua
scripts+= test-init-parsestring.lua
scripts+= test-nclaux-gen-id.lua
scripts+= test-nclaux-timetoseconds.lua
scripts+= test-path-absolute.lua
scripts+= test-path-join.lua
scripts+= test-path-relative.lua
scripts+= test-path-split.lua
scripts+= test-xmlsugar-attributes.lua
scripts+= test-xmlsugar-children.lua
scripts+= test-xmlsugar-clone.lua
scripts+= test-xmlsugar-equal.lua
scripts+= test-xmlsugar-eval.lua
scripts+= test-xmlsugar-gmatch.lua
scripts+= test-xmlsugar-insert.lua
scripts+= test-xmlsugar-match.lua
scripts+= test-xmlsugar-remove.lua
scripts+= test-xmlsugar-replace.lua
scripts+= test-xmlsugar-userdata.lua
check_SCRIPTS= $(scripts)

TESTS= $(check_SCRIPTS)
EXTRA_DIST=\
  $(check_SCRIPTS)\
  util.lua\
  $(NULL)

CLEANFILES+= *.log *.trs
