;;
;; Author: Adrian Brady
;; Date: 04/01/2024
;; Purpose: Breakout Game Lab for Computer Engineering class spring 2024 MATC.
;;

;; -----------------------------------------------------------------------------

.orig x3000

START: ;; CLEAR THE SCREEN
  JSR InitFrameBufferSR

  LD R5,VIDEO
  LD R2,RED
  PUTS
  JSR DrawTopSR
  JSR DrawSideSR
  JSR DrawBottomSR
  LD R3,BRICK1
  JSR DrawBrick
HALT

;; Subroutines needed:
;; - Draw box row
;; - Draw box column
;; - Draw Brick
;; - Clear frame

;; Initialize frame buffer
InitFrameBufferSR
  LD R5,VIDEO ; R5 <- pointer to where pixels will be written
  LD R2,BLACK ; Pixel color value
  LD R3,DISPSIZE
  DrawBuffer:
    STR R2,R5,#0
    ADD R5,R5,#1
    ADD R3,R3,#-1
    BRp DrawBuffer
  ST R7,TEMP
  LEA R0, DB1
  PUTS
  LD R7,TEMP
  RET

;; Draw box row
DrawTopSR

  LD R5,VIDEO
  ST R7,TEMP
  LD R4,FOUR
  DrawTopHeight:

    LD R3,BOX_ROW_WIDTH
    DrawTopRow:

      STR R2,R5,#0
      ADD R5,R5,#1
      ADD R3,R3,#-1
      BRp DrawTopRow

    LD R3,NEXTROW
    ADD R5,R5,R3

    ADD R4,R4,#-1
    BRzp DrawTopHeight
  LD R7,TEMP
  RET

DrawSideSR
  LD R5,VIDEO
  LD R3,SIDESTART
  ADD R5,R5,R3

  ST R7,TEMP
  LD R4,SIDEHEIGHT
  DrawSideHeight:
    LD R3,FOUR

    DrawLeftSideRow:
      STR R2,R5,#0
      ADD R5,R5,#1
      ADD R3,R3,#-1
      BRzp DrawLeftSideRow

    LD R3,NEXTSIDE
    ADD R5,R5,R3

    LD R3,FOUR

    DrawRightSideRow:
      STR R2,R5,#0
      ADD R5,R5,#1
      ADD R3,R3,#-1
      BRzp DrawRightSideRow

    LD R3,NEXTROW
    ADD R5,R5,R3
    
    ADD R4,R4,#-1
    BRp DrawSideHeight
  LD R7,TEMP
  RET


DrawBottomSR
  LD R5,VIDEO
  LD R3,BOTTOMSTART
  ADD R5,R5,R3

  ST R7,TEMP
  LD R4,FOUR
  DrawBottomHeight:
    LD R3,BOX_ROW_WIDTH

    DrawBottomRow:
      STR R2,R5,#0
      ADD R5,R5,#1
      ADD R3,R3,#-1
      BRp DrawBottomRow

    LD R3,NEXTROW
    ADD R5,R5,R3

    ADD R4,R4,#-1
    BRzp DrawBottomHeight
  LD R7,TEMP
  RET

DrawBrick
  LD R5,VIDEO
  ADD R5,R5,R3 ; Adds brick offset position

  LD R6,DISPWIDTH
  NOT R3,R3
  ADD R3,R3,#-1
  ADD R6,R6,R3

  ST R7,TEMP
  LD R4,FOUR
  DrawBrickHeight:
    LD R3,BRICK_WIDTH

      DrawBrickRow:
        STR R2,R5,#0
        ADD R5,R5,#1
        ADD R3,R3,#-1
        BRp DrawBrickRow

    ADD R5,R5,R6

    ADD R4,R4,#-1
    BRzp DrawBrickHeight
  LD R7,TEMP
  RET

  


;;
;; <======== Hardcoded values ========>
;;
BOX_ROW_WIDTH .FILL 84
TEMP .FILL 0


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
DISPWIDTH .FILL x0080

ZERO .FILL x0000
EIGHTY .FILL x0050
TWENTY .FILL x0014
SIDEHEIGHT .FILL x0078

RED .FILL x7C00
BLACK .FILL x0000
GREEN .FILL x03E0
WHITE .FILL x7FFF

FIVE .FILL x0004
FOUR .FILL x0003
THREE .FILL x0002
EIGHT .FILL x0008

TOPSTART .FILL xC000
BOTTOMSTART .FILL x3C00
NEXTROW .FILL x002C
RMAX .FILL x0053
NEXTC .FILL x007C
NEXTSIDE .FILL x004C
INCRSIDE .FILL x0028

SIDESTART .FILL x0200

BRICKSTART .FILL x0408
BRICKHEIGHT .FILL x0004
BRICKSPACE .FILL x0004
BRICK_WIDTH .FILL x0014
BRICKNEXTROW .FILL x0035
BRICK1 .FILL x0408

BALL_X	.FILL 5
BALL_Y .FILL 5
BALL_X_DIR .FILL 1
BALL_Y_DIR .FILL 1
BALL_COLOR .FILL x8AA8

SIDE .FILL xC200
DELAY .FILL 6000

DB1 .STRINGZ "DB1"
TOP .STRINGZ "TOP"
.end
