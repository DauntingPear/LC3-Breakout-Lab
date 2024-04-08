.orig x3000

START ;; CLEAR THE SCREENLD R5,VIDEO ; R5 is the pointer to the where the pixels will be written to the displayLD R7,BLACK ; Black pixel valueLD R3,DISPSIZE ; The size of the entire frame buffer (We are going to write the; value of BLACK in the entire frame buffer)

LOOP0 STR R7,R5,#0 ; In this loop, we are storing the pixel in the appropriate location, then
; incrementing R5ADD R5,R5,#1 ;ADD R3,R3,#-1 ; Checking to see if the entire frame buffer has been written intoBRp LOOP0 ;

LD R5,VIDEO ; This is in preparation for drawing the top border, row by row. Each row has; length 80 decimal
LD R1,RMAX ;LD R7,RED ; The value of a red pixel

;; TOP SIDELD R4,FOUR ; We need 4 such rows of length 80 decimal eachTIMES4 LD R0,ZERO ; This loop repeats 4 times, once for each rowLOOP1 STR R7,R5,#0 ; Storing a red pixel at the present display pointer, and incrementing the;pointerADD R0,R0,#1 ;ADD R5,R5,#1 ;LD R3,ZERO ; In this loop, we check if the length limit has been reached. If not, we go; back to LOOP1ADD R3,R3,R0 ;NOT R3,R3 ;ADD R3,R3,#1 ;ADD R3,R1,R3 ;BRzp LOOP1 ;LD R3,NEXTR ; Here we do the same thing 4 times..ADD R5,R5,R3 ; ..but remember that the display pointer must now point to the next row's

;starting addressADD R4,R4,#-1 ;BRp TIMES4 ;

;; LEFT AND RIGHT SIDES
	LD R5,SIDE	; now update the display to where the left side wall begins (Do not consider the overlap with the top side)
	LD R3,CMAX	; This is the height of the side walls (Excluding the 4 rows for the top side)
LOOP2	STR R7,R5,#0	; Drawing the left wall..
	STR R7,R5,#1	; 
	STR R7,R5,#2	;
	STR R7,R5,#3	; ..Done that.
	LD R4,DELTA	; Now updating the display pointer to point to the leftmost pixel of the right wall	
	ADD R5,R5,R4	; Drawing the right wall..
	STR R7,R5,#0	;
	STR R7,R5,#1	;
	STR R7,R5,#2	;
	STR R7,R5,#3	; ..Done that.
	
	LD R4,NEXTS	; Don't forget to change the display pointer to the next starting point
	ADD R5,R5,R4	;
	
	ADD R3,R3,#-1	; Repeat the same process for the entire height of the side walls.
	BRp LOOP2	;

;; BRICKS

	LD R5,BSTART	; Starting at the top left corner of the 1st brick
	LD R7,BLUE	; We'll choose to make it blue
	LD R4,BHEIGHT	; And R4 will store the height of the brick
	
TIME4	LD R3,BLENGTH	; 	
LOOP3	STR R7,R5,#0	; In this loop, we draw the 1st brick, the length of the 1st brick is 20 decimal. 
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	;
	BRp LOOP3	;
	
	ADD R5,R5,#4	; ..Remember to move the display pointer to the next brick
	LD R3,BLENGTH	;
LOOP4	STR R7,R5,#0	; Draw the next brick in the same manner as the previous brick
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	;
	BRp LOOP4	;

	ADD R5,R5,#4	; ..Not to forget to change the display pointer to the location of the start of the last brick
	LD R3,BLENGTH	;
LOOP5	STR R7,R5,#0	;
	ADD R5,R5,#1	; same procedure as was for the last 2 bricks
	ADD R3,R3,#-1	;
	BRp LOOP5	;

	LD R0,BRICKINC	; ..Move the display pointer to the next row of the 1st brick, and then repeat the process
	ADD R5,R5,R0	;
	ADD R4,R4,#-1	; Making sure that we draw the bricks length first for the entire height.
	BRp TIME4	;


HALT
;;And now define all the constants we need...VIDEO .FILL xC000DISPSIZE .FILL x3E00ZERO .FILL x0000RMAX .FILL x0053RED .FILL x7C00BLACK .FILL x0000FOUR .FILL x0004NEXTR .FILL x002CSIDE .FILL xC200
CMAX .FILL x0078
RED2 .FILL x8400
BLUE .FILL x001F
BLUE2 .FILL xFFE1

BSTART .FILL xC408		;start of leftmost brick
BSTART2 .FILL xC420		;start of middle brick
BSTART3 .FILL xC438		;start of rightmost brick
BLENGTH .FILL x0014		;20
BHEIGHT .FILL x0004
BRICKINC .FILL x003C	;60
BRICKWRAP .FILL 108	
DELTA .FILL x0050	;50
NEXTS .FILL x0030
.end