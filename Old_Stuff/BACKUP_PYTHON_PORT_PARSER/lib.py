import re, sys, operator, getopt, datetime, os, calendar

class	EasFileHandles:
	# fhandle_list[0] = eas.log, fhandle_list[1] = output.tex and/or fhandle_list[2] = trace
	def	__init__(self, fhandle_list, trace_flag):
		# Check for existence of eas.log file in current directory.
		if not os.path.exists(fhandle_list[0]):
			print "No eas.log file found in current directory."
			sys.exit(0)

		self.OpenInFile(fhandle_list[0],"r")
		self.OpenOutFile(fhandle_list[1],"w")
		if trace_flag == True:
			self.OpenTraceFile(fhandle_list[2],"w")
		#self.infile = open(fhandle_list[0],"r")
		#self.outfile = open(fhandle_list[1],"w")
		#if trace_flag == True:
			#self.tracefile = open(fhandle_list[2],"w")
		self.trace_flag = trace_flag
		self.eas_file_list = self.infile.readlines()
		self.index = 0
		# We don't want newlines.
		self.eas_infile_line = self.eas_file_list[self.index].rstrip()
		
	def	EndOfList(self):
		if self.index < len(self.eas_file_list):
			return False
		else:
			return True

	def	GetLineFromCurrentIndex(self):
		if self.EndOfList():
			if self.trace_flag == True:
				self.WriteTo_TraceFile("Eof reached\n")
		else:
			self.eas_infile_line = self.eas_file_list[self.index].rstrip()

	def 	HandleMatchedFilterAndAlreadyHeard(self):
		if re.search("(Matched Filter)", self.eas_infile_line):
			self.IncrementIndexByOne()
		if "Already heard" in self.eas_infile_line:
			self.WriteAlreadyHeard_ToOutFile()

	def	IncrementIndexByOne(self):
		self.index = self.index + 1
		if self.EndOfList():
			if self.trace_flag == True:
				self.WriteTo_TraceFile("Eof reached\n")
		self.GetLineFromCurrentIndex()

	def 	ExtractDate(self):
		date_regex = "(\d{2})\/(\d{2})\/(\d{2})"
		match = re.search(date_regex, self.eas_infile_line).groups()
		return datetime.date(2000+int(match[2]),int(match[0]),int(match[1]) )

	def 	GoToNextAlert_Or_EndOfList(self):
		date_regex = "(\d{2})\/(\d{2})\/(\d{2})"
		while re.search("((Alert Received)|(Alert sent)|(Local Alert))", self.eas_infile_line)==None\
					and not self.EndOfList():
					#and re.search(date_regex, self.eas_infile_line)==None\
			self.IncrementIndexByOne()

	def	WriteHeaderTo_OutFile(self):
		self.WriteToOutFile("\\documentclass{article}\n\n\\usepackage{ulem}\n\n\\begin{document}\n\n")
		self.WriteToOutFile("\\noindent \\underline{WREK EAS LOG for this Week} \n\n\\medskip\n\n")

	def	WriteDateRangeTo_OutFile(self, requested_week):
		self.WriteToOutFile("\\noindent \\underline{WEEK RANGE: "+FormattedDateString(requested_week.sunday)\
				+" - "+FormattedDateString(requested_week.saturday)+"(Sunday - Saturday)}\n\n\\medskip\n\n")

	def	WriteAlreadyHeard_ToOutFile(self):
		self.WriteToOutFile("\n\n\\medskip\n\n\\medskip\n\n \\hspace{20 pt}Already heard \n\n\\medskip\n\n")

	def	WriteFooterToOutFile(self, requested_week):
		one_day_after = datetime.timedelta(1)
		self.WriteToOutFile("\n\\noindent {\\large{Signed,}}\n \\underline{\\hspace{100 pt}}, "\
				+FormattedDateString(requested_week.saturday + one_day_after)\
				+"\n\n\\medskip\n\n{\\large{Chief Engineer, Alternate, or Authorized "\
				+" Representative for Signing Logs \\newline (circle one)}} "\
				+"\n\n\\medskip\n\n \\noindent {\\large{Please print and add to log}}")
		self.WriteToOutFile("\\noindent \n\n\\medskip\n\n\\end{document}")

	def	WriteRequestedWeekTo_TraceFile(self, requested_week):
		self.WriteTo_TraceFile("Requested week is -> "+FormattedDateString(requested_week.sunday)+" - "\
					+FormattedDateString(requested_week.saturday)+"\n")

	def	WriteNotInDateRange_ToTraceFile(self, requested_week, extracted_date):
		self.WriteTo_TraceFile(FormattedDateString(extracted_date)+" is not within "\
			+FormattedDateString(requested_week.sunday)+" - "+FormattedDateString(requested_week.saturday)+"\n")

	def	WriteInDateRangeTo_TraceFile(self, alert, requested_week, week):
		self.WriteTo_TraceFile("\n\nFOUND!\n\n"+FormattedDateString(alert.curr_date)\
				+" was found to be in the date range "\
				+FormattedDateString(requested_week.sunday)+" - "\
				+FormattedDateString(requested_week.saturday)+"\n")
		self.WriteTo_TraceFile("\n\nRequested Sunday is "+str(requested_week.sunday.month)+"/"+str(requested_week.sunday.day)\
				+"/"+str(requested_week.sunday.year)+"\nRequested Saturday is "+str(requested_week.saturday.month)+"/"\
				+str(requested_week.saturday.day)+"/"+str(requested_week.saturday.year)+"\nNew week Sunday is "\
				+str(week.sunday.month)+"/"+str(week.sunday.day)+"/"+str(week.sunday.year)+"\nNew week Saturday is "\
				+str(week.saturday.month)+"/"+str(week.saturday.day)+"/"+str(week.saturday.year)+"\n")

	def 	WriteTo_TraceFile(self,string):
		if self.trace_flag == True:
			self.tracefile.write(string)

	def 	WriteToOutFile(self,string):
		self.outfile.write(string)

	def	OpenOutFile(self,file,mode):
		self.outfile = open(file,mode)

	def	OpenInFile(self,file,mode):
		self.infile = open(file,mode)

	def	OpenTraceFile(self,file,mode):
		self.tracefile = open(file,mode)

	def	CloseOutFile(self):
		self.outfile.close()

	def	CloseTraceFile(self):
		self.tracefile.close()

	def	CloseInFile(self):
		self.infile.close()

