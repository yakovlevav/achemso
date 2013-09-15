################################################################
################################################################
# Makefile for achemso                                         #
################################################################
################################################################

.SILENT:

################################################################
# Default with no target is to give help                       #
################################################################

help:
	@echo ""
	@echo " make clean               - clean out test directory"
	@echo " make ctan                - create a CTAN-ready archive"
	@echo " make doc                 - typeset documentation"
	@echo " make localinstall        - install files in local texmf tree"
	@echo " make tds                 - create a TDS-ready archive"
	@echo " make unpack              - extract packages"
	@echo ""
	
##############################################################
# Master package name                                        #
##############################################################

PACKAGE = achemso

##############################################################
# Directory structure for making zip files                   #
##############################################################

CTANROOT := ctan
CTANDIR  := $(CTANROOT)/$(PACKAGE)
TDSDIR   := tds

##############################################################
# Data for local installation and TDS construction           #
##############################################################

INCLUDEPDF  := $(PACKAGE)
INCLUDETEX  := $(PACKAGE)-demo
INCLUDETXT  := README
PACKAGEROOT := latex/$(PACKAGE)

##############################################################
# Details of source files                                    #
##############################################################

DTX      = $(subst ,,$(notdir $(wildcard *.dtx)))
DTXFILES = $(subst .dtx,,$(notdir $(wildcard *.dtx)))
UNPACK   = $(DTX)

##############################################################
# Clean-up information                                       #
##############################################################

AUXFILES = \
	aux  \
	bbl  \
	blg  \
	cmds \
	glo  \
	gls  \
	hd   \
	idx  \
	ilg  \
	ind  \
	log  \
	out  \
	tmp  \
	toc  \
	xref
	
CLEAN = \
	bib \
	bst \
	cfg \
	cls \
	gz  \
	ins \
	pdf \
	sty \
	tex \
	txt \
	zip 

################################################################
# PDF Settings                                                 #
################################################################

PDFSETTINGS = \AtBeginDocument{\OnlyDescription}
	
################################################################
# File building: default actions                               #
################################################################

%.pdf: %.dtx
	NAME=`basename $< .dtx` ; \
	echo "Typesetting $$NAME" ; \
	pdflatex -draftmode -interaction=batchmode "$(PDFSETTINGS) \input $<" &> /dev/null ; \
	if [ $$? = 0 ] ; then  \
	  bibtex8 --wolfgang $$NAME.aux &> /dev/null ; \
	  makeindex -q -s gglo.ist -o $$NAME.gls $$NAME.glo ; \
	  makeindex -q -s gind.ist -o $$NAME.ind $$NAME.idx ; \
	  pdflatex -interaction=batchmode "$(PDFSETTINGS) \input $<" &> /dev/null ; \
	  makeindex -q -s gglo.ist -o $$NAME.gls $$NAME.glo ; \
	  makeindex -q -s gind.ist -o $$NAME.ind $$NAME.idx ; \
	  pdflatex -interaction=batchmode "$(PDFSETTINGS) \input $<" &> /dev/null ; \
	else \
	  echo "  Compilation failed" ; \
	fi ; \
	for I in $(AUXFILES) ; do \
	  rm -f $$NAME.$$I ; \
	done

################################################################
# File building: special files                                 #
################################################################

achemso-demo.pdf:
	echo "Typesetting achemso-demo" ; \
	pdflatex -draftmode -interaction=nonstopmode achemso-demo &> /dev/null ; \
	if [ $$? = 0 ] ; then  \
	  bibtex8 --wolfgang achemso-demo.aux &> /dev/null ; \
	  pdflatex -interaction=batchmode achemso-demo &> /dev/null ; \
	  pdflatex -interaction=batchmode achemso-demo &> /dev/null ; \
	else \
	  echo "  Compilation failed" ; \
	fi ; \
	for I in $(AUXFILES) ; do \
	  rm -f achemso-demo.$$I ; \
	done
	
################################################################
# User make options                                            #
################################################################

.PHONY = \
	clean        \
	ctan         \
	doc          \
	localinstall \
	tds          \
	unpack
	
