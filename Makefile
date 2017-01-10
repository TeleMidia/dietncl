# Makefile -- Builds DietNCL.
# Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia
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

BUGSTO= gflima@telemidia.puc-rio.br
COLOR_TESTS?= yes
LDOC?= ldoc
LUA?= lua

TESTS_ENVIRONMENT=\
 LUA_PATH="./tests/?.lua;./?.lua;./?/init.lua;$$LUA_PATH;;" $(LUA)\
 $(NULL)

TESTS_DIR= tests
TESTS=\
 test-filter-import.lua\
 test-filter-prenorm1.lua\
 test-filter-prenorm2.lua\
 test-filter-prenorm3.lua\
 test-filter-prenorm4.lua\
 test-filter-prenorm5.lua\
 test-filter-region.lua\
 test-filter-transition.lua\
 test-filter-unused_media.lua\
 test-init-parse.lua\
 test-init-parsestring.lua\
 test-nclaux-gen-id.lua\
 test-nclaux-timetoseconds.lua\
 test-path-absolute.lua\
 test-path-join.lua\
 test-path-relative.lua\
 test-path-split.lua\
 test-xmlsugar-attributes.lua\
 test-xmlsugar-children.lua\
 test-xmlsugar-clone.lua\
 test-xmlsugar-equal.lua\
 test-xmlsugar-eval.lua\
 test-xmlsugar-gmatch.lua\
 test-xmlsugar-insert.lua\
 test-xmlsugar-match.lua\
 test-xmlsugar-remove.lua\
 test-xmlsugar-replace.lua\
 test-xmlsugar-userdata.lua\
 $(NULL)

XFAIL_TESTS=\
 $(NULL)

all:
.PHONY: all

COPYRIGHT_YEAR := 2015
COPYRIGHT_HOLDER := PUC-Rio/Laboratorio\sTeleMidia
update_copyright_ :=\
  s:(\W*Copyright\s\(C\)\s\d+)-?\d*(\s$(COPYRIGHT_HOLDER)\b)\
   :$$1-$(COPYRIGHT_YEAR)$$2:x

.PHONY: clean
clean:
	-rm -rf ./doc

.PHONY: doc
doc:
	$(LDOC) .

.PHONY: update-copyright
update-copyright:
	perl -i'~' -wpl -e '$(update_copyright_)' `git ls-files`

all_src := `git ls-files '*.lua'`
dietncl_src := `git ls-files 'dietncl/*.lua'`

.PHONY: syntax-check
syntax-check:
	@./build-aux/syntax-check $(all_src)

# Adapted from GNU Automake 1.12.6.
tty_colors= \
red=; grn=; lgn=; blu=; std=; \
test "X$(COLOR_TESTS)" != Xno \
&& test "X$$TERM" != Xdumb \
&& { test "X$(COLOR_TESTS)"= Xalways || test -t 1 2>/dev/null; } \
&& { \
  red='[0;31m'; \
  grn='[0;32m'; \
  lgn='[1;32m'; \
  blu='[1;34m'; \
  std='[m'; \
}

.PHONY: check
check:
	@failed=0; all=0; xfail=0; xpass=0; skip=0;\
	list=' $(TESTS) ';\
	$(tty_colors); \
	if test -n "$$list"; then\
	  for tst in $$list; do \
	    if $(TESTS_ENVIRONMENT) $(TESTS_DIR)/$$tst; then \
	      all=`expr $$all + 1`; \
	      case " $(XFAIL_TESTS) " in \
	      *[\ \	]$$tst[\ \	]*) \
		xpass=`expr $$xpass + 1`; \
		failed=`expr $$failed + 1`; \
		col=$$red; res=XPASS; \
	      ;; \
	      *) \
		col=$$grn; res=PASS; \
	      ;; \
	      esac; \
	    elif test $$? -ne 77; then \
	      all=`expr $$all + 1`; \
	      case " $(XFAIL_TESTS) " in \
	      *[\ \	]$$tst[\ \	]*) \
		xfail=`expr $$xfail + 1`; \
		col=$$lgn; res=XFAIL; \
	      ;; \
	      *) \
		failed=`expr $$failed + 1`; \
		col=$$red; res=FAIL; \
	      ;; \
	      esac; \
	    else \
	      skip=`expr $$skip + 1`; \
	      col=$$blu; res=SKIP; \
	    fi; \
	    echo "$${col}$$res$${std}: $$tst"; \
	  done; \
	  if test "$$all" -eq 1; then \
	    tests="test"; \
	    All=""; \
	  else \
	    tests="tests"; \
	    All="All "; \
	  fi; \
	  if test "$$failed" -eq 0; then \
	    if test "$$xfail" -eq 0; then \
	      banner="$$All$$all $$tests passed"; \
	    else \
	      if test "$$xfail" -eq 1; then failures=failure; else failures=failures; fi; \
	      banner="$$All$$all $$tests behaved as expected ($$xfail expected $$failures)"; \
	    fi; \
	  else \
	    if test "$$xpass" -eq 0; then \
	      banner="$$failed of $$all $$tests failed"; \
	    else \
	      if test "$$xpass" -eq 1; then passes=pass; else passes=passes; fi; \
	      banner="$$failed of $$all $$tests did not behave as expected ($$xpass unexpected $$passes)"; \
	    fi; \
	  fi; \
	  dashes="$$banner"; \
	  skipped=""; \
	  if test "$$skip" -ne 0; then \
	    if test "$$skip" -eq 1; then \
	      skipped="($$skip test was not run)"; \
	    else \
	      skipped="($$skip tests were not run)"; \
	    fi; \
	    test `echo "$$skipped" | wc -c` -le `echo "$$banner" | wc -c` || \
	      dashes="$$skipped"; \
	  fi; \
	  report=""; \
	  if test "$$failed" -ne 0 && test -n "$(BUGSTO)"; then \
	    report="Please report to $(BUGSTO)"; \
	    test `echo "$$report" | wc -c` -le `echo "$$banner" | wc -c` || \
	      dashes="$$report"; \
	  fi; \
	  dashes=`echo "$$dashes" | sed s/./=/g`; \
	  if test "$$failed" -eq 0; then \
	    echo "$$grn$$dashes"; \
	  else \
	    echo "$$red$$dashes"; \
	  fi; \
	  echo "$$banner"; \
	  test -z "$$skipped" || echo "$$skipped"; \
	  test -z "$$report" || echo "$$report"; \
	  echo "$$dashes$$std"; \
	  test "$$failed" -eq 0; \
	else :; fi
