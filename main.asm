TITLE Assembly Language Maze		(main.asm)

; Author: Matthew McGrath
; Description: This program implements a Maze-type game.
; July 25th, 2008

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Global Constants.
;****************************************************************************
TIME_LIMIT = 90000			; Time Limit to escape maze (in ms)
ROW_SIZE = 36				; Size of a row in the maze.
COLUMN_SIZE = 22			; Size of a column in the maze.

; Defines for Movement.
UP		= 'w'				; w moves the player Up.
RIGHT	= 'd'				; d moves the player Right.
DOWN	= 's'				; s moves the player Down.
LEFT	= 'a'				; a moves the player Left.
;****************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLAYER STRUCTURE 
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Player STRUCT	
	aName		BYTE 30 DUP(0)		; Stores player's name.
	Position	COORD <0, 0>		; Stores current x and y position.
	Direction 	WORD 0				; Stores direction player wants to move.
	Score		WORD 0				; Stores the player's current score.
	Picture		BYTE "O"			; The ASCII used to represent the player.
	Speed		WORD 1				; Player's speed (moves per second)
	NumMoves	WORD 0				; Number of spaces the player has moved.
Player ENDS	
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

; Uninitialized blocks of data declared here.
.data?
	startTime DWORD ?
	ascii	BYTE  ?
	scan		BYTE  ?
	
