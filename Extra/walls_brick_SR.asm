;this is HW6 completed using Subroutines. To explain how compact and neat it can be…..
; the purpose of this is to clarify and enhance understanding of subroutines.
; Use this along with lc3os_v2


.orig x3000

START:	;; CLEAR THE SCREEN
	JSR INIT_FRAME_BUFFER_SR 	; Clear the frame buffer by writing zeros to all memory locations.
	
	LD R5,VIDEO			; This is in preparation for drawing the top border, row by row. Each row has length 80 decimal.
	LD R1,RMAX	 
	LD R2, RED
	JSR DRAW_TOP_SR 		; Subroutine to draw the top border.
	JSR DRAW_SIDES_SR 		; Subroutine to draw the left and right border.
	
	
	;; Drawing the 3 bricks
	AND R0,R0, #0
	ADD R1,R0, #2
	ADD R0,R0, #2
	LD R2,BLUE			; We'll choose to make it blue
	JSR DRAW_BRICK_SR		; Draw the first brick
	ADD R0,R0, #1
	JSR DRAW_BRICK_SR		; Draw the second brick
	ADD R0,R0, #1
	JSR DRAW_BRICK_SR		; Draw the third brick
	

HALT



;; Below are the service routines that may be useful for this project



INIT_FRAME_BUFFER_SR
	LD R5,VIDEO	; R5 is the pointer to the where the pixels will be written to the display
	LD R6,BLACK	; Black pixel value
	LD R3,DISPSIZE	; The size of the entire frame buffer (We are going to write the value of BLACK in the entire frame buffer)
LOOP0:
	STR R6,R5,#0	; In this loop, we are storing the pixel in the appropriate location, then incrementing R5
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	; Checking to see if the entire frame buffer has been written into
	BRp LOOP0	;
	RET

DRAW_TOP_SR
	LD R4,TWENTYONE	; We need 4 such rows of length 84 decimal each
	AND R0,R0, #0
	LD R1, ZERO
	
	ST R7, TEMP
TOP_LOOP:
	TRAP x40
	ADD R0, R0, #1
	ADD R4, R4, #-1
	BRp TOP_LOOP;	
	LD R7, TEMP
	RET

DRAW_SIDES_SR
	AND R1,R1, #0	; now update the display to where the left side wall begins (Do not consider the overlap with the top side)
	ADD R1,R1, #1
	LD R3,THIRTY	; This is the height of the side walls (Excluding the 4 rows for the top side)
	LD R5,TWENTYONE 
	ADD R5,R5, #-1
	ST R7, TEMP
SIDE_LOOP:	
	AND R0,R0, #0
	TRAP x40	; Drawing the right wall..
	ADD R0,R0,R5	
	TRAP x40
	ADD R1,R1,#1	;
	ADD R3,R3,#-1	; Repeat the same process for the entire height of the side walls.
	BRp SIDE_LOOP	;
	LD R7, TEMP
	RET

DRAW_BRICK_SR
	LD R4, FIVE
	ST R7, TEMP
BRICK_LOOP:		
	TRAP x40
	ADD R0, R0, #1
	ADD R4, R4, #-1
	BRp BRICK_LOOP	;
	LD R7, TEMP
	RET

	

;;And now define all the constants we need..

VIDEO .FILL xC000
DISPSIZE .FILL x3E00
RMAX .FILL x0053		;83
RED .FILL x7C00
TWENTYONE	.FILL 21
ZERO .FILL x0000
BLACK .FILL x0000
TEMP		.FILL 0
BLUE .FILL x001F
EIGHT		.FILL 8
FIVE		.FILL 5
THIRTY .FILL 30





.end
