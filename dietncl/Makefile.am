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
include $(top_srcdir)/build-aux/Makefile.am.link

AM_CPPFLAGS= -I$(top_srcdir)/dietncl -I$(top_builddir)/dietncl
AM_CFLAGS= $(WERROR_CFLAGS) $(WARN_CFLAGS) $(LUA_CFLAGS)
AM_LDFLAGS= -module $(LT_MODULE_LDFLAGS)

dietncllib_LTLIBRARIES=  xmllib.la
xmllib_la_DEPENDENCIES= $(xmllib_def_depedency)
xmllib_la_CFLAGS= $(AM_CFLAGS) $(GLIB_CFLAGS)
xmllib_la_LDFLAGS= $(AM_LDFLAGS) $(GLIB_LIBS)
xmllib_la_SOURCES= xmllib.c
