#!/bin/sh

if [ -s "DoneByParser" ]; then
	rm -rf DoneByParser
fi;
mkdir DoneByParser

./run.sh 10 01 10
echo "./run.sh 10 01 10"
./run.sh 04 07 10
echo "./run.sh 04 07 10"
./run.sh 13 06 10
echo "./run.sh 13 06 10"
./run.sh 20 06 10
echo "./run.sh 20 06 10"
./run.sh 27 06 10
echo "./run.sh 27 06 10"
./run.sh 23 05 10
echo "./run.sh 23 05 10"
./run.sh 30 05 10
echo "./run.sh 30 05 10"
./run.sh 01 11 09
echo "./run.sh 01 11 09"
./run.sh 15 11 09
echo "./run.sh 15 11 09"
./run.sh 22 11 09
echo "./run.sh 22 11 09"
./run.sh 29 11 09
echo "./run.sh 29 11 09"
./run.sh 11 10 09
echo "./run.sh 11 10 09"
./run.sh 18 10 09
echo "./run.sh 18 10 09"
./run.sh 25 10 09
echo "./run.sh 25 10 09"
./run.sh 11 04 10
echo "./run.sh 11 04 10"
./run.sh 18 04 10
echo "./run.sh 18 04 10"
./run.sh 06 12 09
echo "./run.sh 06 12 09"
./run.sh 13 12 09
echo "./run.sh 13 12 09"
./run.sh 20 12 09
echo "./run.sh 20 12 09"
./run.sh 27 12 09
echo "./run.sh 27 12 09"
./run.sh 07 02 10
echo "./run.sh 07 02 10"
./run.sh 14 02 10
echo "./run.sh 14 02 10"
./run.sh 28 02 10
echo "./run.sh 28 02 10"
./run.sh 03 01 10
echo "./run.sh 03 01 10"
./run.sh 17 01 10
echo "./run.sh 17 01 10"
./run.sh 24 01 10
echo "./run.sh 24 01 10"
./run.sh 31 01 10
echo "./run.sh 31 01 10"
./run.sh 18 07 10
echo "./run.sh 18 07 10"
./run.sh 25 07 10
echo "./run.sh 25 07 10"
./run.sh 06 06 10
echo "./run.sh 06 06 10"
./run.sh 14 03 10
echo "./run.sh 14 03 10"
./run.sh 28 03 10
echo "./run.sh 28 03 10"
./run.sh 09 05 10
echo "./run.sh 09 05 10"
./run.sh 16 05 10
echo "./run.sh 16 05 10"
./run.sh 08 11 09
echo "./run.sh 08 11 09"
./run.sh 04 04 10
echo "./run.sh 04 04 10"
./run.sh 25 04 10
echo "./run.sh 25 04 10"
./run.sh 21 02 10
echo "./run.sh 21 02 10"
./run.sh 11 07 10
echo "./run.sh 11 07 10"
./run.sh 02 05 10
echo "./run.sh 02 05 10"
./run.sh 21 03 10
echo "./run.sh 21 03 10"
./run.sh 07 03 10
echo "./run.sh 07 03 10"

mv _* DoneByParser