.data
	playerName			BYTE "Name of Trapped Player: ", 0
	timeRemaining		BYTE "Seconds Left to Escape: ", 0
	currentScore		BYTE "Bonus Points Collected: ", 0
	currentNumMoves		BYTE "Number of  Moves  Made: ", 0
	timeExpiredString	BYTE "Time Expired", 0
	thePlayer			Player <>
	newRow				WORD	0
	newCol				WORD	0
	timeTaken			DWORD	0
	timeBonus			DWORD	0
	highScore			DWORD	0
	lastScore			DWORD	0
	
	; Variables used for I/O to / from a file.
	fileName		BYTE		"highScores.txt", 0
	fileHandle		HANDLE		?
	buffer			BYTE		10 DUP(0)
	totalScore		WORD 		10 DUP(0)
	
	; Stores the contents of the maze in an array.
	mazeArray	BYTE 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X',			'X', 'X', 'X', 'X', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', 'X', 'X', '#', 'X', 'X', 'X', 'X', ' ', ' ', ' ', 'X', '#', ' ', ' ', ' ', ' ', 'X',			' ', ' ', ' ', ' ', '#', 'X'
			BYTE 'X', 'X', 'X', '#', ' ', ' ', ' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'X', ' ', 'X', ' ', 'X', 'X', 'X', ' ', 'X',			' ', 'X', 'X', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', ' ', ' ', 'X', ' ', ' ', 'X',			' ', ' ', ' ', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', ' ', ' ', ' ', ' ', 'X', 'X', 'X', 'X', 'X', ' ', ' ', '%', ' ', ' ', ' ', 'X', 'X', 'X', 'X', ' ', 'X', 'X', ' ', 'X', ' ', 'X', 'X',			'X', 'X', ' ', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', ' ', '#', 'X', 'X', '#', 'X', 'X', 'X', 'X', ' ', ' ', ' ', '#', 'X', ' ', 'X', ' ', ' ', 'X', ' ', ' ', ' ',			' ', 'X', ' ', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', ' ', ' ', 'X', 'X', 'X', 'X', 'X',			' ', 'X', ' ', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', '%', '%', '%', 'X',			' ', ' ', ' ', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', ' ', ' ', '#', ' ', ' ', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X',			'X', 'X', 'X', 'X', ' ', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', ' ', ' ', '#', ' ', ' ', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', '%', 'X', 'X', 'X', 'X', 'X', ' ', ' ', 'X', 'X', '%', ' ',			' ', ' ', ' ', ' ', ' ', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', '#', 'X', 'X', 'X', '#', 'X', 'X', 'X', 'X', ' ', ' ', ' ', ' ', ' ', 'X', ' ', 'X', 'X', 'X', 'X', 'X',			'X', 'X', 'X', 'X', ' ', 'X'

			BYTE 'X', ' ', '%', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', 'X', ' ', ' ', ' ', ' ', ' ', ' ',			' ', 'X', ' ', ' ', '#', 'X'
			BYTE 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', ' ', ' ', 'X', 'X', 'X', 'X', 'X',			' ', 'X', ' ', 'X', ' ', 'X'
			BYTE 'X', 'X', ' ', ' ', ' ', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ',			' ', 'X', ' ', 'X', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '%', 'X', ' ', 'X', ' ',			'X', 'X', ' ', ' ', ' ', ' '
			BYTE 'X', 'X', 'X', 'X', ' ', ' ', ' ', ' ', ' ', '#', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', ' ',			'X', 'X', 'X', 'X', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', '#', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', ' ', ' ', ' ', 'X', ' ', ' ', ' ', ' ', ' ', ' ',			'X', ' ', ' ', ' ', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', ' ', ' ', ' ', ' ', 'X', 'X', 'X', '#', 'X', ' ', ' ', 'X', ' ', ' ', ' ', 'X', 'X', 'X', 'X', ' ',			' ', ' ', 'X', ' ', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', ' ', ' ', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X',			'X', 'X', 'X', '%', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X',			'X', 'X', 'X', 'X', 'X', 'X'
			BYTE ' ', ' ', ' ', '#', ' ', ' ', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '#', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X',			'X', 'X', 'X', 'X', 'X', 'X'
			BYTE 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X',			'X', 'X', 'X', 'X', 'X', 'X'
	
	; Variables used to make menu decisions.
	menuChoice			WORD ?
	textColorChoice		WORD ?
	bgColorChoice		WORD ?
	
	; String variables used to draw ASCII-based menus to the console window.
	
	menuStr	BYTE "-------------------------------------------------------------------------------", 0dh, 0ah
			BYTE "---------------- W E L C O M E   T O   M A Z E   E S C A P E  ! ---------------", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXX   M A I N    M E N U    XXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXX       Please Select An Option:                                        XXXX", 0dh, 0ah
			BYTE "XXXX           1) Play Maze Escape                                         XXXX", 0dh, 0ah
			BYTE "XXXX           2) Help Screen                                              XXXX", 0dh, 0ah
			BYTE "XXXX           3) Options Menu                                             XXXX", 0dh, 0ah
			BYTE "XXXX           4) Exit Game                                                XXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah, 0
			
	helpStr	BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXX   H E L P    M E N U    XXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXX       OBJECTIVE:                                                      XXXX", 0dh, 0ah
			BYTE "XXXX           Your objective in Maze Escape is to find your way out       XXXX", 0dh, 0ah
			BYTE "XXXX            of the maze before time expires. Meanwhile, collecting     XXXX", 0dh, 0ah
			BYTE "XXXX            Bonus Items to boost your score. Your final score will     XXXX", 0dh, 0ah
			BYTE "XXXX            take both your raw score and the amount of time you        XXXX", 0dh, 0ah
			BYTE "XXXX            took to escape the maze into consideration.                XXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXX       MOVEMENT CONTROLS:                                              XXXX", 0dh, 0ah
			BYTE "XXXX           Left	a                                                  XXXX", 0dh, 0ah
			BYTE "XXXX           Right	d                                                  XXXX", 0dh, 0ah
			BYTE "XXXX           Up       w                                                  XXXX", 0dh, 0ah
			BYTE "XXXX           Down	s                                                  XXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXX       COLLECTABLE ITEMS:                                              XXXX", 0dh, 0ah
			BYTE "XXXX           +10 pts  # (Colored Red)                                    XXXX", 0dh, 0ah
			BYTE "XXXX           +20 pts  % (Colored Green)                                  XXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah, 0
			
	OptionStr	BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXX   O P T I O N    M E N U    XXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXX   COLOR OPTIONS:                                                      XXXX", 0dh, 0ah
			BYTE "XXXX      0) Black   4) Red           8) Gray          12) Light Red       XXXX", 0dh, 0ah
			BYTE "XXXX      1) Blue    5) Magenta       9) Light Blue    13) Light Magenta   XXXX", 0dh, 0ah
			BYTE "XXXX      2) Green   6) Brown        10) Light Green   14) Yellow          XXXX", 0dh, 0ah
			BYTE "XXXX      3) Cyan    7) Light Gray   11) Light Cyan    15) White           XXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah, 0
			
	txtClrStr	BYTE " Choose the color you want your menu text to appear in (Enter 0-15): ", 0dh, 0ah, 0
	
	bgClrStr	BYTE "Choose the color you want your background to appear in (Enter 0-15): ", 0dh, 0ah, 0
			
	enterNameStr	BYTE "Please enter your name, then press [Enter] to begin: ", 0
	
	scoreStr	BYTE "-------------------------------------------------------------------------------", 0dh, 0ah
			BYTE "---------------Y O U   H A V E   E S C A P E D   T H E   M A Z E---------------", 0dh, 0ah, 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXX  P  L  A  Y  E  R ' S      S  C  O  R  E  XXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "Score from Bonus Pick-Ups:	", 0dh, 0ah
			BYTE "Time Bonus:				", 0dh, 0ah
			BYTE "                               X__________	", 0dh, 0ah
			BYTE "TOTAL SCORE:							", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah
			BYTE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0dh, 0ah, 0
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Read Player's Score from a File         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ReadHighScoreFile MACRO
; Open the file for input
	mov edx, OFFSET fileName
	call OpenInputFile
	mov fileHandle, eax