class	Week:
	# Constructor
	def	__init__(self, sunday,saturday):
		self.sunday = sunday
		self.saturday = saturday

		self.monitor1_received = False
		self.monitor2_received = False
		self.monitor_sent = False
		self.wrek_sent = False
		self.rwt = False

	# = operator
	def	__set__(self, week2):
		self.sunday = datetime.date(week2.sunday.year, week2.sunday.month, week2.sunday.day)
		self.saturday = datetime.date(week2.saturday.year, week2.saturday.month, week2.saturday.day)

	# == operator
	def 	__eq__(self, week):
		if self.sunday.day == week.sunday.day\
			 and self.sunday.month == week.sunday.month\
			 and self.sunday.year == week.sunday.year\
			 and self.saturday.day == week.saturday.day\
			 and self.saturday.month == week.saturday.month\
			 and self.saturday.year == week.saturday.year:
			return True
		else:
			return False

	"""
	# Returns True if it is out of Generated Range. Assumption -> date never goes past sunday of the requested generated week.
	def	CheckOutOfGeneratedRange(self,date):
		if date.day > self.saturday.day and date.month == self.saturday.month and date.year == self.saturday.year:
			#print "date.day ",date.day, " > ","self.saturday.day ",self.saturday.day
			return True
		elif date.month > self.saturday.month and date.year == self.saturday.year:
			#print "date.month ",date.month, " > ","self.saturday.month ",self.saturday.month
			return True
		elif date.year > self.saturday.year:
			#print "date.year ",date.year, " > ","self.saturday.year ",self.saturday.year
			return True
		else:
			return False
	
	def	CheckForMonitorsSendingAndReceiving(self, eas_handles):
		if self.monitor1_received == False:
			eas_handles.WriteToOutFile("\n\n\\noindent {\\large{\\uueas_infile_line{NO CALL SIGNS RECEIVED ON MONITOR 2 !!!}}}"\
						 +"\n\n\\medskip\n\n")
		if self.monitor2_received == False:
			eas_handles.WriteToOutFile("\n\n\\noindent {\\large{\\uueas_infile_line{NO CALL SIGNS RECEIVED ON MONITOR 1 !!!}}}"\
						 +"\n\n\\medskip\n\n")
		if self.wrek_sent == False:
			eas_handles.WriteToOutFile("\n\n\\noindent {\\large{\\uueas_infile_line{NO CALL SIGNS SENT !!!}}} \n\n\\medskip\n\n")
	"""
				

