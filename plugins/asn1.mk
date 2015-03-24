# Copyright (c) 2013-2015, Loïc Hoguin <essen@ninenines.eu>
# Copyright (c) 2015, Viktor Söderqvist <viktor@zuiderkwast.se>
# Copyright (c) 2015, yannayl
# This file is part of erlang.mk and subject to the terms of the ISC License.

##TODO: add support to asn1/%.set.asn asn1/%.asn

.PHONY: asn1 distclean-asn1

# Configuration.

ASN1_OPTS ?= noobj
# This variable must be defined (otherwise, error is generated in the implicit rule).
ASN1_ENCODING ?= 

# Core targets

## closest thing there is to prebuild target. still not working well with -j
## TODO: make asn1 prerequisite of real prebuild (requires re-factoring the core to overcome the malice of double colon)
erlc-include: asn1

distclean:: distclean-asn1

help::
	@printf "%s\n" "" \
		"ASN1 targets:" \
		"  asn1         Generate asn1 source files from .asn1 files."

# Plugin specific

asn1_verbose_0 = @echo " ASN1  " $(filter-out $(patsubst %,%.asn1,$(ASN1_EXCLUDE)),\
    $(filter %.asn1,$(?F)));
asn1_verbose = $(asn1_verbose_$(V))

ifeq (0,$(V))
ASN1_VERBOSE_FLAG = 
else
ASN1_VERBOSE_FLAG = -v
endif

src/%.erl include/%.hrl: asn1/%.asn1
ifndef ASN1_ENCODING
	$(error "ASN1_ENCODING is undefined")
endif
	$(asn1_verbose) erlc $(ASN1_VERBOSE_FLAG) -b$(ASN1_ENCODING) $(foreach opt,$(ASN1_OPTS),+$(opt)) -o src/ $< ;\
	asn1_hrl=$(@D)/$(basename $(@F)).hrl; if [ -f $$asn1_hrl ]; then mv $$asn1_hrl include; fi


asn1_base_files = $(foreach asn1_file,$(wildcard $(CURDIR)/asn1/*.asn1),\
	$(notdir $(basename $(asn1_file))))

asn1: $(foreach asn1_file,$(asn1_base_files),src/$(asn1_file).erl)

distclean-asn1:
	$(gen_verbose) rm -f $(foreach fname,$(asn1_base_files),src/$(fname).erl src/$(fname).asn1db include/$(fname).hrl)
