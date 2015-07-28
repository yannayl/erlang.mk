# Copyright (c) 2013-2015, Loïc Hoguin <essen@ninenines.eu>
# This file is part of erlang.mk and subject to the terms of the ISC License.

.PHONY: plt distclean-plt dialyze

# Configuration.

DIALYZER_PLT ?= $(CURDIR)/.$(PROJECT).plt
export DIALYZER_PLT

PLT_APPS ?=
DIALYZER_DIRS ?= --src -r src
DIALYZER_OPTS ?= -Werror_handling -Wrace_conditions \
	-Wunmatched_returns # -Wunderspecs
ifndef DIALYZER_FILTER_FILE
ifneq ($(wildcard ./dialyzer.ignore-warnings),)
DIALYZER_FILTER_FILE = ./dialyzer.ignore-warnings
endif
endif

# Core targets.

check:: dialyze

distclean:: distclean-plt

help::
	$(verbose) printf "%s\n" "" \
		"Dialyzer targets:" \
		"  plt         Build a PLT file for this project" \
		"  dialyze     Analyze the project using Dialyzer"

# Plugin-specific targets.

ifdef DIALYZER_FILTER_FILE
DIALYZER_FILTER_CMD = | grep -v -f $(DIALYZER_FILTER_FILE)
else
DIALYZER_FILTER_CMD =
endif

$(DIALYZER_PLT): deps app
	$(verbose) dialyzer --build_plt --apps erts kernel stdlib $(PLT_APPS) $(OTP_DEPS) $(ALL_DEPS_DIRS)

plt: $(DIALYZER_PLT)

distclean-plt:
	$(gen_verbose) rm -f $(DIALYZER_PLT)

ifneq ($(wildcard $(DIALYZER_PLT)),)
dialyze:
else
dialyze: $(DIALYZER_PLT)
endif
	$(verbose) dialyzer --no_native $(DIALYZER_DIRS) $(DIALYZER_OPTS) $(DIALYZER_FILTER_CMD)