month_table = {1:[31,31],2:[28,29],3:[31,31],4:[30,30],5:[31,31],6:[30,30],7:[31,31],8:[31,31],9:[30,30],10:[31,31],11:[30,30],12:[31,31]}
class	Month:
	def	__init__(self, week):
		self.rmt = False

	# Taken from-> http://www.pro9ramming.com/-python-leap-year-finder-t-1189.html
	def	LeapYear(self,year):
		if year % 400 == 0:
			return 1
		elif year % 100 == 0:
			return 1
		elif year % 4 == 0:
			return 1
		else:
			return 0

	def	RmtCheckNecessary(self, week):
		if month_table[week.saturday.month][self.LeapYear(week.saturday.year)] == 30:
		#if calendar.monthrange(week.saturday.year, week.saturday.day)[1] == 30:
			if week.sunday.day >= 23 and (week.saturday.day <= 7 or week.saturday.day == 30 ):
				return True
		#elif calendar.monthrange(week.saturday.year, week.saturday.day)[1] == 31:
		if month_table[week.saturday.month][self.LeapYear(week.saturday.year)] == 31:
			if week.sunday.day >= 23 and (week.saturday.day <= 7 or week.saturday.day == 31 ):
				return False
		# Accounting for February leap years and otherwise
		#elif calendar.monthrange(week.saturday.year, week.saturday.day)[1] == 28:
		if month_table[week.saturday.month][self.LeapYear(week.saturday.year)] == 28:
			if week.sunday.day >= 21 and (week.saturday.day <= 7 or week.saturday.day == 31 ):
				return False
		#elif calendar.monthrange(week.saturday.year, week.saturday.day)[1] == 29:
		if month_table[week.saturday.month][self.LeapYear(week.saturday.year)] == 29:
			if week.sunday.day >= 22 and (week.saturday.day <= 7 or week.saturday.day == 31 ):
				return False
		

	def	SearchForRmt(self, alert, eas_handles, week):
		if self.RmtCheckNecessary(week) == True:
			alert.GetAlertDetails(eas_handles)
			alert.ExtractInfoFromZCZC(eas_handles, week)
			if "RMT" in alert.eastype:
				self.rmt = True

	def 	Rmt_CheckAndSearch(self, week, alert):
		if self.RmtCheckNecessary(week) == True:
			if "RMT" in alert.eastype:
				self.rmt = True

	def 	CheckIf_RmtOutsideWeekRange(self, eas_handles, week):
		if self.RmtCheckNecessary(week) == True:
			date_regex = "(\d{2})\/(\d{2})\/(\d{2})"
			alert = Alert()
			match = re.search(date_regex, eas_handles.eas_infile_line).groups()
			eas_handles.IncrementIndexByOne()
			alert.curr_date = datetime.date(2000+int(match[2]),int(match[0]),int(match[1]) )
			if re.search("(Matched Filter)|(Already heard)", eas_handles.eas_infile_line):
				eas_handles.IncrementIndexByOne()
			self.SearchForRmt(alert,eas_handles,week)
		

