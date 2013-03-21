#!/bin/csh

rm -f do class assoc
touch do class assoc

set entry = `cat file | fgrep rawframe | sed "s/rawframe *//" | sed "s/ *{//" | sed "s/_/\\\\_/g"`

echo "DO category: {\\tt $entry}" > result
#echo "{\\tt $entry}" >> do

foreach item (`cat file | fgrep "=="`)
  echo $item | fgrep "==" > /dev/null
  if ( $status == 0 ) then
    set entry = `echo $item | sed "s/DPR_CATEGORY/DPR CATG/" | sed "s/DPR_TYPE/DPR TYPE/" | sed "s/DPR_TECHNIQUE/DPR TECH/" | sed "s/TP_ID/TPL ID/" | sed 's/=="/ = /' | sed 's/".*//' | sed "s/_/\\\\_/g"`
    echo "\\> {\\tt $entry}" >> class
  endif
end


foreach item (`cat file | fgrep "//"`)
  echo $item | fgrep "ESO." > /dev/null
  if ( $status == 0 ) then
     set entry = `echo $item | sed "s/ESO.//" | sed "s/;//" | sed "s/\./ /g" | sed "s/_/\\\\_/g"`
     echo "{\\tt $entry}" >> assoc
  endif
end

cat file | fgrep "//" | fgrep -v INSTRUMENT | sed "s/^.*\/\/ *//" | sed 's/$/ \\\\/' > comm

echo '\\begin{tabbing}' >> result
echo '{\\tt xxx} \\= {\\tt xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} \\= {\\tt xxxxxxxxxxxxxxxxxxx} \\= {\\tt xxxxxxxxxxxx} \\kill' >> result
echo '\\> Classification keywords \\> Association keywords \\> Note \\\\' >> result

paste --delimiters="%" class assoc comm >> result

ex - result << fine
% s/%/ \\\> /g
% s/^ / \\\> /
w
q
fine

echo '\\end{tabbing}' >> result

cat result
