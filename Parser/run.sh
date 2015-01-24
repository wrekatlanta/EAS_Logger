#!/bin/bash
# Majority of this code was obtained from:
# http://theos.in/shell-scripting/send-mail-bash-script/

cd /home/srb/Parser
cp /d/eas/logs/eas.log .
perl -i -pe 's///g' eas.log

echo >> eas.log # Adds a carriage return at the end of eas.log to fix end of file errors.
echo >> eas.log # Adds a carriage return at the end of eas.log to fix end of file errors.
ARG_NUM=$#
if [ "$ARG_NUM" -gt "0" ]; then
	python parser.py -d $1 -m $2 -y $3 -t
	#echo "./run.sh $1 $2 $3" >> list.sh
else
	python parser.py -d `date -d "yesterday" +\%d` -m `date -d "yesterday" +\%m` -y `date -d "yesterday" +\%y` -t
	#echo "./run.sh `date +"%m %d %y"`" >> list.sh
fi;
TEX_FILE=`ls *.tex`
NOW=`echo "$TEX_FILE" | cut -d'.' -f1`
mkdir $NOW
if [ -s trace ]; then
	mv trace $NOW
fi;
mv *.tex ./$NOW
cd $NOW

###File info###
TEMP="temp.txt"
grep -A 1 'WARNING' $TEX_FILE > ./$TEMP 
if [ -s $TEMP ]; then  ### EAS log failed to comply
			sed -e 's/\\noindent \\underline{WREK EAS LOG for this Week}/\
			\\noindent \\underline{ACTION REQUIRED! - WREK EAS LOG FOR THIS WEEK SHOWS}\n\n\\medskip\n\n\
			\\noindent \\underline{FAILURE TO MAINTAIN FCC REQUIREMENTS}/' -e 's/Signed,/\n\nReason for discrepancy:\n\\hrulefill\
			\n\n\\hrulefill\n\n\\hrulefill\n\\hrulefill \n\n\\medskip\n\n\n\n\n\n\n \\noindent Signed,/' $TEX_FILE > results2.tex
			SUBJECT="WREK EAS LOG for given week is NOT in compliance with FCC"
			EMAILMESSAGE="ATTENTION! Main eas.log file is NOT in compliance with FCC for given date range!!!!"
			EMAIL="chief.engineer@wrek.org,it.director@wrek.org,general.manager@wrek.org"
else ### EAS log passes FCC compliance test.
			sed -e 's/WREK EAS LOG for this Week/\\underline{WREK EAS LOG for this Week - Passes Inspection}/' $TEX_FILE > results2.tex
			SUBJECT="WREK EAS LOG for given week is good."
			EMAILMESSAGE="No problem. All good."
		        EMAIL="chief.engineer@wrek.org"		       
fi
mv results2.tex $TEX_FILE

pdflatex $TEX_FILE >> /dev/null
FILE_WO_EXT=`echo "$TEX_FILE" | cut -d'.' -f1`
echo $EMAILMESSAGE | mutt -s "$SUBJECT" -a "$FILE_WO_EXT.pdf" "$EMAIL";

find . -name "*.aux" -exec rm -f {} \;
find . -name "*.log" -exec rm -f {} \;
rm -f ./$TEMP

cd ../..
rm sent
cd /home/srb/Parser
