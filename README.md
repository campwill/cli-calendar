# cli-calendar
A linux command line calendar written in 32-bit x86 assembly. Prints and tracks user submitted events.

Here is an initial example of how mktime works in assembly: https://stackoverflow.com/a/19172500

I built off this idea to create a functional planner calendar that:

1. Starts at the current month.
2. Is able to be traverse backward and forward month at a time.
3. Creates and removes user submitted events that are associated with each month.
4. Each event is saved and sorted when printed out to the terminal.
5. Functional clear_screen and raw_mode utilization that makes traversing and exiting the calender look nice.

## Installation
1. Download and extract cal.zip from the releases page.
2. Open a terminal within the cal folder and change permission of the install script by running `chmod +x install.sh`.
3. Run the install script by running `sudo ./install.sh`.

## Usage
Run the calendar by typing `cal` in the command line.

While the calendar is running:

`a` - Traverse back one month.

`d` - Traverse forward one month.

`w` - Remove an event.

`s` - Add an event.

`x` - Exit the calendar.

## Notes
There are future fixes and implementations I would like to take note of:

1. Implement leap year.
2. Make events unique to the specific month of the year.
3. Make multiple events for a single day.