class	Alert:
	def	__init__(self):
		self.zczc = ""
		self.monitor = ""
		# Constructor needs arguments, I believe
		self.curr_date = datetime.date(1,1,1)
		self.curr_time = ""
		self.easwhere = ""
		self.eastype = ""
		self.eom_date = ""
		self.eom_time = ""
		self.rec_or_sent = ""
		self.alert_details = ""

	def	GetAlertDetails(self, eas_handles):
		while re.search("^ZCZC",eas_handles.eas_infile_line) == None and not eas_handles.EndOfList():
			self.alert_details = self.alert_details + eas_handles.eas_infile_line
			eas_handles.IncrementIndexByOne()

	def 	SetReceivedOrSent(self, eas_handles):
		if "Received" in eas_handles.eas_infile_line:
			self.rec_or_sent = "Received"
			self.monitor = re.search("monitor #(\d)", eas_handles.eas_infile_line).group(1)
		elif "Local Alert" in eas_handles.eas_infile_line:
			self.rec_or_sent = "(Local Alert) Sent"
		else:
			self.rec_or_sent = "Sent"

	def 	SetTime(self, eas_handles):
		time_regex = "(\d{2}:\d{2}:\d{2})" 
		if re.search(time_regex, eas_handles.eas_infile_line): 
			self.curr_time = re.search(time_regex, eas_handles.eas_infile_line).group(1)

	def	ExtractInfoFromZCZC(self, eas_handles, week):
		self.eastype = eas_handles.eas_infile_line[9:12]
		self.zczc = eas_handles.eas_infile_line
		while re.search("-$",eas_handles.eas_infile_line) == None and not eas_handles.EndOfList():
			eas_handles.IncrementIndexByOne()
			self.zczc = self.zczc + eas_handles.eas_infile_line
		if re.search("([A-Z ]{7,8}-$)", self.zczc):
			if self.rec_or_sent == "Received":
				if "1" in self.monitor:
					week.monitor1_received = True
				else:
					week.monitor2_received = True
			if "Sent" in self.rec_or_sent:
				week.wrek_sent = True
			self.easwhere = re.search("([A-Z ]{7,8}-$)", self.zczc).group(1)
			eas_handles.IncrementIndexByOne()

	def	Check_For_Eom_And_Display_Received_Info(self, eas_handles):
		if re.search("^EOM",eas_handles.eas_infile_line):
			self.eom_date = re.search("(\d{2}\/\d{2}\/\d{2})",eas_handles.eas_infile_line).group(1)
			self.eom_time = re.search("(\d{2}:\d{2}:\d{2})",eas_handles.eas_infile_line).group(1)
			self.monitor = re.search("#(\d)",eas_handles.eas_infile_line).group(1)
			eas_handles.WriteToOutFile("\\hspace{20 pt}     "+self.rec_or_sent+" "+self.eastype+" from "+self.easwhere+" at "\
				+FormattedDateString(self.curr_date)+" "+self.curr_time+" (EOM Received at "+self.eom_date+" "\
				+self.eom_time+" on monitor \\#"+self.monitor+") \\\\")
		else:
			if "Received" in self.rec_or_sent:
				eas_handles.WriteToOutFile("\\hspace{20 pt}     "+self.rec_or_sent+" "+self.eastype+" from "+self.easwhere+" at "\
					+FormattedDateString(self.curr_date)+" "+self.curr_time+" on monitor \\#"+self.monitor+"\\\\")
			else:
				eas_handles.WriteToOutFile("\\hspace{20 pt}     "+self.rec_or_sent+" "+self.eastype+" from "+self.easwhere+" at "\
					+FormattedDateString(self.curr_date)+" "+self.curr_time+"\\\\")
		if re.search("RWT", self.eastype):
			eas_handles.WriteToOutFile("\\hspace{20pt}     A broadcast station or cable system has issued a required weekly test"\
						 +"\n\n\\medskip\n\n")
		else:
			eas_handles.WriteToOutFile("     "+self.alert_details+" \n\n\\medskip\n\n")

	def	Check_For_Eom_And_Display_Sent_Info(self, eas_handles):
		if re.search("^EOM", eas_handles.eas_infile_line):
			self.eom_date = re.search("(\d{2}\/\d{2}\/\d{2})", eas_handles.eas_infile_line).group(1)
			self.eom_time = re.search("(\d{2}:\d{2}:\d{2})", eas_handles.eas_infile_line).group(1)
			# Takes care of "EOM not heard" messages.
			if "not heard" not in eas_handles.eas_infile_line:
				self.monitor = re.search("#(\d)", eas_handles.eas_infile_line).group(1)
				eas_handles.WriteToOutFile("\\hspace{20 pt}     "+self.rec_or_sent+" "\
					+self.eastype+" from "+self.easwhere+" at "\
					+FormattedDateString(self.curr_date)+" "+self.curr_time+" (EOM Received at "+self.eom_date+" "\
					+self.eom_time+" on monitor \\#"+self.monitor+") \\\\")
			else:
				eas_handles.WriteToOutFile("\\hspace{20 pt} 	EOM not heard, timeout at "+self.eom_date+" "\
					+self.eom_time)
		else:
			if "Received" in self.rec_or_sent:
				eas_handles.WriteToOutFile("\\hspace{20 pt}     "+self.rec_or_sent+" "\
					+self.eastype+" from "+self.easwhere+" at "\
					+FormattedDateString(self.curr_date)+" "+self.curr_time+" on monitor \\#"+self.monitor+"\\\\")
			else:
				eas_handles.WriteToOutFile("\\hspace{20 pt}     "+self.rec_or_sent+" "\
					+self.eastype+" from "+self.easwhere+" at "\
					+FormattedDateString(self.curr_date)+" "+self.curr_time+"\\\\")
		if re.search("RWT", self.eastype):
			eas_handles.WriteToOutFile("\\hspace{20pt}     A broadcast station or cable system has issued a required weekly test"\
						 +"\n\n\\medskip\n\n")
		else:
			eas_handles.WriteToOutFile("     "+self.alert_details+" \n\n\\medskip\n\n")
				
	def	FlagRelevantAlerts(self,week):
		if "1" in self.monitor and "Received" in self.rec_or_sent:
			week.monitor1_received = True
		if "2" in self.monitor and "Received" in self.rec_or_sent:
			week.monitor1_sent = True
		if "Sent" in self.rec_or_sent:
			week.monitor_sent = True
		if "RWT" in self.eastype:
			week.rwt = True
		if "WREK" in self.easwhere:
			week.rwt = True