file_ok:
	mov edx, OFFSET buffer
	mov ecx, 10
	call ReadFromFile

; Display contents of file (previous score).
	mWrite <"Your Previous Score: ">
	mov edx, OFFSET buffer
	call WriteString
	
close_file:
	mov eax, fileHandle
	call CloseFile
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Write Player's Score to a File          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
SaveHighScore MACRO theHighScore

	; This lengthy block of code converts an integer read from a memory operand
	;  into a string that can be properly written to highScores.txt
	;-----------------------------------------------------------------------------------
	mov dx, 0
	mov ax, theHighScore	
	mov cx, 1000
	div cx				; AX stores digit in 1,000's place.

	; Convert the 1,000's digit to its string value; store it.
	mov esi, 0
	add al, 48
	mov buffer[esi], al
	
	mov bx, dx
	mov dx, 0
	mov ax, bx
	mov cx, 100
	div cx				; AX stores digit in 100's place

	
	; Convert the 100's digit to its string value; store it.
	add al, 48
	mov esi, 1
	mov buffer[esi], al
	
	mov bx, dx
	mov dx, 0
	mov ax, bx
	mov cx, 10
	div cx				; AX stores digit in 10's place.
	
	; Convert the 10's digit to its string value; store it.
	add al, 48
	mov esi, 2
	mov buffer[esi], al
	
	mov bx, dx
	mov dx, 0
	mov ax, bx
	mov cx, 1
	div cx				; AX stores digit in 1's place.
	
	; Convert the 1's digit to its string value; store it.	
	add al, 48
	mov esi, 3
	mov buffer[esi], al
	;-----------------------------------------------------------------------------------
	
	; This block of code does the actual creation of the text file / writing to it.
	;-----------------------------------------------------------------------------------		
	mov edx, OFFSET fileName			; Store the offset of the filename.
	call CreateOutputFile			; Create the text file for output.
	mov fileHandle, eax				; Store EAX into the file handle.
	
	mov eax, fileHandle
	mov edx, OFFSET buffer			; Store the offset of the buffer.
	mov ecx, 10
	call WriteToFile				; Write the buffer to the text file.
	call CloseFile					; Close the file since it's no longer needed.
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;              The Main Menu                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MainMenu MACRO
	; Display the main menu ASCII art.
	DisplayMenuString: 
		call Clrscr
		mov edx, OFFSET menuStr
		call WriteString

	; Grab the user's menu decision.
	ReadMenuChoice:
		mReadInt menuChoice
	
		; Player selects "Play Game". Have him enter his name.
		.IF menuChoice == 1
			EnterName
			
		; Player selects Help Menu.
		.ELSEIF menuChoice == 2
			call Clrscr
			mov edx, OFFSET helpStr
			call WriteString			; Display Help Menu string.
			call WaitMsg
			jmp DisplayMenuString		; Jump back to main menu.
			
		; Player selects Options.
		.ELSEIF menuChoice == 3
			call Clrscr
			mov edx, OFFSET optionStr
			call WriteString			; Display Option menu string.
			
			mov edx, OFFSET txtClrStr	
			call WriteString			; Display list of colors.
			mReadInt textColorChoice		; Grab user's choice for text color.
			
			mov edx, OFFSET bgClrStr
			call WriteString			
			mReadInt bgColorChoice		; Grab user's choice for bg color.
			
			; Set console colors based on input made above.
			; Text color is EAX = foregroundColor + (16 * bgColor).
			mov ax, 16
			mov bx, bgColorChoice
			mul bx				
			add ax, textColorChoice
			call SetTextColor
			jmp DisplayMenuString	; Jump back to main menu.
		
		; Player selects Quit.
		.ELSEIF menuChoice == 4
			exit
		.ENDIF
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Retrieving Player's Name               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
EnterName MACRO
	mov edx, OFFSET enterNameStr
	call WriteString

	mov edx, OFFSET thePlayer.aName	
	mov ecx, 30
	call ReadString
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      MazeArray[row][col] = character Macro     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FillChar MACRO rowindex, colindex, character
	mov ax, rowindex
	mov bx, ROW_SIZE
	mul bx					;; Result in AX
	movsx esi, ax
	mov ebx, OFFSET mazeArray
	add ebx, esi
	mov esi, colindex
	mov BYTE PTR [ebx + esi], character
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Initialize Player Struct Attributes       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
InitPlayer MACRO
	mov thePlayer.NumMoves, 0
	mov thePlayer.Position.X, 0
	mov thePlayer.Position.Y, 20
	mov thePlayer.Direction, DOWN
	mov thePlayer.Score, 0
	FillChar 20, 0, 'O'
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                Move Player Macro               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MovePlayer MACRO
; MovePlayer
	mMove32 thePlayer.Position.Y, newRow
	mMove32 thePlayer.Position.X, newCol
	
	; Move into correct array index based on direction given by user.
	;-----------------------------------------------------------------------------------
	mReadkey 0, ascii, scan		; Read key pressed.
	movsx ax, ascii			; Store the ASCII code in ax.
	
	; Set the player's direction based on user input.
	mov thePlayer.Direction, ax
	
	; If player wants to move UP...
	movsx ebx, thePlayer.direction
	.IF ebx == UP
		mov dx, thePlayer.Position.Y
		dec dx
		mov newRow, dx
	
	; If the player wants to move RIGHT...
	movsx ebx, thePlayer.Direction
	.ELSEIF ebx == RIGHT
		mov dx, newCol
		inc dx
		mov newCol, dx
	
	; If the player wants to move DOWN...
	movsx ebx, thePlayer.Direction
	.ELSEIF ebx == DOWN
		mov dx, thePlayer.Position.Y
		inc dx
		mov newRow, dx
	
	; If the player wants to move LEFT...
	movsx ebx, thePlayer.Direction
	.ELSEIF ebx == LEFT
		mov dx, thePlayer.Position.X
		dec dx
		mov newCol, dx
	
	; No key was pressed this turn; jump to Dont Move
	.ELSE
		jmp DontMove
	.ENDIF
	;-----------------------------------------------------------------------------------

	; Determine what type of space the player is attempting to enter.
	;-----------------------------------------------------------------------------------
	mov ax, newRow
	mov bx, ROW_SIZE
	mul bx
	movsx esi, ax
	mov ebx, OFFSET mazeArray
	add ebx, esi
	movsx esi, newCol
	movsx eax, BYTE PTR [ebx + esi]
	
	; Determine if the player attempts to move into a wall.
	mov ebx, 'X'
	.IF eax == ebx
		jmp DontMove
		call WaitMsg
	.ENDIF
		
	; Determine if the player attempts to move into a space with a Score Bonus + 10
	mov ebx, '#'
	.IF eax == ebx
		mov cx, thePlayer.Score
		add cx, 10
		mov thePlayer.Score, cx
	.ENDIF

	; Determine if the player attemots to move into a space with a Score Bonus + 20
	mov ebx, '%'
	.IF eax == ebx
		mov cx, thePlayer.Score
		add cx, 20
		mov thePlayer.Score, cx
	.ENDIF
	;-----------------------------------------------------------------------------------
	
	; Draw the player's Avatar's appearance in the new space.
	;-----------------------------------------------------------------------------------
	; Draw the "player was here" symbol ("V") in the previous maze location.
	; C++ representation of this code: mazeArray[player.y][player.x] = ' '
	mov ax, thePlayer.Position.Y
	mov bx, ROW_SIZE
	mul bx					; Result in AX
	movsx esi, ax
	mov ebx, OFFSET mazeArray
	add ebx, esi
	movsx esi, thePlayer.Position.X
	mov BYTE PTR [ebx + esi], ' '
	
	; Draw the player symbol ("O") in the new maze location.
	; C++ representation of this code: mazeArray[newRow][newColumn] = 'O'
	mov ax, newRow
	mov bx, ROW_SIZE
	mul bx
	movsx esi, ax
	mov ebx, OFFSET mazeArray
	add ebx, esi
	movsx esi, newCol
	mov BYTE PTR [ebx + esi], 'O'
	
	; The player's position is now equal to newRow and newCol.
	; C++ representation of this code: player.position.X = newCol, player.position.y = newRow
	mMove32 newRow, thePlayer.Position.Y
	mMove32 newCol, thePlayer.Position.X
	
	mov bx, thePlayer.NumMoves
	inc bx
	mov thePlayer.NumMoves, bx
	
	; Jump to this label to bypass code if there's a wall in the way.
	DontMove:
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prints the maze in appropriate coloring.
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
PrintMaze MACRO
	lea esi, mazeArray			; Offset of the Maze Array.
	mov ecx, 792				; The number of elements in the maze.
	mov edx, ROW_SIZE			; Our row length. Needed for proper line formatting.
	
