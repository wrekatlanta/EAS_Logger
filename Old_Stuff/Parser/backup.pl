#!/usr/bin/perl -w

use strict;
require "lib.pl";
use Date::Calc qw(:all);
use Getopt::Long;

sub whichMonth($);
sub checkOutOfMonth($$$);
sub FCCWeeklySent($$$$$$$);
sub NotWithinDateRange($$$$$$);
sub genDateRange($$$); 

my $infile = "eas.log";
my $outfile = ">output.tex";

my $line; # Grabs each line of text from file.
my $EAStype; # Stores type of EAS alert.
my $EASwhere; # Stores where EAS alert originated.
my ($day,$month,$year,$time); # Stores the time and date of each EAS alert.
my ($week,$SunDay,$SunMonth,$SunYear,$SatDay,$SatMonth,$SatYear); # Calculates date range.
my ($oldSatMonth,$oldSatYear,$oldSatDay) = (00,00,00); # Calculates date range.
my ($nextSunYear,$nextSunMonth,$nextSunDay,$nextSatYear,$nextSatMonth,$nextSatDay);
my $monitor; #Used to display monitor number.
my $text; #Used to display the text associated with the ZCZC EAS signal (Tornado warnings, RWTs, severe thunderstorms etc.
my @times;
my ($monDay,$monMonth,$monYear);
my (@EOMdate,@EOMtime);
my $fail = 1;
my ($M1_Received,$M2_Received,$WREK_Sent) = (0,0,0);

#--------------------------------------------------------------------------------------------------------------------------#

my $ZCZClinemaker; # Is used to concatenate ZCZC lines that are more than one line in length.
my $Rec_Snd = "JustInitializing"; # Something random (because of compiler error) to display 'Rcv' or 'Snd'.
my $warnings_No = 0;
my (@default_Sunday)=(0,0,0);
my ($m1,$d1,$y1,$m2,$d2,$y2)=(0,0,0,0,0,0);
my $args = GetOptions ("m1=s" => \$m1,"d1=s" => \$d1,"y1=s" => \$y1);
#"m2=s" => \$m2,"d2=s" => \$d2,"y2=s" => \$y2);

open(INHANDLE,$infile) or die("Input file could not be opened"); 
open(OUTHANDLE,$outfile) or die("Output file could not be created/opened");

printf OUTHANDLE ("\\documentclass{article}\n\n\\usepackage{ulem}\n\n\\begin{document}\n\n");

