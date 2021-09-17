#!/bin/sh

FNAME=cr2res_manpages.tex

echo "\section{Recipe man-pages}\label{sec:manpages}" > $FNAME

cat <<EOT >> $FNAME
The following is auto-generated pages with the manual-pages
of each recipe. These can be viewed any time on the command-line
with
\begin{verbatim}
    esorex --man-page <recipe>
\end{verbatim}
where \texttt{<recipe>} stands for the recipe name.

\emph{Until the chapter with detailed recipe descriptions is written, this has been moved forward from the appendix to serve as a reference for inputs, outputs and parameters.
}

EOT

echo foo
esorex --recipes | grep cr2re | cut -b3-23 | while read rec; do
    resc=$(echo $rec | sed s/_/\\\\_/g)
    printf "\subsection{${resc}}\n" >> $FNAME
    printf "%sbegin{verbatim}\n" "\\" >> $FNAME
    esorex --man-page $rec | tail -n+4 | head -n-31  >> $FNAME
    printf "%send{verbatim}\n" "\\" >> $FNAME

done