PrintLoop:
	mov al, BYTE PTR [esi]		; Store the current maze array character in al.
	mov bl, al
	
	push eax					; Preserve EAX's value for , since SetTextColor alters it.
	push edx
	
	; Determine what type of object the current maze array character is; color it appropriately.
	;-----------------------------------------------------------------------------------
	; If the object is a +10 point Bonus item...
	.IF al == '#'				
		mov eax, 16
		mov bx, bgColorChoice	; Color the background the user's choice.
		mul bx
		add ax, lightRed		; Color the foreground red.
		
	; If the object is a +20 point Bonus item...
	.ELSEIF al == '%'			
			;mov eax, lightGreen	
		mov eax, 16
		movzx ebx, bgColorChoice
		mul ebx			
		add eax, lightGreen		; Color the foreground green.
		
	; If the object is the Player's avatar...
	.ELSEIF al == 'O'			
		mov eax, 16
		movzx ebx, bgColorChoice
		mul ebx
		add eax, white			; Color the foreground white.
		
	; Else the object must be a wall...
	.ELSE
		mov eax, 16
		movzx ebx, bgColorChoice
		mul ebx
		add eax, yellow		; Color the foreground yellow.
	.ENDIF
	
	call SetTextColor
	;-----------------------------------------------------------------------------------
	
	pop edx
	
	; This block of code does the actual printing of characters to the screen.
	;-----------------------------------------------------------------------------------
	; If our EDX counter (used for line formatting) reaches 0...
	.IF edx == 0
		call Crlf			; Move cursor to the next line.
		mov edx, ROW_SIZE	; Restore EDX counter to row's length.
	.ENDIF
	
	dec edx				; Decrease our EDX counter.
	pop eax				
	call WriteChar			; Print the current maze array element.
	inc esi				; Point to next maze array element.
	loop PrintLoop			; Repeat until ECX = 0.
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

