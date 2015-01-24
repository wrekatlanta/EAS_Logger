## Subroutine Definitions ##

# Function returns 0 if not within date range.
sub WithinDateRange($$$$$$$$$){

	my ($month,$day,$year,$SunMonth,$SunDay,$SunYear,$SatMonth,$SatDay,$SatYear)=($1,$2,$3,$4,$5,$6,$7,$8,$9);
	if( ($year > $SatYear || $year < $SunYear) || ($month > $SatMonth || $month < $SunMonth) )
	{
		return 0;
	}
	elsif($SatMonth == $SunMonth)
	{
		if($day < $SunDay || $day > $SatDay)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	elsif($month == $SatMonth)
	{
		if($day > $SatDay)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	elsif($month == $SunMonth)
	{
		if($day < $SunDay)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	else
	{
		return 1;
	}
}

sub checkOutOfMonth($$$){

	my ($date,$month,$year) = ($_[0],$_[1],$_[2]);
	if (whichMonth($month)==1)
	{
		#Condition for month with 31 days
		if ($date > 31)
		{
			return (($date-31),$month+1,$year);
		}
		else
		{
			return ($date,$month,$year);
		}
	}
	elsif (whichMonth($month) == 2)
	{
		if ($date>31 && $index == 1)
		{
			return (($date-31),1,$year+1);
		}
		else
		{
			return ($date,$month,$year);
		}
		
	}
	elsif (whichMonth($month) == 3)
	{
		if ($date > 29 && leap_year($year))
		{
			return (($date-29),$month + 1,$year);
		}
		elsif ($date > 28)
		{
			return (($date-28),$month + 1,$year);
		}
		else
		{
			return ($date,$month,$year);
		}
	}
	else #Condition for month with 30 days
	{
		if ($date > 30)
		{
			return (($date-30),$month + 1,$year);
		}
		else
		{
			return ($date,$month,$year);
		}
	}
	
}

### This subroutine checks if an EAS is sent/received every week ###
sub FCCWeeklySent($$$$$$$){

	my ($tempOldSatDay,$tempOldSatMonth,$tempOldSatYear,$tempSunDay,
	    $tempSunMonth,$tempSunYear,$warnings_No)=($_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6]);
	if($tempOldSatDay != 0) # To avoid first Date Range
	{
		$tempOldSatDay = $tempOldSatDay + 1;
		($tempOldSatDay,$tempOldSatMonth,$tempOldSatYear) = checkOutOfMonth($tempOldSatDay,$tempOldSatMonth,$tempOldSatYear);
		if($tempSunDay != $tempOldSatDay || $tempSunMonth != $tempOldSatMonth || $tempSunYear != $tempOldSatYear)
		{
			$warnings_No = $warnings_No + 1;
			printf OUTHANDLE ("{\\large{DANGER!!!\n");
			printf OUTHANDLE ("No EAS sent during %s/%s/%s -",$tempOldSatMonth,$tempOldSatDay,$tempOldSatYear);
			$tempSunDay = $tempSunDay - 1;

#---------------------- ENTER REASON FOR EAS NOT BEING SENT ----------------------------#

			printf OUTHANDLE ("%s/%s/%s BECAUSE... }}\\newline \\newline \\newline \\newline \\newline\n\n\n\n\n",$tempSunMonth,$tempSunDay,$tempSunYear);

#---------------------------------------------------------------------------------------#

		}
	}
	return $warnings_No;
}

# This subroutine finds the month. I would've liked to use macros like in C to make
# this more readable, but I'm not sure if Perl supports that. ###
sub whichMonth($){

	my $month = $_[0];
	if ($month == 1 || $month == 3 || $month== 5 || $month == 7 || $month == 10 || $month == 8) # 31 days except December
	{
		return 1;
	}
	elsif ($month == 12) # December
	{
		return 2;
	}
	elsif ($month == 2) # February
	{
		return 3;
	}
	else #Condition for month with 30 days
	{
		return 4;
	}
}

### This subroutine is used to check if the next date encountered in the
### eas log file is after the previous week's Saturday. (i.e -> Start of
### a new week.###
sub NotWithinDateRange($$$$$$){
	
	my ($day,$month,$year,$oldSatDay,$oldSatMonth,$oldSatYear) = ($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);
	if ($day > $oldSatDay && $month == $oldSatMonth && $year == $oldSatYear) # Checks dates if dates are in same month
	{
		return 1;
	}
	elsif ($month > $oldSatMonth && $year == $oldSatYear) # Checks if dates are in different months and same year
	{
		return 1;
	}
	elsif ($year > $oldSatYear) #Checks if dates are in different years.
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

### This subroutine generates the Date range. ###
sub genDateRange($$$){

	my ($day,$month,$year) = ($_[0],$_[1],$_[2]);
	my ($SunDay,$SunMonth,$SunYear,$SatDay,$SatMonth,$SatYear);
	if (Day_of_Week($year,$month,$day) == 7)
	{
		($SunDay,$SunMonth,$SunYear) = ($day,$month,$year);
		$SatMonth = $month; $SatYear = $year;
		$SatDay = $SunDay + 6;
		if (whichMonth($SunMonth) == 1)
		{
			if ($SatDay > 31){$SatDay = $SatDay - 31;$SatMonth = $SatMonth + 1;}
		}
		elsif (whichMonth($SunMonth) == 2)
		{
			if ($SatDay > 31){$SatDay = $SatDay - 31; $SatMonth = 1; $SatYear = $SatYear + 1;}
		}
		elsif (whichMonth($SunMonth) == 3)
		{
			if ($SatDay > 29 && leap_year($SatYear)){$SatDay = $SatDay - 29; $SatMonth = $SatMonth + 1;}
			elsif ($SatDay > 28){$SatDay = $SatDay - 28;$SatMonth = $SatMonth + 1;}
		}
		elsif (whichMonth($SunMonth) == 4)
		{
			if ($SatDay > 30){$SatDay = $SatDay - 30;$SatMonth = $SatMonth + 1;}
		}
	}
	else
	{
		($SunYear,$SunMonth,$SunDay) = Add_Delta_Days(Monday_of_Week(Week_of_Year($year,$month,$day)),-1);
		($SatYear,$SatMonth,$SatDay)= Add_Delta_Days(Monday_of_Week(Week_of_Year($year,$month,$day)),5);
	}
	return ($SunYear,$SunMonth,$SunDay,$SatYear,$SatMonth,$SatDay);

}
sub prependZero($)
{
	my $number = $_[0];
	if($number < 10 && !($number =~ m/[0]\d/))
	{
		$number = "0".$number;
	}
	return $number;
}
1;
