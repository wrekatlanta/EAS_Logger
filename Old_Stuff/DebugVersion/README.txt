Tested with Perl 5.10.0 built for i486-linux-gnu-thread-multi.

Requirements:
Requires Perl 5.10.0 or higher, the Date::Calc and Getopt::Long CPAN perl module.
Also requires mutt and pdflatex for bash script.

Instructions:
Just run the run.sh file

Documentation:
The perl script first parses the ENTIRE eas log file (ignoring the perl arguments) and produces an output file called output.tex
It then parses output.tex according to the perl arguments and produces results.tex (I could have changed this to parse according to
the perl arguments, but I was too lazy)

Now what my script does is, each time it is run, it creates a directory which is named in this format:
hour:minute:second_Month-Date-Year

I named it like that so nothing would be overwritten (unless you run it in a script multiple times or something... )
It then copies all the tex files into that directory and goes into that directory. (It also makes a few small changes to the results.tex file)
The resulting file called results.pdf is then emailed to the people specified in the shell script.
After all of this it does a pretty good job cleaning up stuff. The only file left in the directory is final.pdf

NOTE: bash script does a couple of things that the perl script does not.