PrintMaze2 MACRO
	
	lea esi, mazeArray			; Offset of the Maze Array.
	mov ecx, 792				; The number of elements in the maze.
	mov edx, ROW_SIZE			; Our row length. Needed for proper line formatting.
	mov dh, 0
	mov dl, 0

	aLoop:
		mov al, BYTE PTR [esi]		; Store the current maze array character in al.
	
		push eax					; Preserve EAX's value for , since SetTextColor alters it.
		push edx
		
		; Determine what type of object the current maze array character is; color it appropriately.
		;-----------------------------------------------------------------------------------
		; If the object is a +10 point Bonus item...
		.IF al == '#'				
			mov eax, 16
			mov bx, bgColorChoice	; Color the background the user's choice.
			mul bx
			add ax, lightRed		; Color the foreground red.
			
		; If the object is a +20 point Bonus item...
		.ELSEIF al == '%'			
				;mov eax, lightGreen	
			mov eax, 16
			movzx ebx, bgColorChoice
			mul ebx			
			add eax, lightGreen		; Color the foreground green.
			
		; If the object is the Player's avatar...
		.ELSEIF al == 'O'			
			mov eax, 16
			movzx ebx, bgColorChoice
			mul ebx
			add eax, white			; Color the foreground white.
			
		; Else the object must be a wall...
		.ELSE
			mov eax, 16
			movzx ebx, bgColorChoice
			mul ebx
			add eax, yellow		; Color the foreground yellow.
		.ENDIF
		
		call SetTextColor
		;-----------------------------------------------------------------------------------
		
		pop edx
		
		.IF dl == ROW_SIZE
			call Crlf
			inc dh
			mov dl, 0
		.ENDIF
		
		call Gotoxy
		pop eax
		call WriteChar
		inc esi
		inc dl
	loop aLoop
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mMove32 macro
; This macro essentially provides an easy
; way to move a memory operand into another,
; thereby skipping the intermediate move into
; a register.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
mMove32 MACRO source, destination
	;IFDIFI %(TYPE destination), <4>
	;	ECHO ERROR: Destination must be 32-bits.
	;	EXITM
	;ENDIF
	
	;IFDIFI %(TYPE destination), <4>
	;	ECHO ERROR: Source must be 32-bits.
	;	EXITM
	;ENDIF
	
	mov ax, source
	mov destination, ax
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mReadkey macro for Exercise 1 
; Input: miliseconds to delay keyboard reading,
; storage to hold ascii code / keyboard scan code.
; Output: Par1 stores ascii code, Par2 kb code.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
mReadkey MACRO delayPeriod, par1, par2
	mov eax, delayPeriod
	call Delay
	call ReadKey

	mov par1, al
	mov par2, ah
