#!/bin/bash
# Majority of this code was obtained from:
# http://theos.in/shell-scripting/send-mail-bash-script/

cd /home/srb/Python_Port_Parser
cp /d/eas/logs/eas.log .
perl -i -pe 's///g' eas.log

echo >> eas.log # Adds a carriage return at the end of eas.log to fix end of file errors.
echo >> eas.log # Adds a carriage return at the end of eas.log to fix end of file errors.
ARG_NUM=$#
if [ "$ARG_NUM" -gt "0" ]; then
	NOW="_$2-$1-$3"
	python parser.py -d $1 -m $2 -y $3 -t
else
	NOW=`date +"%H:%M:%S_%b-%d-%y"`
	python parser.py -d `date -d "yesterday" +\%d` -m `date +\%m` -y `date +\%y` -t
fi;
mkdir $NOW
if [ -s trace ]; then
	mv trace $NOW
fi;
mv *.tex ./$NOW
cd $NOW

###File info###
TEXFILE="output.tex"
TEMP="temp.txt"
grep -A 1 'WARNING' $TEXFILE > ./$TEMP 
<<MAILSTUFF
if [ -s $TEMP ]; then  ### EAS log failed to comply
			sed -e 's/\\noindent \\underline{WREK EAS LOG for this Week}/\
			\\noindent \\underline{ACTION REQUIRED! - WREK EAS LOG FOR THIS WEEK SHOWS}\n\n\\medskip\n\n\
			\\noindent \\underline{FAILURE TO MAINTAIN FCC REQUIREMENTS}/' -e 's/Signed,/\n\nReason for discrepancy:\n\\hrulefill\
			\n\n\\hrulefill\n\n\\hrulefill\n\\hrulefill \n\n\\medskip\n\n\n\n\n\n\n \\noindent Signed,/' $TEXFILE > results2.tex
			SUBJECT="Python Port Test found a problem! Not good!!!"
			#SUBJECT="WREK EAS LOG for given week is NOT in compliance with FCC"
			EMAILMESSAGE="ATTENTION! Main eas.log file is NOT in compliance with FCC for given date range!!!!"
			EMAIL="srb@wrek.org"
			#,chief.engineer@wrek.org,business.manager@wrek.org,traffic.director@wrek.org,operations.manager@wrek.org,general.manager@wrek.org"
else ### EAS log passes FCC compliance test.
			sed -e 's/WREK EAS LOG for this Week/\\underline{WREK EAS LOG for this Week - Passes Inspection}/' $TEXFILE > results2.tex
			SUBJECT="Python Port Test works fine so far!!"
			#SUBJECT="WREK EAS LOG for given week is good."
			EMAILMESSAGE="No problem. All good."
			EMAIL="srb@wrek.org"
			#,chief.engineer@wrek.org,traffic.director@wrek.org"
fi;
cp results2.tex $TEXFILE
MAILSTUFF

pdflatex $TEXFILE
FILE_WO_EXT=`echo "$TEXFILE" | cut -d'.' -f1`
#echo $EMAILMESSAGE | mutt -s "$SUBJECT" -a "$FILE_WO_EXT.pdf" "$EMAIL";

rm -f output.aux
rm -f output.log
rm -f ./$TEMP

#cd ../..
#cd ..
#rm sent
#cd Python_Port_Parser
