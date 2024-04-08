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

  ; Draw Sides
  JSR DrawTopSR
  JSR DrawSideSR
  JSR DrawBottomSR

  LD R2,GREEN
  ; Set column 
  AND R0,R0,#0
  ADD R0,R0,#2

  ; Set row
  AND R1,R1,#0
  ADD R1,R1,#2

  ; Draw Bricks
  JSR DrawBrickSR
  ADD R0,R0,#1
  JSR DrawBrickSR
  ADD R0,R0,#1
  JSR DrawBrickSR

  JSR DrawBallSR

  ; Game Loop
  
HALT

;;
;; Initialize frame buffer
;;
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

;;
;; Draw box row
;;
DrawTopSR
	LD R4,WIDTH	; We need 4 such rows of length 84 decimal each
	AND R0,R0, #0
	LD R1, ZERO
	
	ST R7, TEMP
  DrawTop:
    TRAP x40
    ADD R0, R0, #1
    ADD R4, R4, #-1
    BRp DrawTop;	
    LD R7, TEMP
    RET

;;
;; === Draw Sides ===
;; R0 -> Column
;; R1 -> Row
;; R2 -> Color
;; R3 -> Height Iteration Counter
;; R5 -> Side distance between offset
;; R6
;; R7
;----------------------------
DrawSideSR
  AND R1,R1,#0
  ADD R1,R1,#1
  LD R3,SIDEHEIGHT
  LD R5,WIDTH
  ADD R5,R5,#-1
  ST R7,TEMP
  DrawSide:
    AND R0,R0,#0 ; Set Column pointer
    TRAP x40 ; Draw Left Side
    ADD R0,R0,R5
    TRAP x40 ; Draw Right Side
    ADD R1,R1,#1 ; Increment Row
    ADD R3,R3,#-1 ; Decrement iterator
    BRp DrawSide
  LD R7,TEMP
  RET

;;
;; Draw Bottom
;;
DrawBottomSR
  LD R0,ZERO
  LD R1,ZERO
  LD R4,WIDTH
  LD R3,SIDEHEIGHT
  ADD R1,R1,R3
  LD R3,ZERO

  ST R7,TEMP
  DrawBottom:
    TRAP x40
    ADD R0,R0,#1
    ADD R4,R4,#-1
    BRp DrawBottom
  LD R7,TEMP
  RET

;;
;; Draw Bricks
;;
DrawBrickSR
  LD R4,BRICKWIDTH
  
  ST R7,TEMP
  DrawBrick:
    TRAP x40
    ADD R0,R0,#1
    ADD R4,R4,#-1
    BRp DrawBrick
  LD R7,TEMP
  RET
  
;;
;; Draw Ball
;;
DrawBallSR
  LD R0, BALL_X		; X coordinate of ball starts at location 5	
  LD R1, BALL_Y		; Y coordinate of ball starts at location 5
  LD R2, BALL_COLOR	
  ST R7,TEMP
  TRAP x40			; Trap to OS to draw the ball
  LD R7,TEMP
  RET

;;
;; Game Loop
;;
GameLoopSR
  GameLoop	; This label is used as the main game loop, so return here as long as there are still bricks in the game!
    ; Put some delay to slow down the ball
    LD R6, DELAY	
    JSR DelayLoopSR

    ;; TODO implement current location and direction
    ;; TODO implement next location

    TRAP x41 ; Get color of next location -> R5
    HALT
    ;; TODO BR??? WALL_COLLISION_LABEL if wall color, its a wall
    ;; TODO BR??? BRICK_COLLISION_LABEL if brick color, its a brick
    ;; TODO change color values to BRICKCOLOR and WALLCOLOR
    ;; TODO BR??? GAME_OVER_LABEL Check if at bottom of the screen, game over 
    ;; TODO No collision
      ; move ball by erasing current ball then redrawing ball at new location
      ; store new location
    ;; TODO check to see if total number of bricks is positive GAME_LOOP, otherwise HALT

    BRnzp GameLoop

;;
;; Delay Loop
;;
DelayLoopSR
  DelayLoop:
	ADD R6,R6,#-1
	BRp DelayLoop
	RET

;;
;; <======== Hardcoded values ========>
;;
VIDEO .FILL xC000
DISPSIZE .FILL x3E00

WIDTH .FILL 21

ZERO .FILL x0000
SIDEHEIGHT .FILL 30

RED .FILL x7C00
BLACK .FILL x0000
GREEN .FILL x03E0
WHITE .FILL x7FFF

FIVE .FILL x0004
FOUR .FILL x0003
THREE .FILL x0002

BRICKWIDTH .FILL 5

BALL_X	.FILL 5
BALL_Y .FILL 5
BALL_X_DIR .FILL 1
BALL_Y_DIR .FILL 1
BALL_COLOR .FILL x8AA8

DELAY .FILL 6000
TEMP .FILL 0

.end