ENDM
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mReadInt macro for Exercise 5
; Input: 16-bit or 32-bit memory operand.
; Output: The 16-bit or 32-bit memory operand
;         store an integer retrieved from user.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*************************************************
mReadInt MACRO intReadSource
	IFIDNI %(TYPE intReadSource), <4>
	call ReadInt
	mov intReadSource, eax
	ENDIF
	
	IFIDNI %(TYPE intReadSource), <2>
	call ReadInt
	mov intReadSource, ax
	ENDIF
ENDM
;*************************************************


.code
main PROC

; This block of code sets the initial screen colors and calls the MainMenu macro.
;-----------------------------------------------------------------------------------
MenuPhase:
	; We manually set the color at the start of the game in case the player
	; selects a color combination that is unreadable via Options.
	mov eax, 9				; Store the color we want the menu to appear in.
	call SetTextColor			; Set the text color.
	
	; Display the main menu.
	MainMenu


; This block of code initializes the timer and player for the maze game.
;-----------------------------------------------------------------------------------
InitializationPhase:  
	INVOKE GetTickCount			; Get the current time to track elapsed time.
	mov startTime,eax			; The current time is the time the game started.
	
	InitPlayer				; INITIALIZE THE PLAYER
	
	
; This block of code handles in-game logic in a loop.
;-----------------------------------------------------------------------------------------------------------
; GameLoop repeats until TIME_LIMIT runs out or the player escapes the maze.	
call Clrscr
GameLoop:
	;call Clrscr
	
	; Exit to the EscapedMaze label if the player reaches exit position.
	movsx ecx, thePlayer.Position.Y
	movsx edx, thePlayer.Position.X
	
	.IF ecx == 14 && edx == 35
		jmp EscapedMaze
	.ENDIF
	
	MovePlayer				; Move Player
	PrintMaze2					; Print the maze with appropriate colors.
	
	RenderInterface:
	; This block of code prints the player's name to the screen.
	;-----------------------------------------------------------------------------------
	call Crlf
	; Move the cursor and write the player's name. 
	mov dh, 15				; Move cursor to 15th row.
	mov dl, 40				; Move cursor to 40th column.
	call Gotoxy
	mov edx, OFFSET playerName
	call WriteString
	mov edx, OFFSET thePlayer.aName
	call WriteString
	call Crlf
	
	; This block of code prints the time remaining to the screen.
	;-----------------------------------------------------------------------------------
	; Move the cursor and write the player's score from bonus items.
	mov dh, 16				; Move cursor to 16th row.
	mov dl, 40				; Move cursor to 40th column.
	call Gotoxy
	mov edx, OFFSET timeRemaining ; EDX stores offset to timeRemaining string.
	call WriteString			; Display "Time Remaining: " string.
	INVOKE GetTickCount			; Get the current time.
	sub eax, startTime			; Stores elapsed time.
	mov timeTaken, eax
	
	mov ebx, eax				; EBX Stores elapsed time as well.
	mov eax, TIME_LIMIT			; Stores TIME_LIMIT amount of seconds		
	sub eax, ebx				; Subtract elapsed time to get time remaining.
	
	; Divide time remaining by 1,000 for clean, second-only output.
	mov edx, 0
	mov eax, eax
	mov ecx, 1000
	div ecx
	call WriteDec				; Displays the time remaining.
	;-----------------------------------------------------------------------------------
	
	; This block of code prints the player's current score.
	;-----------------------------------------------------------------------------------
	call Crlf
	
	; Move the cursor and write the player's score from bonus items.
	mov dh, 17				; Move the cursor to the 17th row.
	mov dl, 40				; Move the cursor to the 40th column.
	call Gotoxy
	mov edx, OFFSET currentScore
	call WriteString
	movsx eax, thePlayer.Score
	call WriteDec
	;-----------------------------------------------------------------------------------
	
	; This block of code prints the player's number of moves made.
	;-----------------------------------------------------------------------------------
	call Crlf
	; Move the cursor and write the player's score from bonus items.
	mov dh, 18				; Move the cursor to the 18th row.
	mov dl, 40				; Move the cursor to the 40th column.
	call Gotoxy
	mov edx, OFFSET currentNumMoves
	call WriteString
	movsx eax, thePlayer.NumMoves
	call WriteDec
	;-----------------------------------------------------------------------------------
	
	; Regulate the frame rate (4 frames / moves per second).
	INVOKE Sleep, 250			; Sleep for 0.25 seconds

	; Repeat GameLoop if time has not expired.
	INVOKE GetTickCount			; Get the current time.
	sub  eax, startTime			; Check the elapsed time
	cmp  eax, TIME_LIMIT		; Compare elapsed time to time limit.
	jb   GameLoop				; Repeat GameLoop if time limit is not up.
