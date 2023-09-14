;Assembly Final Project
;William Campbell


;Here is an initial example of how mktime works in assembly:
;https://stackoverflow.com/a/19172500


;I built off this idea to create a functional planner calender that:
;
;	1. starts at the current month.
;	2. is able to be traverse backward and forward month at a time.
;	3. creates and removes events that are associated with each month.
;		a. each event is sorted when printed out to the terminal.
;	4. functional clear_screen and raw_mode utilization that makes
;	   traversing and exiting the calender look nice.
;	5. can traverse from the year 1909 to the year 2038.


;There are also future fixes and implementations I would like to take note of:
;
;	1. Implement leap year.
;	2. Make events unique to the specific month of the year.
;	3. Make multiple events for a single day.


%include "/usr/local/share/csc314/asm_io.inc"
%define tm_mday 12
%define tm_mon 16
%define tm_wday 24

segment .data
	fmtcalender 	  db "Sun Mon Tue Wed Thu Fri Sat", 10, 0
	fmtmonth    	  db "%B", 0
	fmtmonthyear      db "%13B %Y", 10, 0
	fmtint            db "%d", 0
	fmtstring         db "%s", 0
	fmtentry          db "%d %s", 10, 0
	fmtentryint       db "%d ", 0

	raw_mode_on_cmd   db "stty raw -echo",0
	raw_mode_off_cmd  db "stty -raw echo",0

	Jan  			  db "January", 0
	Feb				  db "February", 0
	Mar 			  db "March", 0
	Apr 			  db "April", 0
	May 			  db "May", 0
	Jun 			  db "June", 0
	Jul 			  db "July", 0
	Aug 			  db "August", 0
	Sep 			  db "September", 0
	Oct 			  db "October", 0
	Nov 			  db "November", 0
	Decm			  db "December", 0

	Sun 	          db "Sunday", 0
	Mon     	      db "Monday", 0
	Tue         	  db "Tuesday", 0
	Wed         	  db "Wednsday", 0
	Thu         	  db "Thursday", 0
	Fri         	  db "Friday", 0
	Sat         	  db "Saturday", 0

	SunMonth 		  db "%3d %3d %3d %3d %3d %3d %3d", 10, 0
	MonMonth    	  db "    %3d %3d %3d %3d %3d %3d", 10, 0
	TueMonth 		  db "        %3d %3d %3d %3d %3d", 10, 0
	WedMonth 		  db "            %3d %3d %3d %3d", 10, 0
	ThuMonth 		  db "                %3d %3d %3d", 10, 0
	FriMonth 		  db "                    %3d %3d", 10, 0
	SatMonth 		  db "                        %3d", 10, 0

	MoreMonth 		  db "%3d ", 0
	MoreMonthNL		  db "%3d ", 10, 0

	Month             dd Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Decm
	WeekDay     	  dd Sun, Mon, Tue, Wed, Thu, Fri, Sat

	Menu0             db "Add Event", 10, 0
	Menu1             db "Enter a Day: ", 0
	Menu2             db "Enter an event: ", 0

	Menu3             db "Remove Event", 10, 0
	Menu4             db "Enter a Day: ", 0

	clear_screen_code db 27,"[2J",27,"[H",0

	JanFile db "/usr/local/share/csc314/Final/events/Jan.txt", 0
	FebFile db "/usr/local/share/csc314/Final/events/Feb.txt", 0
	MarFile db "/usr/local/share/csc314/Final/events/Mar.txt", 0
	AprFile db "/usr/local/share/csc314/Final/events/Apr.txt", 0
	MayFile db "/usr/local/share/csc314/Final/events/May.txt", 0
	JunFile db "/usr/local/share/csc314/Final/events/Jun.txt", 0
	JulFile db "/usr/local/share/csc314/Final/events/Jul.txt", 0
	AugFile db "/usr/local/share/csc314/Final/events/Aug.txt", 0
	SepFile db "/usr/local/share/csc314/Final/events/Sep.txt", 0
	OctFile	db "/usr/local/share/csc314/Final/events/Oct.txt", 0
	NovFile db "/usr/local/share/csc314/Final/events/Nov.txt", 0
	DecFile db "/usr/local/share/csc314/Final/events/Dec.txt", 0
	mode_a  db "a", 0
	mode_r  db "r", 0
	mode_w  db "w", 0
	TmpFile db "/usr/local/share/csc314/Final/Tmp.txt", 0

