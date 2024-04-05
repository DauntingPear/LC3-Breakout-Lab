;;
;; Author: Adrian Brady
;; Date: 04/01/2024
;; Purpose: Breakout Game Lab for Computer Engineering class spring 2024 MATC.
;;

;; -----------------------------------------------------------------------------

.orig x3000

START ;; CLEAR THE SCREEN
LD R5,VIDEO ; R5 is the pointer to the where the pixels will be written to the display
LD R7,BLACK ; Black pixel value
LD R3,DISPSIZE ; The size of the entire frame buffer (We are going to write the
; value of BLACK in the entire frame buffer)
LOOP0 STR R7,R5,#0 ; In this loop, we are storing the pixel in the appropriate location, then
; incrementing R5
ADD R5,R5,#1 ;
ADD R3,R3,#-1 ; Checking to see if the entire frame buffer has been written into
BRp LOOP0 ;

;;
;; <======== The top part clears the screen ========>
;;


;;<==== TOP FILL ====>

;; R7 <- Pixel Color
;; R6 <- None
;; R5 <- Absolute pixel position
;; R4 <- Outer loop iterator
;; R3 <- Iterator check by negation
;; R2 <- None
;; R1 <- Iterator bound counter
;; R0 <- Relative pixel position

LD R5,TOPSTART
LD R7,RED ; Pixel color

LD R1,RMAX ; Set inner iterator bound check

LD R4,FOUR

TopRows

  LD R0,ZERO
  DrawTop

    STR R7,R5,#0 ; Set pixel color

    ADD R0,R0,#1 ; Increment relative pixel position
    ADD R5,R5,#1 ; Increment absolute pixel position

    ;; Check if relative pixel position has exceeded bounds
    ADD,R1,R1,#-1
    BRzp DrawTop

  DrawTop_END

  ;; Increment absolute pixel position to next row
  LD R3,NEXTR
  LD R1,RMAX
  ADD R5,R5,R3

  ADD R4,R4,#-1 ; Decrement outer loop iterator
  BRzp TopRows

TopRows_END

;;
;; Bottom Row
;;

LD R5,BOTTOMSTART
LD R7,RED ; Pixel color

LD R1,RMAX ; Set inner iterator bound check

LD R4,FOUR

BottomRows

  LD R0,ZERO
  DrawBottom

    STR R7,R5,#0 ; Set pixel color

    ADD R0,R0,#1
    ADD R5,R5,#1

    ADD R1,R1,#-1
    BRzp DrawBottom
  DrawBottom_END

  LD R3,NEXTR
  LD R1,RMAX
  ADD R5,R5,R3

  ADD R4,R4,#-1
  BRzp BottomRows

BottomRows_END

;; <==== Draw Sides ====>

;; R7 <- Pixel color
;; R6 <- None
;; R5 <- Absolute pixel position
;; R4 <- Outer loop iterator
;; R3 <- Iterator check by negation
;; R2 <- None
;; R1 <- Iterator bound counter
;; R0 <- Relative pixel position

LD R5,VIDEO
LD R7,RED

LD R4, ONE24

DrawSides ; Controls for each row

  LD R1,FOUR ; Iterator bound
  LD R0,ZERO ; Reset relative pixel counter

  DrawLeft

    STR R7,R5,#0 ; Controls drawing pixels in each row
    ADD R0,R0,#1 ; Increment relative counter
    ADD R5,R5,#1 ; Increment absolute counter

    ADD R1,R1,#-1
    BRzp DrawLeft

  DrawLeft_END

  ;; Increment absolute pixel position by next side pixel difference
  LD R3,NEXTSIDE
  ADD R5,R5,R3

  LD R1,FOUR
  LD R0,ZERO

  DrawRight

    STR R7,R5,#0 ; Controls drawing pixels in each row
    ADD R0,R0,#1 ; Increment relative counter
    ADD R5,R5,#1 ; Increment absolute counter

    ADD R1,R1,#-1
    BRzp DrawRight

  DrawRight_END

  LD R3,INCRSIDE
  ADD R5,R5,R3

  ADD R4,R4,#-1
  BRp DrawSides

DrawSides_END

;; <==== BRICKS FILL ====>

;; R7 <- Color
;; R6 <- None
;; R5 <- Absolute pixel position
;; R4 <- Brick Rows Remaining
;; R3 <- None
;; R2 <- Bricks remaining to draw on row
;; R1 <- Brick Width Remaining
;; R0 <- Iterator Counter

LD R5,VIDEO ; Store memory address of first pixel
LD R0,BRICKSTART
ADD R5,R5,R0 ; Add brick starting position offset

LD R7,GREEN ; Load pixel color

;; ----

LD R4,BRICKHEIGHT ; DRAW_BRICKS iterator
DrawBricks ; Loop draws each row for each brick

  LD R2, THREE ; DRAW_IN_ROW iterator
  DrawInRow ; Loop used to draw each brick row in row

    LD R0,ZERO ; Relative pointer position, used for drawing
    LD R1,BRICKWIDTH ; DRAW_BRICK_ROW iterator

    DrawBrickRow ; Loop used to draw the brick row
      STR R7,R5,#0  

      ;; Increment pointer position
      ADD R0,R0,#1
      ADD R5,R5,#1
      ADD R1,R1,#-1 ; R1-- decr iterator
      
      BRzp DrawBrickRow ; If length remaining is >= 0 then loop
    DrawBrickRow_END

    ADD R5,R5,#4
    ADD R2,R2,#-1 ; R2-- decr iterator
    BRzp DrawInRow ; If number of bricks to draw is >= 0 then loop

  DrawInRow_END

  LD R3,BRICKNEXTROW
  ADD R5,R5,R3 ; Set absolute pointer to next row start
  LD R3,ZERO ; Reset register
  ADD R4,R4,#-1 ; R4-- decr iterator

  BRzp DrawBricks ; If number of rows remaining is >= 0 then loop

DrawBricks_END

HALT

	LD R0, BALL_X		; X coordinate of ball starts at location 5	
	LD R1, BALL_Y		; Y coordinate of ball starts at location 5
	LD R2, BALL_COLOR	
	TRAP x40			; Trap to OS to draw the ball

;;
;; Game Loop
;;
GameLoop	; This label is used as the main game loop, so return here as long as there are still bricks in the game!
	; Put some delay to slow down the ball
	LD R6, DELAY	
	JSR DELAY_LOOP

  HALT

  BRnzp GameLoop
GameLoop_END

DELAY_LOOP
	ADD R6,R6,#-1
	BRp DELAY_LOOP
	RET

;;And now define all the constants we need...
VIDEO .FILL xC000
DISPSIZE .FILL x2E00

ZERO .FILL x0000
EIGHTY .FILL x0050
TWENTY .FILL x0014
ONE24 .FILL x007C

RED .FILL x7C00
BLACK .FILL x0000
GREEN .FILL x03E0
WHITE .FILL x7FFF

FIVE .FILL x0004
FOUR .FILL x0003
THREE .FILL x0002
EIGHT .FILL x0008

TOPSTART .FILL xC000
BOTTOMSTART .FILL xFC00
NEXTR .FILL x002C
RMAX .FILL x0053
NEXTC .FILL x007C
NEXTSIDE .FILL x0050
INCRSIDE .FILL x0028

BRICKSTART .FILL x0408
BRICKHEIGHT .FILL x0004
BRICKSPACE .FILL x0004
BRICKWIDTH .FILL x0014
BRICKNEXTROW .FILL x0035

SIDE .FILL xC200
.end