# Table -> Weekday : Sunday offset, Saturday offset
# Cheap way of calculating offsets of Saturday and Sunday from given date
day_offset_table = {0:[-1,5],1:[-2,4],2:[-3,3],3:[-4,2],4:[-5,1],5:[-6,0],6:[0,6]}

def	GenerateSunSatFromDate(date):
	saturday = date + datetime.timedelta(day_offset_table[date.weekday()][1])
	sunday = date + datetime.timedelta(day_offset_table[date.weekday()][0])
	week = Week(sunday,saturday)
	return week

def	FormattedDateString(date):
	datestring = date.isoformat()
	return datestring[5:7]+"/"+datestring[8:10]+"/"+datestring[2:4]

def	FormattedTimeString(time_list):
	return time_list[0]+":"+time_list[1]+":"+time_list[2]

def	Eas_Offline_Check( eas_handles):
	if re.search("^EAS Machine Offeas_infile_line", eas_handles.eas_infile_line):
		times = lib.re.findall("(\d{2}):(\d{2}):(\d{2})")
		hour_diff = abs( int(times[0][0]) - int(times[1][0]) )
		minute_diff = abs( int(times[0][1]) - int(times[1][1]) )
		second_diff = abs( int(times[0][2]) - int(times[1][2]) )
		eas_handles.WriteToOutFile("{\\large{\\uueas_infile_line{EAS WAS OFFLINE for "+hour_diff+" hours, "+minute_diff\
			+" minutes and "+second_diff+" seconds (FROM "+FormattedTimeString(times[0])+" to "\
			+FormattedTimeString(times[1])+")}}} \n\n\\medskip\n\n")