segment .bss
	timeinfo    	resd    1
	rawtime     	resd    1
	lpszBuffer  	resb    80
	lineint         resd    4
	linestring      resb    1024

segment .text
	global asm_main
	global makeCalender
	global decrement
	global increment
	global printEvents
	global removeEvent

    global raw_mode_on
    global raw_mode_off
	extern system

	extern printf
	extern getchar
	extern putchar

	extern fopen
	extern fclose
	extern fprintf
	extern fscanf
	extern fgetc

	extern time
	extern mktime
	extern localtime
	extern strftime

asm_main:
	push	ebp
	mov		ebp, esp
	; ********** CODE STARTS HERE **********

	mov esi, 0

	;recieve today's date
    push rawtime
    call time
    add esp, 4

    push rawtime
    call localtime
    add esp, 4

	mov dword [timeinfo], eax

	;find the first of the month
	mov dword [eax + tm_mday], 1

	push    dword [timeinfo]
    call    mktime
    add     esp, 4


	call makeCalender


    toptoptop:

	call raw_mode_on

	call getchar

	cmp eax, 'a'
	jne notleft

		call raw_mode_off
		call decrement

	notleft:
	cmp eax, 'd'
	jne notright

		call raw_mode_off
		call increment

	notright:
	cmp eax, 's'
	jne notaddevent

		call raw_mode_off

		push Menu0
		call printf

		push Menu1
		call printf

		call read_int
		mov ebx, eax; ebx = chosen day

		push rawtime
	    call time
	    add esp, 4

	    push rawtime
	    call localtime
	    add esp, 4

		mov dword [timeinfo], eax

		mov dword [eax + tm_mday], ebx

		add dword[eax + tm_mon], esi

		push dword [timeinfo]
	    call mktime
	    add esp, 4

	    push dword [timeinfo]
	    push fmtmonth
	    push 80
	    push lpszBuffer
	    call strftime
	    add esp, 16

		call getchar

		push Menu2
		call printf

		mov edi, 0
		readloop:
			call read_char
			cmp al, ' '
			jne notspace
				mov al, '_'
				mov byte[linestring + edi * 1], al
			notspace:
			mov byte[linestring + edi * 1], al
		inc edi
		cmp al, 10
		jne readloop
		mov byte[linestring + edi * 1 - 1], 0

		mov eax, dword[timeinfo]
		mov eax, dword[eax + tm_mon]
	    mov ecx, dword[Month + 4 * eax]

		cmp ecx, Jan
		jne notJan2

			push JanFile
			call makeEvent

		notJan2:
		cmp ecx, Feb
		jne notFeb2

			push FebFile
			call makeEvent

		notFeb2:
		cmp ecx, Mar
		jne notMar2

			push MarFile
			call makeEvent

		notMar2:
		cmp ecx, Apr
		jne notApr2

			push AprFile
			call makeEvent

		notApr2:
		cmp ecx, May
		jne notMay2

			push MayFile
			call makeEvent

		notMay2:
		cmp ecx, Jun
		jne notJun2

			push JunFile
			call makeEvent

		notJun2:
		cmp ecx, Jul
		jne notJul2

			push JulFile
			call makeEvent

		notJul2:
		cmp ecx, Aug
		jne notAug2

			push AugFile
			call makeEvent

		notAug2:
		cmp ecx, Sep
		jne notSep2

			push SepFile
			call makeEvent

		notSep2:
		cmp ecx, Oct
		jne notOct2

			push OctFile
			call makeEvent

		notOct2:
		cmp ecx, Nov
		jne notNov2

			push NovFile
			call makeEvent

		notNov2:
		cmp ecx, Decm
		jne notDec2

			push DecFile
			call makeEvent

		notDec2:

		push edi
		call fclose
		add esp, 4

		push rawtime
	    call time
	    add esp, 4

	    push rawtime
	    call localtime
	    add esp, 4

		mov dword [timeinfo], eax

		;call makeCalender ;temp fix, makeCalender doesnt update when entering event
		call increment
		call decrement

	notaddevent:
	cmp eax, 'w'
	jne notremove

		;remove entry from file
		call raw_mode_off

		push Menu3
		call printf

		push Menu4
		call printf

		call read_int
		mov ebx, eax; ebx = chosen day


		mov eax, dword[timeinfo]
		mov eax, dword[eax + tm_mon]
	    mov ecx, dword[Month + 4 * eax]

		cmp ecx, Jan
		jne notJan4

			push ebx
			push JanFile
			call removeEvent

		notJan4:
		cmp ecx, Feb
		jne notFeb4

			push ebx
			push FebFile
			call removeEvent

		notFeb4:
		cmp ecx, Mar
		jne notMar4

			push ebx
			push MarFile
			call removeEvent

		notMar4:
		cmp ecx, Apr
		jne notApr4

			push ebx
			push AprFile
			call removeEvent

		notApr4:
		cmp ecx, May
		jne notMay4

			push ebx
			push MayFile
			call removeEvent

		notMay4:
		cmp ecx, Jun
		jne notJun4

			push ebx
			push JunFile
			call removeEvent

		notJun4:
		cmp ecx, Jul
		jne notJul4

			push ebx
			push JulFile
			call removeEvent

		notJul4:
		cmp ecx, Aug
		jne notAug4

			push ebx
			push AugFile
			call removeEvent

		notAug4:
		cmp ecx, Sep
		jne notSep4

			push ebx
			push SepFile
			call removeEvent

		notSep4:
		cmp ecx, Oct
		jne notOct4

			push ebx
			push OctFile
			call removeEvent

		notOct4:
		cmp ecx, Nov
		jne notNov4

			push ebx
			push NovFile
			call removeEvent

		notNov4:
		cmp ecx, Decm
		jne notDec4

			push ebx
			push DecFile
			call removeEvent

		notDec4:

		push rawtime
	    call time
	    add esp, 4

	    push rawtime
	    call localtime
	    add esp, 4

		mov dword [timeinfo], eax

		;call makeCalender ;temp fix, makeCalender doesnt update when entering event
		call increment
		call decrement

	notremove:
	cmp eax, 'x'
	jne notexit

		jmp exit

	notexit:


	jmp toptoptop

	exit:
	call raw_mode_off

    push clear_screen_code
	call printf
	add esp, 4

	; *********** CODE ENDS HERE ***********
	mov		eax, 0
	mov		esp, ebp
	pop		ebp
	ret

