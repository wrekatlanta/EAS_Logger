#!/usr/bin/python
import lib


# Options parsing. Enter: python parser.py -d <value> -m <value> -y <value> -t
# "-t" is optional
# trace_flag is true if "-t" is included.
# Calculates date and trace flag from parameters.
requested_date, trace_flag = lib.ParseOptions()

# File names used
infile = "eas.log"
outfile = "output.tex"
trace = "trace"

# List of files
fhandle_list = []
fhandle_list.append(infile)
fhandle_list.append(outfile)
if trace_flag == True:
	fhandle_list.append(trace)
# Handles file i/o
eas_handles = lib.EasFileHandles(fhandle_list, trace_flag)
# Don't need input file because all lines are stored in a list and can be indexed.
eas_handles.CloseInFile()
eas_handles.WriteHeaderTo_OutFile()
# Calculates week range from date
requested_week = lib.GenerateSunSatFromDate(requested_date)
if trace_flag == True:
	eas_handles.WriteRequestedWeekTo_TraceFile
# For RMT check
month = lib.Month(requested_week)

# Equivalent of Eof Check
while not eas_handles.EndOfList():
	# Regex for matching dates
	date_regex = "(\d{2})\/(\d{2})\/(\d{2})"
	if lib.re.search("((Alert Received)|(Alert sent)|(Local Alert))", eas_handles.eas_infile_line )\
			 and lib.re.search(date_regex, eas_handles.eas_infile_line):
		# Get date from line.
		extracted_date = eas_handles.ExtractDate()
		# Get week range from date
		week = lib.GenerateSunSatFromDate(extracted_date)
		# Trace file stuff
		if trace_flag == True:
			if not requested_week.__eq__(week):
				eas_handles.WriteNotInDateRange_ToTraceFile(requested_week, extracted_date)

		# Weekly checks
		if requested_week == week:
			# TRACE
			eas_handles.WriteDateRangeTo_OutFile(requested_week)
			while requested_week == week and not eas_handles.EndOfList():
				alert = lib.Alert()
				alert.curr_date = eas_handles.ExtractDate()
				week = lib.GenerateSunSatFromDate(alert.curr_date)
				# TRACE
				if trace_flag == True:
					eas_handles.WriteInDateRangeTo_TraceFile(alert, requested_week, week)
				# Received or sent?
				alert.SetReceivedOrSent(eas_handles)
				# Set time
				alert.SetTime(eas_handles)
				# Writes only if trace_flag == True
				eas_handles.WriteTo_TraceFile(eas_handles.eas_infile_line)
				# Increments index and goes to next line
				eas_handles.IncrementIndexByOne()
				eas_handles.HandleMatchedFilterAndAlreadyHeard()
				alert.GetAlertDetails(eas_handles)
				eas_handles.GetLineFromCurrentIndex()
				eas_handles.WriteTo_TraceFile(eas_handles.eas_infile_line)
				# Assuming the eas_infile_line now contains a ZCZC
				#print eas_handles.eas_infile_line
				alert.ExtractInfoFromZCZC(eas_handles, requested_week)

				# RMT checks
				month.Rmt_CheckAndSearch(week, alert)
				# This is where alerts are marked true or false. If they are marked false at end of program... VERY BAD news.
				alert.FlagRelevantAlerts(requested_week)
				if not eas_handles.EndOfList():
					if alert.rec_or_sent == "Received":
						alert.Check_For_Eom_And_Display_Received_Info(eas_handles)
					else:
						alert.Check_For_Eom_And_Display_Sent_Info(eas_handles)
					eas_handles.IncrementIndexByOne()
				else:
					break
				if trace_flag == True:
					lib.Perform_Trace_Extraction( requested_week, alert, eas_handles, month, requested_week)
				eas_handles.GoToNextAlert_Or_EndOfList()
				if eas_handles.EndOfList():
					break
				# Generate next date and week before exiting loop so that comparison can be made
				alert.curr_date = eas_handles.ExtractDate()
				week = lib.GenerateSunSatFromDate(alert.curr_date)
			break
		# RMT check, if date is not in the requested week.
		month.CheckIf_RmtOutsideWeekRange( eas_handles, week, requested_week, trace_flag)

	else:
		lib.Eas_Offline_Check(eas_handles)
	if eas_handles.EndOfList():
		break
	eas_handles.IncrementIndexByOne()

lib.Fcc_Compliant(requested_week, eas_handles, month, trace_flag)
month.RmtCheckForTraceFile(requested_week, eas_handles, trace_flag)
eas_handles.WriteFooterToOutFile(requested_week)
eas_handles.WriteTo_TraceFile("\nWrote Footer")
if trace_flag == True:
	eas_handles.CloseTraceFile()
eas_handles.CloseOutFile()