while ($line=<INHANDLE>)
{
	chomp($line);
	## Date calculation/manipulation
	if ( ($line =~ m/Alert Received/ || $line =~ m/Alert sent/ || $line =~ m/Local Alert/) && $line =~ m/(\d{2})\/(\d{2})\/(\d{2})/)
	{
		$month = $1; $day = $2; $year = $3;
		# $1 stores result of regex.
		# Extracts day, month, year from the regex date.
		if ($line =~ m/Received/)
		{
			$Rec_Snd = "Received";
			$line =~ m/#(\d)/;
			$monitor = $1;
		}
		else
		{
			#$total_sent++;
			$Rec_Snd = "Sent";
		}
		if ($line =~ m/(\d{2}:\d{2}:\d{2})/)
		{
			$time =$1;
		}
		if (NotWithinDateRange($day,$month,$year,$oldSatDay,$oldSatMonth,$oldSatYear)==1)
		{
			($SunYear,$SunMonth,$SunDay,$SatYear,$SatMonth,$SatDay)=genDateRange($day,$month,$year);
			if ($oldSatMonth > 0)
			{
				($nextSunYear,$nextSunMonth,$nextSunDay,$nextSatYear,$nextSatMonth,
				 $nextSatDay)=genDateRange($oldSatDay,$oldSatMonth,$oldSatYear);
			}
			# Check documentation for Date::Calc CPAN module.

			$warnings_No = FCCWeeklySent($oldSatDay,$oldSatMonth,$oldSatYear,$SunDay,$SunMonth,$SunYear,$warnings_No);
			printf OUTHANDLE ("\\noindent \\underline{WEEK RANGE: %s/%s/%s - %s/%s/%s (Sunday to Saturday)}\n\n\\medskip\n\n",
					  prependZero($SunMonth),prependZero($SunDay),prependZero($SunYear),prependZero($SatMonth),prependZero($SatDay),prependZero($SatYear));

			if($M1_Received == 0)
			{
				printf OUTHANDLE ("\n\n\\noindent {\\large{\\uuline{NO CALL SIGNS RECEIVED ON MONITOR 1 !!!}}} \n\n\\medskip\n\n");
			}
			if($M2_Received == 0)
			{
				printf OUTHANDLE ("\n\n\\noindent {\\large{\\uuline{NO CALL SIGNS RECEIVED ON MONITOR 2 !!!}}} \n\n\\medskip\n\n");
			}
			if($WREK_Sent == 0)
			{
				printf OUTHANDLE ("\n\n\\noindent {\\large{\\uuline{NO CALL SIGNS SENT!!!}}} \n\n\\medskip\n\n");
			}
			$M1_Received = 0;
			$M2_Received = 0;
			$WREK_Sent = 0;

			@default_Sunday = ($SunMonth,$SunDay,$SunYear);
			$oldSatMonth =$SatMonth;$oldSatYear =$SatYear;$oldSatDay = $SatDay;
		}
		$line = <INHANDLE>;
		chomp($line);



#---------------------------------------MIGHT NOT BE NECESSARY--------------------------------------------------#

		if ($line =~ m/Matched Filter/ || $line =~ m/Already heard/)
		{
			$line = <INHANDLE>;
			chomp($line); #Added out of habit...
		}

#---------------------------------------------------------------------------------------------------------------#

		$text = $line;
		until($line =~ m/^ZCZC/)
		{
			$line = <INHANDLE>;
			chomp($line); #Added out of habit...
			if(!($line =~ m/^ZCZC/))
			{
				$text = $text.$line;
			}
		}
		#@times = $text =~ m/(\d{1,2}:\d{2} [a|p]m)/g;
	

#		if($line =~ m/^ZCZC-EAS-RWT/)
#		{
#
#
##---------------------------------------CHANGE BROADCAST STATION MESSAGE, IF NEEDED-----------------------------#
#
#			printf OUTHANDLE ("A broadcast station or cable system has issued a required weekly test\n");
#
##---------------------------------------------------------------------------------------------------------------#
#
#
#		}
#		else
#		{
#			printf OUTHANDLE ("%s\n",$text);
#		}

		## Line concatenation, printing out ZCZC info
		if($line =~ m/^ZCZC/) #Searches for ZCZC at beginning of every line
		{
			$EAStype = substr($line,9,3); #Location of EAS type in ZCZC line.
			$ZCZClinemaker = $line;
			if(!($line =~ m/-$/))
			{
				$line = <INHANDLE>;
				chomp($line);
				until($line =~ m/-$/)
				{
					$ZCZClinemaker  = $ZCZClinemaker.$line;
					$line = <INHANDLE>;
					chomp($line);
				} 
				$ZCZClinemaker = $ZCZClinemaker.$line;
			}
		}
		if ($ZCZClinemaker =~ m/([A-Z ]{8}-$)/)
		{
			if($monitor == 1 && $Rec_Snd eq "Received")
			{
				$M1_Received = 1;
			}
			elsif($monitor == 2 && $Rec_Snd eq "Received")
			{
				$M2_Received = 1;
			}
			if($Rec_Snd eq "Sent")
			{
				$WREK_Sent = 1;
			}
			$EASwhere = $1;

#------------------------ FOR DEBUGGING PURPOSESF --------------------------------------------------------------#

			#printf OUTHANDLE ("%s\n",$ZCZClinemaker);

#---------------------------------------------------------------------------------------------------------------#

			if ($Rec_Snd eq "Received")
			{
				if($line =~ m/^EOM/)
				{
					@EOMdate = $line =~ m/(\d{2}\/\d{2}\/\d{2})/;
					@EOMtime = $line =~ m/(\d{2}:\d{2}:\d{2})/;
					$line =~ m/#(\d)/; #NEWLY ADDED
					$monitor = $1; #NEWLY ADDED
					printf OUTHANDLE ("\\hspace{20 pt}     %s %s from %s at %s/%s/%s %s (EOM Received at %s %s on monitor \\#%s) \\\\",$Rec_Snd,$EAStype,
							   $EASwhere,$month,$day,$year,$time,@EOMdate,@EOMtime,$monitor);
				}
				else
				{
					printf OUTHANDLE ("\\hspace{20 pt}     %s %s from %s at %s/%s/%s %s on monitor \\#%s \\\\",$Rec_Snd,$EAStype,
							   $EASwhere,$month,$day,$year,$time,$monitor);
				}
				if($EAStype eq "RWT") #$line =~ m/^ZCZC-EAS-RWT/)
				{


		#---------------------------------------CHANGE BROADCAST STATION MESSAGE, IF NEEDED-----------------------------#

					printf OUTHANDLE ("\\hspace{20pt}     A broadcast station or cable system has issued a required weekly test \n\n\\medskip\n\n");

		#---------------------------------------------------------------------------------------------------------------#


				}
				else
				{
					printf OUTHANDLE ("     %s \n\n\\medskip\n\n",$text);
				}

			}
			else
			{
				printf OUTHANDLE ("\\hspace{20pt}     %s %s from %s at %s/%s/%s %s on monitor \\# %s \\\\",
						   $Rec_Snd,$EAStype,$EASwhere,$month,$day,$year,$time,$monitor);
				if($EAStype eq "RWT")
				{
		#---------------------------------------CHANGE BROADCAST STATION MESSAGE, IF NEEDED-----------------------------#

					printf OUTHANDLE ("\\hspace{20pt}     A broadcast station or cable system has issued a required weekly test \n\n\\medskip\n\n");

		#---------------------------------------------------------------------------------------------------------------#
				}
				else
				{
					printf OUTHANDLE ("     %s \n\n\\medskip\n\n",$text);
				}
			}
		}
	}

	### MAKE CHANGES, IF NECESSARY ###
	elsif ($line =~ /^EAS Machine Offline/)
	{
		my ($hour_diff,$minute_diff,$second_diff);
		@times = $line =~ m/\d{2}:\d{2}:\d{2}/g;
		$hour_diff = abs(substr($times[0],0,2) - substr($times[1],0,2));
		$minute_diff = abs(substr($times[0],3,2) - substr($times[1],3,2));
		$second_diff = abs(substr($times[0],6,2) - substr($times[1],6,2));
		printf OUTHANDLE ("{\\large{\\uuline{EAS WAS OFFLINE  for %d hours, %d minutes and %d seconds (FROM %s to %s)}}} \n\n\\medskip\n\n",
				  $hour_diff,$minute_diff,$second_diff,$times[0],$times[1]);
	}
}