clean:
	echo "Cleaning up"
	for I in $(AUXFILES) $(CLEAN) ; do \
	  rm -f *.$$I ; \
	done
	rm -rf $(CTANROOT)/
	rm -rf $(TDSDIR)/
	
ctan: tds
	echo "Creating CTAN archive"
	mkdir -p $(CTANDIR)/
	rm -rf $(CTANDIR)/*
	cp -f *.dtx $(CTANDIR)/ ; \
	for I in $(INCLUDEPDF) ; do \
	  cp -f $$I.pdf $(CTANDIR)/ ; \
	done ; \
	for I in $(INCLUDETEX); do \
	  cp -f $$I.tex $(CTANDIR)/ ; \
	done ; \
	for I in $(INCLUDETXT); do \
	  cp -f $$I.txt $(CTANDIR)/; \
	  mv $(CTANDIR)/$$I.txt $(CTANDIR)/$$I ; \
	done ; \
	cp $(PACKAGE).tds.zip $(CTANROOT)/ 
	cd $(CTANROOT) ; \
	zip -ll -q -r -X $(PACKAGE).zip .
	cp $(CTANROOT)/$(PACKAGE).zip ./
	rm -rf $(CTANROOT)
	
doc: \
	$(foreach FILE,$(INCLUDEPDF),$(FILE).pdf) \
	$(foreach FILE,$(INCLUDETEX),$(FILE).pdf) \
	
localinstall: unpack
	echo "Installing files"
	TEXMFHOME=`kpsewhich --var-value=TEXMFHOME` ; \
	mkdir -p $$TEXMFHOME/tex/$(PACKAGEROOT)/config ; \
	rm -rf $$TEXMFHOME/tex/$(PACKAGEROOT)/*.* ; \
	cp *.cfg $$TEXMFHOME/tex/$(PACKAGEROOT)/config/ ; \
	cp *.cls $$TEXMFHOME/tex/$(PACKAGEROOT)/ ; \
	cp *.sty $$TEXMFHOME/tex/$(PACKAGEROOT)/ 
	
tds: doc
	echo "Creating TDS archive"
	mkdir -p $(TDSDIR)/
	rm -rf $(TDSDIR)/*
	mkdir -p $(TDSDIR)/bibtex/bst/$(PACKAGE)/
	mkdir -p $(TDSDIR)/doc/$(PACKAGEROOT)/
	mkdir -p $(TDSDIR)/tex/$(PACKAGEROOT)/config/
	mkdir -p $(TDSDIR)/source/$(PACKAGEROOT)/
	cp -f *.bst $(TDSDIR)/bibtex/bst/$(PACKAGE)/ ; \
	cp -f *.cfg $(TDSDIR)/tex/$(PACKAGEROOT)/config/ ; \
	cp -f *.cls $(TDSDIR)/tex/$(PACKAGEROOT)/  ; \
	cp -f *.dtx $(TDSDIR)/source/$(PACKAGEROOT)/ ; \
	cp -f *.ins $(TDSDIR)/source/$(PACKAGEROOT)/ ; \
	for I in $(INCLUDEPDF) ; do \
	  cp -f $$I.pdf $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	done ; \
	cp -f *.sty $(TDSDIR)/tex/$(PACKAGEROOT)/ ; \
	for I in $(INCLUDETEX); do \
	  cp -f $$I.bib $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	  cp -f $$I.pdf $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	  cp -f $$I.tex $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	done ; \
	for I in $(INCLUDETXT); do \
	  cp -f $$I.txt $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	  mv $(TDSDIR)/doc/$(PACKAGEROOT)/$$I.txt $(TDSDIR)/doc/$(PACKAGEROOT)/$$I ; \
	done 
	cd $(TDSDIR) ; \
	zip -ll -q -r -X $(PACKAGE).tds.zip .
	cp $(TDSDIR)/$(PACKAGE).tds.zip ./
	rm -rf $(TDSDIR)
	
unpack: 
	echo "Unpacking files"
	for I in $(UNPACK) ; do \
	  tex $$I &> /dev/null ; \
	done