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
  JSR DrawTopSR
  JSR DrawSideSR
  JSR DrawBottomSR

  LD R2,GREEN
  JSR BrickSR
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
  LD R3,DISPSIZE ; Total number of pixels in the display - Iterator value
  DrawBuffer:
    STR R2,R5,#0 ; Set pixel color
    ADD R5,R5,#1 ; Increment pixel
    ADD R3,R3,#-1 ; Decrement iterator
    BRp DrawBuffer
  RET

;; Draw box row
DrawTopSR
  LD R5,VIDEO ; Pointer to where pixels will be written
  ST R7,TEMP ; Store program execution spot
  LD R4,FOUR ; Iterator 1

  DrawTopHeight:
    LD R3,BOX_ROW_WIDTH ; Iterator 2

    DrawTopRow:
      STR R2,R5,#0 ; Set pixel color
      ADD R5,R5,#1 ; Increment pixel
      ADD R3,R3,#-1 ; Decrement iterator
      BRp DrawTopRow

    LD R3,NEXTROW ; Load nextrow offset value
    ADD R5,R5,R3 ; Increment pixel value by offset

    ADD R4,R4,#-1 ; Decrement iterator
    BRzp DrawTopHeight
  LD R7,TEMP ; Load return value
  RET

;; Draw Sides
DrawSideSR
  LD R5,VIDEO ; Pointer to where pixels will be written
  LD R3,SIDESTART ; First pixel offset
  ADD R5,R5,R3 ; Increment pointer by offset

  ST R7,TEMP ; Store return address
  LD R4,SIDEHEIGHT ; Iterator 1
  DrawSideHeight:
    LD R3,FOUR ; Iterator 2

    DrawLeftSideRow:
      STR R2,R5,#0
      ADD R5,R5,#1
      ADD R3,R3,#-1
      BRzp DrawLeftSideRow

    LD R3,NEXTSIDE ; Load next side offset
    ADD R5,R5,R3 ; Increment by offset

    LD R3,FOUR ; Iterator 2

    DrawRightSideRow:
      STR R2,R5,#0
      ADD R5,R5,#1
      ADD R3,R3,#-1
      BRzp DrawRightSideRow

    LD R3,NEXTROW ; Load next row offset
    ADD R5,R5,R3 ; Increment by offset
    
    ADD R4,R4,#-1 ; Decrement iterator
    BRp DrawSideHeight
  LD R7,TEMP
  RET

;; Draw Bottom
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

;; Draw Bricks
BrickSR
  LD R5,VIDEO ; Load first pixel location
  LD R3,BRICKOFFSET ; Load brick offset
  ADD R5,R5,R3 ; Adds brick offset position

  ST R7,TEMP ; Store program return

  LD R7,BRICK_WIDTH ; Load width of brick

  LD R4,FOUR ; Iterator 1 -> Controls for number of rows to draw
  DrawBrickHeight:

    AND R6,R6,0
    ADD R6,R6,#2 ; Iterator 2 -> Controls for Number of bricks in a row
    DrawBrick:

      LD R3,BRICK_WIDTH ; Iterator 3 -> Controls for width of brick
      ADD R5,R5,#4

      DrawBrickRow:
        STR R2,R5,#0
        ADD R5,R5,#1
        ADD R3,R3,#-1
        BRp DrawBrickRow

      ADD R6,R6,#-1
      BRzp DrawBrick

    LD R6,NEXTBRICKROW
    ADD R5,R5,R6

    ADD R4,R4,#-1
    BRzp DrawBrickHeight
  LD R7,TEMP
  RET


;;
;; <======== Hardcoded values ========>
;;
BOX_ROW_WIDTH .FILL 84
NEXTBRICKROW .FILL x0038
BRICKOFFSET .FILL x0404
TEMP .FILL 0
BRICKNUM .FILL 0


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
