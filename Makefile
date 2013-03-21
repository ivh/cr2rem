VERSION=0.1
TUT_VERSION=0.1

PIPEDOC_COMMON :=$(CURDIR)/pipedoc_common
REFLEX_TUT_DIR :=$(CURDIR)/reflex_tutorial
TEXINPUTS :=.:$(CURDIR):$(CURDIR)/figures:$(REFLEX_TUT_DIR):$(PIPEDOC_COMMON):$(PIPEDOC_COMMON)/reflex:$(PIPEDOC_COMMON)/figures:

all: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2re_reflex_tutorial.pdf pdf_check mv

cr2repdoc.pdf: *.tex cr2repdoc.bib

$(REFLEX_TUT_DIR)/cr2re_reflex_tutorial.pdf: $(REFLEX_TUT_DIR)/*.tex

clean:
	rm -f *.dvi *.aux *.toc *.out *.log *.idx *.pdf *.ps *.bbl *.blg *.brf

# Check that all clickable URIs in PDF-document are valid
pdf_check: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2re_reflex_tutorial.pdf
	perl -nle '$$done{$$1}++ or system("wget --no-check-certificate -q -O /dev/null $$1") ? die $$1 : print $$1 while s/\bURI\/URI\(([fht]+tp[^\)]+)\)//i' cr2repdoc.pdf
	perl -nle '$$done{$$1}++ or system("wget --no-check-certificate -q -O /dev/null $$1") ? die $$1 : print $$1 while s/\bURI\/URI\(([fht]+tp[^\)]+)\)//i' cr2re_reflex_tutorial.pdf

mv: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2re_reflex_tutorial.pdf
	mv cr2repdoc.pdf cr2re-pipeline-manual-$(VERSION).pdf
	mv cr2re_reflex_tutorial.pdf cr2re-reflex-tutorial-$(TUT_VERSION).pdf


#  cr2re-pipe-recipes.html
install: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2re_reflex_tutorial.pdf
	install -m644 cr2repdoc.pdf /ftp/pub/dfs/pipelines/cr2re/cr2re-manual-$(VERSION).pdf
	install -m644 cr2re_reflex_tutorial.pdf /ftp/pub/dfs/pipelines/cr2re/cr2re-reflex-tutorial-$(TUT_VERSION).pdf

# Create .pdf from .tex
%.pdf: %.tex
	TEXINPUTS=$(TEXINPUTS); export TEXINPUTS; pdflatex $*
	-bibtex  `basename $*` 
	if [ -s `basename  $*.bbl` ] ; then bibtex `basename $*` ; fi;
	TEXINPUTS=$(TEXINPUTS); export TEXINPUTS; pdflatex $*
	TEXINPUTS=$(TEXINPUTS); export TEXINPUTS; pdflatex $*
	-grep 'Label.s. may have changed' `basename $*.log` && echo s| TEXINPUTS=$(TEXINPUTS) pdflatex $*
	-grep 'Label.s. may have changed' `basename $*.log` && echo s| TEXINPUTS=$(TEXINPUTS) pdflatex $*
	-perl -e 'system("grep -w Warning `basename $*.log`") || die "Warnings are not allowed\n"'