raw_mode_on:
    push    ebp
    mov     ebp, esp

	push    raw_mode_on_cmd
    call    system
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

raw_mode_off:
    push    ebp
    mov     ebp, esp

	push    raw_mode_off_cmd
    call    system
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

increment:
	push ebp
	mov ebp, esp

	inc esi

	push rawtime
    call time
    add esp, 4

    push rawtime
    call localtime
    add esp, 4

	mov dword [timeinfo], eax

	mov dword [eax + tm_mday], 1

	add dword[eax + tm_mon], esi

	push    dword [timeinfo]
    call    mktime
    add     esp, 4

	call makeCalender

	mov esp, ebp
	pop ebp
	ret


decrement:
	push ebp
	mov ebp, esp

	dec esi

	push rawtime
    call time
    add esp, 4

    push rawtime
    call localtime
    add esp, 4

	mov dword [timeinfo], eax

	mov dword [eax + tm_mday], 1

	add dword[eax + tm_mon], esi

	push    dword [timeinfo]
    call    mktime
    add     esp, 4

	call makeCalender

	mov esp, ebp
	pop ebp
	ret

makeCalender:
	push ebp
	mov	ebp, esp

	sub esp, 4; amount of days in month, dword[ebp-4]


    push clear_screen_code
	call printf
	add esp, 4

	call print_nl


    push dword [timeinfo]
    push fmtmonthyear
    push 80
    push lpszBuffer
    call strftime
    add esp, 4 * 4

	push lpszBuffer
	call printf

	push fmtcalender
	call printf

	;identify month

	mov eax, dword[timeinfo]
	mov eax, dword[eax + tm_mon]
    mov ecx, dword[Month + 4 * eax]

	cmp ecx, Jan
	jne notJan
		mov dword[ebp-4], 31
	notJan:
	cmp ecx, Feb
	jne notFeb
		;future implementation: check for leap year
		mov dword[ebp-4], 29
	notFeb:
	cmp ecx, Mar
	jne notMar
		mov dword[ebp-4], 31
	notMar:
	cmp ecx, Apr
	jne notApr
		mov dword[ebp-4], 30
	notApr:
	cmp ecx, May
	jne notMay
		mov dword[ebp-4], 31
	notMay:
	cmp ecx, Jun
	jne notJun
		mov dword[ebp-4], 30
	notJun:
	cmp ecx, Jul
	jne notJul
		mov dword[ebp-4], 31
	notJul:
	cmp ecx, Aug
	jne notAug
		mov dword[ebp-4], 31
	notAug:
	cmp ecx, Sep
	jne notSep
		mov dword[ebp-4], 30
	notSep:
	cmp ecx, Oct
	jne notOct
		mov dword[ebp-4], 31
	notOct:
	cmp ecx, Nov
	jne notNov
		mov dword[ebp-4], 30
	notNov:
	cmp ecx, Decm
	jne notDecm
		mov dword[ebp-4], 31
	notDecm:

	;--------------
	;print calender (based on current first day of the month)
	;--------------

	;also, this part looks repetitive, and function worthy, however i will do this in the future due to time constraints and the amounts of different values used

    mov     eax, dword [timeinfo]
    mov     eax, dword [eax + tm_wday]
    mov     ecx, dword [WeekDay + 4 * eax]

	cmp ecx, Sun
	jne notSun

		mov ebx, 7
		topSun:
		cmp ebx, 1
		jl endSun

			push ebx

		dec ebx
		jmp topSun
		endSun:

		push SunMonth
		call printf

		mov ebx, 8
		mov edi, 0
		topSun2:
		cmp ebx, dword[ebp-4]
		jg endSun2

			inc edi
			cmp edi, 7
			jl nlSun

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goSun

			nlSun:
			push ebx
			push MoreMonth
			call printf
			goSun:

		inc ebx
		jmp topSun2
		endSun2:

		jmp end

	notSun:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	cmp ecx, Mon
	jne notMon

		mov ebx, 6
		topMon:
		cmp ebx, 1
		jl endMon

			push ebx

		dec ebx
		jmp topMon
		endMon:

		push MonMonth
		call printf

		mov ebx, 7
		mov edi, 0
		topMon2:
		cmp ebx, dword[ebp-4]
		jg endMon2

			inc edi
			cmp edi, 7
			jl nlMon

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goMon

			nlMon:
			push ebx
			push MoreMonth
			call printf
			goMon:

		inc ebx
		jmp topMon2
		endMon2:

		jmp end

	notMon:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	cmp ecx, Tue
	jne notTue

		mov ebx, 5
		topTue:
		cmp ebx, 1
		jl endTue

			push ebx

		dec ebx
		jmp topTue
		endTue:

		push TueMonth
		call printf

		mov ebx, 6
		mov edi, 0
		topTue2:
		cmp ebx, dword[ebp-4]
		jg endTue2

			inc edi
			cmp edi, 7
			jl nlTue

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goTue

			nlTue:
			push ebx
			push MoreMonth
			call printf
			goTue:

		inc ebx
		jmp topTue2
		endTue2:

		jmp end

	notTue:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	cmp ecx, Wed
	jne notWed

		mov ebx, 4
		topWed:
		cmp ebx, 1
		jl endWed

			push ebx

		dec ebx
		jmp topWed
		endWed:

		push WedMonth
		call printf

		mov ebx, 5
		mov edi, 0
		topWed2:
		cmp ebx, dword[ebp-4]
		jg endWed2

			inc edi
			cmp edi, 7
			jl nlWed

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goWed

			nlWed:
			push ebx
			push MoreMonth
			call printf
			goWed:

		inc ebx
		jmp topWed2
		endWed2:

		jmp end

	notWed:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	cmp ecx, Thu
	jne notThu

		mov ebx, 3
		topThu:
		cmp ebx, 1
		jl endThu

			push ebx

		dec ebx
		jmp topThu
		endThu:

		push ThuMonth
		call printf

		mov ebx, 4
		mov edi, 0
		topThu2:
		cmp ebx, dword[ebp-4]
		jg endThu2


			inc edi
			cmp edi, 7
			jl nlThu

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goThu

			nlThu:
			push ebx
			push MoreMonth
			call printf
			goThu:

		inc ebx
		jmp topThu2
		endThu2:

		jmp end

	notThu:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	cmp ecx, Fri
	jne notFri

		mov ebx, 2
		topFri:
		cmp ebx, 1
		jl endFri

			push ebx

		dec ebx
		jmp topFri
		endFri:

		push FriMonth
		call printf

		mov ebx, 3
		mov edi, 0
		topFri2:
		cmp ebx, dword[ebp-4]
		jg endFri2


			inc edi
			cmp edi, 7
			jl nlFri

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goFri

			nlFri:
			push ebx
			push MoreMonth
			call printf
			goFri:

		inc ebx
		jmp topFri2
		endFri2:

		jmp end

	notFri:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	cmp ecx, Sat
	jne notSat

		mov ebx, 1
		topSat:
		cmp ebx, 1
		jl endSat

			push ebx

		dec ebx
		jmp topSat
		endSat:

		push SatMonth
		call printf

		mov ebx, 2
		mov edi, 0
		topSat2:
		cmp ebx, dword[ebp-4]
		jg endSat2

			inc edi
			cmp edi, 7
			jl nlSat

				mov edi, 0
				push ebx
				push MoreMonthNL
				call printf
				jmp goSat

			nlSat:
			push ebx
			push MoreMonth
			call printf
			goSat:

		inc ebx
		jmp topSat2
		endSat2:

		jmp end

	notSat:
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	end:

	call print_nl
	call print_nl

	;-----------------------------
	;done printing calender!
	;now onto printing the events!
	;-----------------------------

	mov eax, dword[timeinfo]
	mov eax, dword[eax + tm_mon]
    mov ecx, dword[Month + 4 * eax]

	cmp ecx, Jan
	jne notJan3

		push dword[ebp-4]
		push JanFile
		call printEvents

	notJan3:
	cmp ecx, Feb
	jne notFeb3

		push dword[ebp-4]
		push FebFile
		call printEvents

	notFeb3:
	cmp ecx, Mar
	jne notMar3

		push dword[ebp-4]
		push MarFile
		call printEvents

	notMar3:
	cmp ecx, Apr
	jne notApr3

		push dword[ebp-4]
		push AprFile
		call printEvents

	notApr3:
	cmp ecx, May
	jne notMay3

		push dword[ebp-4]
		push MayFile
		call printEvents

	notMay3:
	cmp ecx, Jun
	jne notJun3

		push dword[ebp-4]
		push JunFile
		call printEvents

	notJun3:
	cmp ecx, Jul
	jne notJul3

		push dword[ebp-4]
		push JulFile
		call printEvents

	notJul3:
	cmp ecx, Aug
	jne notAug3

		push dword[ebp-4]
		push AugFile
		call printEvents

	notAug3:
	cmp ecx, Sep
	jne notSep3

		push dword[ebp-4]
		push SepFile
		call printEvents

	notSep3:
	cmp ecx, Oct
	jne notOct3

		push dword[ebp-4]
		push OctFile
		call printEvents

	notOct3:
	cmp ecx, Nov
	jne notNov3

		push dword[ebp-4]
		push NovFile
		call printEvents

	notNov3:
	cmp ecx, Decm
	jne notDec3

		push dword[ebp-4]
		push DecFile
		call printEvents

	notDec3:

	call print_nl

	mov esp, ebp
	pop ebp
	ret


