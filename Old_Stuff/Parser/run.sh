#!/bin/bash
# Majority of this code was obtained from the site given below:
# http://theos.in/shell-scripting/send-mail-bash-script/

cd /home/srb/Parser
cp /d/eas/logs/eas.log .
perl -i -pe 's///g' eas.log

echo >> eas.log # Adds a carriage return at the end of eas.log to fix end of file errors.
echo >> eas.log # Adds a carriage return at the end of eas.log to fix end of file errors.

perl parser.pl # -m1=01 -d1=04 -y1=08
#perl parser.pl -m1=`date +"%m"` -d1=`date +"%d"` -y1=`date +"%y"`
NOW=`date +"%H:%M:%S_%b-%d-%y"`
mkdir $NOW
cp *.tex ./$NOW
cd $NOW

###File info###
TEXFILE="results.tex"
TEMP="temp.txt"
grep -A 1 'NO CALL SIGNS' $TEXFILE > ./$TEMP 
if [ -s $TEMP ]; then  ### EAS log failed to comply
			sed -e 's/WREK EAS LOG for this Week/\\underline{ACTION REQUIRED! - WREK EAS LOG FOR THIS WEEK SHOWS}\n\\medskip\n\
			\\noindent \\underline{FAILURE TO MAINTAIN FCC REQUIREMENTS}/' -e 's/Signed,/\n\nReason for discrepancy:\n\\hrulefill\
			\n\n\\hrulefill\n\n\\hrulefill\n\\hrulefill \n\n\\medskip\n\n\n\n\n\n\n \\noindent Signed,/' $TEXFILE > results2.tex
			SUBJECT="WREK EAS LOG for given week is NOT in compliance with FCC"
			EMAILMESSAGE="ATTENTION! Main eas.log file is NOT in compliance with FCC for given date range!!!!"
			EMAIL="srb@wrek.org,chief.engineer@wrek.org,business.manager@wrek.org,traffic.director@wrek.org,operations.manager@wrek.org,general.manager@wrek.org"
			#EMAIL="srb@wrek.org"
else ### EAS log passes FCC compliance test.
			sed -e 's/WREK EAS LOG for this Week/\\underline{WREK EAS LOG for this Week - Passes Inspection}/' $TEXFILE > results2.tex
			SUBJECT="WREK EAS LOG for given week is good."
			EMAILMESSAGE="No problem. All good."
			EMAIL="srb@wrek.org,chief.engineer@wrek.org,traffic.director@wrek.org"
			#EMAIL="srb@wrek.org"
fi;

mv results2.tex results.tex

pdflatex $TEXFILE
FILE_WO_EXT=`echo "$TEXFILE" | cut -d'.' -f1`
echo $EMAILMESSAGE | mutt -s "$SUBJECT" -a "$FILE_WO_EXT.pdf" "$EMAIL";

find . ! -name "*.pdf" -type f -exec rm -f {} \; # Comment out for debugging purposes.
rm -f ./$TEMP

cd ..
find . -name "*.tex" -type f -exec rm -f {} \; # Comment out for debugging purposes.
cd ..
rm sent
cd Parser
