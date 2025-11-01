
Using this Makefile:

Generally the following command generates a pdf-file from a latex file using beamer:

make pdf


To use beamer it is NOT necessary to use this Makefile.
The presentation can be compiled using pdflatex:
pdflatex [name]
However, makefiles provide convenient and consitent usability.
The targets may need the commands cat, rm, pdflatex and bibtex.

Available targets:


all     : call make pdf
clean   : removes temporary files
help    : outputs this help file
pdf     : generates pdf-file from tex-file
bib     : generates bbl-file (for use with bibtex)
show    : views the pdf file using default PDF viewer

-------------------------------------------------
(c) Justus, 30 October 2001, (m) Justus, May 2005 
(m) for Sabah, November 2005
(m) modernized March 2016