printf OUTHANDLE ("\\noindent \\underline{END: }\n\n\\medskip\n\n");
($monDay,$monMonth,$monYear) = checkOutOfMonth($SatDay+1,$SatMonth,$SatYear);
printf OUTHANDLE ("\n\\noindent {\\large{Signed,}}\n \\underline{\\hspace{100 pt}}, %d/%d/%d \n\n\\medskip\n\n{\\large{Chief Engineer, Alternate, or Authorized Representative for Signing Logs \\newline (circle one)}}",
		   $monMonth,$monDay,$monYear);

#----------------------------------------------------------------------------------------------------------------#


printf OUTHANDLE ("\\end{document}");
close(INHANDLE);
close(OUTHANDLE);

my $tempString = $default_Sunday[0]."/".$default_Sunday[1]."/".$default_Sunday[2];
open(HANDLE, substr($outfile,1)) or die "Input file could not be opened";

my $resultsfile = ">results.tex";
open(FINALHANDLE,$resultsfile);

printf FINALHANDLE ("\\documentclass{article}\n\n\\usepackage{ulem}\n\n\\begin{document}\n\n");
$line = <HANDLE>;
chomp($line);
printf FINALHANDLE ("\\noindent WREK EAS LOG for this Week \n\n\\medskip\n\n");

