# cfg.mk -- Setup maintainer's makefile.
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

COPYRIGHT_YEAR= 2017
COPYRIGHT_HOLDER= PUC-Rio/Laboratorio TeleMidia

INDENT_EXCLUDE=
INDENT_JOIN_EMPTY_LINES_EXCLUDE=
INDENT_TYPES=

SC_USELESS_IF_BEFORE_FREE_ALIASES=\
  g_free\
  $(NULL)

SC_COPYRIGHT_EXCLUDE=\
  build-aux/%\
  dietncl/luax-macros.h\
  dietncl/macros.h\
  maint.mk\
  tests/lua.c\
  $(NULL)

SC_RULES+= sc-copyright
sc-copyright:
	$(V_at)$(build_aux)/syntax-check-copyright\
	  -b='/*' -e='*/' -t=cfg.mk\
	  $(call vc_list_exclude, $(VC_LIST_C), $(SC_COPYRIGHT_EXCLUDE))
	$(V_at)$(build_aux)/syntax-check-copyright\
	  -b='#' -t=cfg.mk\
	  $(call vc_list_exclude,\
	    $(VC_LIST_AC)\
	    $(VC_LIST_AM)\
	    $(VC_LIST_MK)\
	    $(VC_LIST_PL)\
	    $(VC_LIST_SH),\
	    $(SC_COPYRIGHT_EXCLUDE))

# Files copied from the NCLua project.
nclua:= https://github.com/gflima/nclua/raw/master
NCLUA_FILES+= build-aux/Makefile.am.common
NCLUA_FILES+= build-aux/Makefile.am.coverage
NCLUA_FILES+= build-aux/Makefile.am.env
NCLUA_FILES+= build-aux/Makefile.am.gitlog
NCLUA_FILES+= build-aux/Makefile.am.link
NCLUA_FILES+= build-aux/Makefile.am.valgrind
NCLUA_FILES+= build-aux/util.m4
NCLUA_FILES+= maint.mk
NCLUA_FILES+= tests/lua.c
NCLUA_FILES+= lib/luax-macros.h
NCLUA_FILES+= lib/macros.h
NCLUA_SCRIPTS+= bootstrap
NCLUA_SCRIPTS+= build-aux/syntax-check
NCLUA_SCRIPTS+= build-aux/syntax-check-copyright
REMOTE_FILES+= $(NCLUA_FILES)
REMOTE_SCRIPTS+= $(NCLUA_SCRIPTS)

.PHONY: fetch-remote-local-nclua
fetch-remote-local-nclua:
	$(V_at)for path in $(NCLUA_FILES) $(NCLUA_SCRIPTS); do\
	  if test `dirname "$$path"` = "lib"; then\
	    dir=dietncl;\
	  else\
	    dir=`dirname "$$path"`;\
	  fi;\
	  $(FETCH) -dir="$$dir" "$(nclua)/$$path" || exit 1;\
	done

fetch-remote-local: fetch-remote-local-nclua