;-----------------------------------------------------------------------------------------------------------
; End of GameLoop has been reached due to time expiration or successful escape.
	

; TimeExpired label is reached if time has expired before exit is reached.
;-----------------------------------------------------------------------------------
TimeExpired:
	call Clrscr
	mov edx, OFFSET timeExpiredString
	call WriteString
	Invoke Sleep, 5000
	call Crlf
	call Crlf
	call WaitMsg
	call Clrscr
	jmp MenuPhase				; Jump back to Main Menu.


; EscapedMaze label is reached if the player reaches the exit before time expires.
;-----------------------------------------------------------------------------------
EscapedMaze:
	call Clrscr
	mov edx, OFFSET scoreStr
	call WriteString			; Display the "SCORE" string.
	
	; Move the cursor and write the player's score from bonus items.
	mov dh, 8					; Move cursor to 8th row.
	mov dl, 34				; Move cursor to 34th column.
	call Gotoxy
	movsx eax, thePlayer.Score	; Store the player's score in EAX.
	call WriteDec				; Write the score without leading signs.
	
	; Move the cursor and write the time remaining.
	mov dh, 9					; Move the cursor to the 9th row.
	mov dl, 34				; Move the cursor to the 34th column.
	call Gotoxy
	mov eax, TIME_LIMIT			; Store TIME_LIMIT in EAX.
	
	sub eax, timeTaken			; Find difference between timeTaken and TIME_LIMIT.
	
		
	; Divide time remaining by 1,000 for clean, second-only output.
	mov edx, 0
	mov ecx, 1000
	div ecx
	mov timeBonus, eax			; The time bonus is the time difference in seconds.
	call WriteDec				; Displays the time bonus.
	
	; Move cursor in preparation for writing the TOTAL SCORE.
	mov dh, 11				; Move cursor to 11th row.
	mov dl, 34				; Move cursor to 34th column.
	call Gotoxy
	
	; Calculate TOTAL SCORE.
	mov eax, timeBonus			; Multiplication operand 1
	mov bx, thePlayer.Score		; Multiplication operand 2
	mul bx					; EAX = timeBonus x thePlayer.Score
	mov totalScore, ax			; Total Score = timeBonus x thePlayer.score
	call WriteDec				; Displays the TOTAL SCORE.
	
	; Read the "high score" (player's last score) from the file.
	mov dh, 14
	mov dl, 34
	call Gotoxy
	ReadHighScoreFile
	
	; Save the high score to highScore.txt file.
	SaveHighScore totalScore
	
	; Sleep so the user cannot exit game until he has observed score.
	INVOKE Sleep, 8000
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call Crlf
	call WaitMsg
	call Clrscr
	jmp MenuPhase				; Jump back to Main Menu.

	exit
main ENDP
END main