printEvents:
    push    ebp
    mov     ebp, esp

	mov ebx, 1
	mov edx, 1

	push mode_r
	push dword[ebp+8];AprFile
	call fopen
	add esp, 8
	mov edi, eax

	top:

	cmp ebx, dword[ebp+12]
	jg done

	push lineint
	push fmtint
	push edi
	call fscanf
	add esp, 12

	cmp eax, -1
	je else

	cmp ebx, dword[lineint]
	jne notentry

		push linestring
		push fmtstring
		push edi
		call fscanf
		add esp, 12
		mov eax, dword[linestring]

		push dword[lineint]
		push fmtentryint
		call printf

		mov edx, 0
		writeloop:

		 	cmp byte[linestring + edx * 1], '_'
			jne cont

				mov al,  ' '
				call print_char
				inc edx
				jmp writeloop

			cont:

			cmp byte[linestring + edx * 1], 0
			je endwrite

			mov al, byte[linestring + edx * 1]
			call print_char

		inc edx
		jmp writeloop
		endwrite:

		call print_nl

		else:

		push edi
		call fclose
		add esp, 4

		push mode_r
		push dword[ebp+8];File
		call fopen
		add esp, 8
		mov edi, eax

		inc ebx
		jmp top

	notentry:

	push linestring
	push fmtstring
	push edi
	call fscanf
	add esp, 12
	mov eax, dword[linestring]

	push edi
	call fgetc
	add esp, 4

	jmp top

	done:

    mov     esp, ebp
    pop     ebp
    ret

