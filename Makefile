USERMANUAL_VERSION=0.5.0
REFLEXTUTORIAL_VERSION=0.5.0

PIPEDOC_COMMON :=$(CURDIR)/pipedoc
REFLEX_TUT_DIR :=$(CURDIR)/reflex_tutorial
TEXINPUTS :=.:$(CURDIR):$(CURDIR)/figures:$(REFLEX_TUT_DIR):$(REFLEX_TUT_DIR)/figures:$(PIPEDOC_COMMON):$(PIPEDOC_COMMON)/reflex:$(PIPEDOC_COMMON)/figures:

all: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2res_reflex_tutorial.pdf pdf_check mv

cr2repdoc.pdf: *.tex cr2repdoc.bib

$(REFLEX_TUT_DIR)/cr2res_reflex_tutorial.pdf: $(REFLEX_TUT_DIR)/*.tex

clean:
	rm -f *.dvi *.aux *.toc *.out *.log *.idx *.pdf *.ps *.bbl *.blg *.brf

# Check that all clickable URIs in PDF-document are valid
pdf_check: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2res_reflex_tutorial.pdf
	perl -nle '$$done{$$1}++ or system("wget --no-check-certificate -q -O /dev/null $$1") ? die $$1 : print $$1 while s/\bURI\/URI\(([fht]+tp[^\)]+)\)//i' cr2repdoc.pdf
	perl -nle '$$done{$$1}++ or system("wget --no-check-certificate -q -O /dev/null $$1") ? die $$1 : print $$1 while s/\bURI\/URI\(([fht]+tp[^\)]+)\)//i' cr2res_reflex_tutorial.pdf

mv: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2res_reflex_tutorial.pdf
	mv cr2repdoc.pdf cr2re-pipeline-manual-$(USERMANUAL_VERSION).pdf
	mv cr2res_reflex_tutorial.pdf cr2res-reflex-tutorial-$(REFLEXTUTORIAL_VERSION).pdf


#  cr2res-pipe-recipes.html
install: cr2repdoc.pdf $(REFLEX_TUT_DIR)/cr2res_reflex_tutorial.pdf
	install -m644 cr2repdoc.pdf /ftp/pub/dfs/pipelines/cr2re/cr2re-manual-$(USERMANUAL_VERSION).pdf
	install -m644 cr2res_reflex_tutorial.pdf /ftp/pub/dfs/pipelines/cr2re/cr2res-reflex-tutorial-$(REFLEXTUTORIAL_VERSION).pdf

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