def	Perform_Trace_Extraction( week, alert, eas_handles):
	eas_handles.WriteTo_TraceFile("\n\nMatched date-> "+str(alert.curr_date.month)+"/"+str(alert.curr_date.day)+"/"+str(alert.curr_date.year)+"\n")
	eas_handles.WriteTo_TraceFile("Generated date range-> "+FormattedDateString(week.sunday)+" - "+FormattedDateString(week.saturday)+"\n")
	eas_handles.WriteTo_TraceFile("Alert was "+alert.rec_or_sent+" on monitor \\#"+alert.monitor+" at "+alert.curr_time+"\n")
	eas_handles.WriteTo_TraceFile("Alert details are:\n"+alert.alert_details+"\n")
	eas_handles.WriteTo_TraceFile("Alert zczc is:\n"+alert.zczc+"\n")
	eas_handles.WriteTo_TraceFile("Eas type is:"+alert.eastype+"\n")
	eas_handles.WriteTo_TraceFile("Eas where is:"+alert.easwhere+"\n")
	eas_handles.WriteTo_TraceFile("Eom date is:"+alert.eom_date+" "+ alert.eom_time+" "+"\n")
	eas_handles.WriteTo_TraceFile("Current time is:"+alert.curr_time+"\n")
	eas_handles.WriteTo_TraceFile("Current date is:"+FormattedDateString(alert.curr_date)+"\n")
	eas_handles.WriteTo_TraceFile("This alert is done"+"\n\n\n\n\n\n\n\n")
	eas_handles.WriteTo_TraceFile("Next alert"+"\n\n")

def 	ParseOptions():
	trace_flag = False
	try:
		opts, args = getopt.getopt(sys.argv[1:],"d:m:y:t")
		# Extract options
		keys = map(operator.itemgetter(0), opts)
		# Extract values of options
		values = map(operator.itemgetter(1), opts)
		# Extract indices of options
		value_indices = [keys.index("-y"), keys.index("-m"), keys.index("-d")]
	except:
		print "Your arguments are incorrect. Try again."
		sys.exit(0)
	try:
		if 't' in opts[3][0]:
			trace_flag = True
	except:
		trace_flag = False
	#requested_date = datetime.date( int(opts[2][1]), int(opts[1][1]), int(opts[0][1]) )
	requested_date = datetime.date( 2000+int(values[value_indices[0]]), int(values[value_indices[1]]), int(values[value_indices[2]]) )
	#print requested_date.isoformat()
	return requested_date, trace_flag

def	Fcc_Compliant(parser_week, eas_handles,month):
	if parser_week.monitor1_received == False:
		eas_handles.WriteToOutFile("{\\large{WARNING!!! No alerts received during "+FormattedDateString(parser_week.sunday)+" - "\
			+FormattedDateString(parser_week.saturday) +" on monitor \\#1}}\n\n")
	if parser_week.monitor2_received == False:
		eas_handles.WriteToOutFile("{\\large{WARNING!!! No alerts received during "+FormattedDateString(parser_week.sunday)+" - "\
			+FormattedDateString(parser_week.saturday) + " on monitor \\#2}}\n\n")
	if parser_week.monitor_sent == False and parser_week.wrek_sent == True:
		eas_handles.WriteToOutFile("{\\large{WARNING!!! No alerts sent during "+FormattedDateString(parser_week.sunday)+" - "\
			+FormattedDateString(parser_week.saturday) + " }}\n\n")
	if parser_week.rwt == False:
		eas_handles.WriteToOutFile("{\\large{WARNING!!! No RWTs sent during "+FormattedDateString(parser_week.sunday)+" - "\
			+FormattedDateString(parser_week.saturday) + " }}\n\n")
	if parser_week.wrek_sent == False:
		eas_handles.WriteToOutFile("{\\large{WARNING!!! No alerts sent by WREK FM during "+FormattedDateString(parser_week.sunday)+" - "\
			+FormattedDateString(parser_week.saturday) + " }}\n\n")
	if month.RmtCheckNecessary(parser_week) == True:
		if month.rmt == False:
			eas_handles.WriteToOutFile("{\\large{WARNING!!! No RMT sent during "+parser_week.sunday.month+","+parser_week.sunday.year+"}}")
