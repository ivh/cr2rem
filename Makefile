USERMANUAL_VERSION=0.8
REFLEXTUTORIAL_VERSION=0.3

PIPEDOC_COMMON :=$(CURDIR)/pipedoc
REFLEX_TUT_DIR :=$(CURDIR)/reflex_tutorial
TEXINPUTS :=.:$(CURDIR):$(CURDIR)/figures:$(REFLEX_TUT_DIR):$(REFLEX_TUT_DIR)/figures:$(PIPEDOC_COMMON):$(PIPEDOC_COMMON)/reflex:$(PIPEDOC_COMMON)/figures:

all: iiinstrumentpdoc.pdf $(REFLEX_TUT_DIR)/iiinstrument_reflex_tutorial.pdf pdf_check mv

iiinstrumentpdoc.pdf: *.tex iiinstrumentpdoc.bib

$(REFLEX_TUT_DIR)/iiinstrument_reflex_tutorial.pdf: $(REFLEX_TUT_DIR)/*.tex

clean:
	rm -f *.dvi *.aux *.toc *.out *.log *.idx *.pdf *.ps *.bbl *.blg *.brf

# Check that all clickable URIs in PDF-document are valid
pdf_check: iiinstrumentpdoc.pdf $(REFLEX_TUT_DIR)/iiinstrument_reflex_tutorial.pdf
	perl -nle '$$done{$$1}++ or system("wget --no-check-certificate -q -O /dev/null $$1") ? die $$1 : print $$1 while s/\bURI\/URI\(([fht]+tp[^\)]+)\)//i' iiinstrumentpdoc.pdf
	perl -nle '$$done{$$1}++ or system("wget --no-check-certificate -q -O /dev/null $$1") ? die $$1 : print $$1 while s/\bURI\/URI\(([fht]+tp[^\)]+)\)//i' iiinstrument_reflex_tutorial.pdf

mv: iiinstrumentpdoc.pdf $(REFLEX_TUT_DIR)/iiinstrument_reflex_tutorial.pdf
	mv iiinstrumentpdoc.pdf iiinstrument-pipeline-manual-$(USERMANUAL_VERSION).pdf
	mv iiinstrument_reflex_tutorial.pdf iiinstrument-reflex-tutorial-$(REFLEXTUTORIAL_VERSION).pdf


#  iiinstrument-pipe-recipes.html
install: iiinstrumentpdoc.pdf $(REFLEX_TUT_DIR)/iiinstrument_reflex_tutorial.pdf
	install -m644 iiinstrumentpdoc.pdf /ftp/pub/dfs/pipelines/iiinstrument/iiinstrument-manual-$(USERMANUAL_VERSION).pdf
	install -m644 iiinstrument_reflex_tutorial.pdf /ftp/pub/dfs/pipelines/iiinstrument/iiinstrument-reflex-tutorial-$(REFLEXTUTORIAL_VERSION).pdf

# Create .pdf from .tex
%.pdf: %.tex
	TEXINPUTS=$(TEXINPUTS); export TEXINPUTS; pdflatex -halt-on-error $*
	-bibtex  `basename $*` 
	if [ -s `basename  $*.bbl` ] ; then bibtex `basename $*` ; fi;
	TEXINPUTS=$(TEXINPUTS); export TEXINPUTS; pdflatex -halt-on-error $*
	TEXINPUTS=$(TEXINPUTS); export TEXINPUTS; pdflatex -halt-on-error $*
	grep 'Label.s. may have changed' `basename $*.log` && echo s| TEXINPUTS=$(TEXINPUTS) pdflatex -halt-on-error $* || echo No labels changed
	grep 'Label.s. may have changed' `basename $*.log` && echo s| TEXINPUTS=$(TEXINPUTS) pdflatex -halt-on-error $* || echo No labels changed
	grep 'Package rerunfilecheck Warning' `basename $*.log` && echo s| TEXINPUTS=$(TEXINPUTS) pdflatex -halt-on-error $* || echo No rerunfilecheck needed
	perl -e 'system("grep -w Warning `basename $*.log`") || die "Warnings are not allowed\n"'