if($m1 !=0 && $d1 != 0 && $y1 !=0) #&& $m2 == 0 && $d2 == 0 && $y2 == 0)
{
	my $spec_doy = Day_of_Year(int($y1),int($m1),int($d1));
	my @specific = (int($m1),int($d1),int($y1));
	until($line =~ m/END/)
	{
		if($line =~ m/WEEK RANGE/)
		{
			$line =~ m/(\d{2})\/(\d{2})\/(\d{2}) - (\d{2})\/(\d{2})\/(\d{2})/g; 
			print $specific[0],"/",$specific[1],"/",$specific[2]," ---- ",$1,"/",$2,"/",$3," - ",$4,"/",$5,"/",$6,"\n";
			my $doy_gen1 = Day_of_Year(int($3),int($1),int($2));
			my $doy_gen2 = Day_of_Year(int($6),int($4),int($5));
			if( ($spec_doy >= $doy_gen1 && $spec_doy <= $doy_gen2 && $specific[2] == int($3) && $specific[2] == int($6) ) ||
			    ($spec_doy <=$doy_gen2 && int($3) == $specific[2]-1 && int($6) == $specific[2]) || ($spec_doy >= $doy_gen1 &&
			     int($3) == $specific[2] && int($6) == $specific[2]+1) )
			{
				#print "YES","\n";
				($monMonth,$monDay,$monYear)=($4,$5,$6);
				printf FINALHANDLE ("%s\n",$line);
				$line=<HANDLE>;
				chomp($line);
				until($line =~ m/WEEK RANGE/ || $line =~ m/END/)
				{
					printf FINALHANDLE ("%s\n",$line);
					#printf FINALHANDLE ("\n\n\\cfoot{\\thepage\\ of \\pageref{LastPage}}\n\n");
					$line = <HANDLE>;
					chomp($line);
				}
				if(!($line =~ m/END/))
				{
					$line = <HANDLE>;
					chomp($line);
				}
			}
			else
			{
				$line = <HANDLE>;
			}
		}
		if(!($line =~ m/WEEK RANGE/ || $line =~ m/END/))
		{
			$line = <HANDLE>;
		}
	}
	($monDay,$monMonth,$monYear)=checkOutOfMonth($monDay+1,$monMonth,$monYear);
}
#elsif($m1 !=0 && $d1 != 0 && $y1 !=0 && $m2 != 0 && $d2 != 0 && $y2 != 0)
#{
#	my ($SunYear1,$SunMonth1,$SunDay1,$SatYear1,$SatMonth1,$SatDay1) = genDateRange($d1,$m1,$y1);
#	my ($SunYear2,$SunMonth2,$SunDay2,$SatYear2,$SatMonth2,$SatDay2) = genDateRange($d2,$m2,$y2);
#
#	($SunDay2,$SunMonth2,$SunYear2)=checkOutOfMonth($SunDay2+7,$SunMonth2,$SunYear2);
#	($SatDay2,$SatMonth2,$SatYear2)=checkOutOfMonth($SatDay2+7,$SatMonth2,$SatYear2);
#
#	my $tmp1 = prependZero($SunMonth1)."/".prependZero($SunDay1)."/".prependZero($SunYear1)." - ".prependZero($SatMonth1)."/".prependZero($SatDay1)."/".prependZero($SatYear1);
#	my $tmp2 = prependZero($SunMonth2)."/".prependZero($SunDay2)."/".prependZero($SunYear2)." - ".prependZero($SatMonth2)."/".prependZero($SatDay2)."/".prependZero($SatYear2);
#
#	($monDay,$monMonth,$monYear) = checkOutOfMonth($SatDay2-6,$SatMonth2,$SatYear2);
#
#	my @extracted_date=(0,0,0);
#	my $dynamic_year=$y1;
#
#	$fail = 0; 
#	while($line = <HANDLE>)
#	{
#		chomp($line);
#		if($line =~ m/($tmp1)/)
#		{
#			$fail = 1;
#			until($line =~ m/($tmp2)/ || $line =~ m/END/)
#			{
#				printf FINALHANDLE ("%s\n",$line);
#				$line = <HANDLE>;
#				chomp($line);
#			}
#		}
#	}
#	if($fail == 0)
#	{
#		print "The first date MUST exist in the output file\n";
#	}
#}
elsif($m1 ==0 && $d1 == 0 && $y1 ==0 && $m2 == 0 && $d2 == 0 && $y2 == 0)
{
	my $tmp = prependZero($default_Sunday[0])."/".prependZero($default_Sunday[1])."/".prependZero($default_Sunday[2]);
	while($line=<HANDLE>)
	{
		chomp($line);
		if($line =~ m/($tmp)/)
		{
			until($line =~ m/END/)
			{
				printf FINALHANDLE ("%s\n",$line);
				#printf FINALHANDLE ("\\cfoot{\\thepage\\ of \\pageref{LastPage}}");
				$line = <HANDLE>;
				chomp($line);
			}
		}
	}

}
else
{
	print "The arguments you entered are not supported by this program.\n\n";
	$fail = 0;
}
if($fail == 1)
{
	printf FINALHANDLE ("\n\\noindent {\\large{Signed,}}\n \\underline{\\hspace{100 pt}}, %s/%s/%s \n\n\\medskip\n\n{\\large{Chief Engineer, Alternate, or Authorized Representative for Signing Logs \\newline (circle one)}}\n",
			   prependZero($monMonth),prependZero($monDay),prependZero($monYear));
}
printf FINALHANDLE ("\\end{document}");
close(FINALHANDLE);
