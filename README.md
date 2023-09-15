# cli-calendar
A linux command line calender written in 32-bit x86 assembly. Prints and tracks user submitted events.

Assembly Final Project

Here is an initial example of how mktime works in assembly:
https://stackoverflow.com/a/19172500

I built off this idea to create a functional planner calender that:

	1. Starts at the current month.
	2. Is able to be traverse backward and forward month at a time.
	3. Creates and removes events that are associated with each month.
		a. each event is sorted when printed out to the terminal.
	4. Functional clear_screen and raw_mode utilization that makes
	   traversing and exiting the calender look nice.
	5. Can traverse from the year 1909 to the year 2038.

There are also future fixes and implementations I would like to take note of:

	1. Implement leap year.
	2. Make events unique to the specific month of the year.
	3. Make multiple events for a single day.