makeEvent:
    push    ebp
    mov     ebp, esp

	push mode_a
	push dword[ebp+8]
	call fopen
	add esp, 8
	mov edi, eax

	push linestring
	push ebx
	push fmtentry
	push edi
	call fprintf
    add esp, 16

	call print_nl

    mov     esp, ebp
    pop     ebp
    ret

removeEvent:
    push    ebp
    mov     ebp, esp

	sub esp, 4

	push mode_w
	push TmpFile
	call fopen
	add esp, 8
	mov dword[ebp-4], eax

	push mode_r
	push dword[ebp+8]
	call fopen
	add esp, 8
	mov edi, eax

	topo:

	push lineint
	push fmtint
	push edi
	call fscanf
	add esp, 12

	mov ebx, dword[lineint]
	cmp ebx, dword[ebp+12]
	je found

		push linestring
		push fmtstring
		push edi
		call fscanf
		add esp, 12
		mov eax, dword[linestring]

		push edi
		call fgetc
		add esp, 4

        cmp eax, -1
		je elses

		push linestring
		push dword[lineint]
		push fmtentry
		push dword[ebp-4]
		call fprintf
	 	add esp, 16

		jmp topo

	found:

	push linestring
	push fmtstring
	push edi
	call fscanf
	add esp, 12
	mov eax, dword[linestring]

	push edi
	call fgetc
	add esp, 4

    cmp eax, -1
	je elses


	jmp topo


	elses:

	push dword[ebp-4]
	call fclose
	add esp, 4

	push edi
	call fclose
	add esp, 4


;now to move the contents of tmp to month

	push mode_r
	push TmpFile
	call fopen
	add esp, 8
	mov dword[ebp-4], eax

	push mode_w
	push dword[ebp+8]
	call fopen
	add esp, 8
	mov edi, eax


	topcopy:

	push lineint
	push fmtint
	push dword[ebp-4]
	call fscanf
	add esp, 12

	push linestring
	push fmtstring
	push dword[ebp-4]
	call fscanf
	add esp, 12
	mov eax, dword[linestring]

	push dword[ebp-4]
	call fgetc
	add esp, 4

    cmp eax, -1
	je exitcopy

	push linestring
	push dword[lineint]
	push fmtentry
	push edi
	call fprintf
 	add esp, 16


	jmp topcopy

	exitcopy:

	push dword[ebp-4]
	call fclose
	add esp, 4

	push edi
	call fclose
	add esp, 4





    mov     esp, ebp
    pop     ebp
    ret
