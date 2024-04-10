;;+------------------------------------------------------------------------------+
;;|                                                                              |
;;|  Author: Adrian Brady                                                        |
;;|  Date: 04/01/2024                                                            |
;;|  Purpose: Breakout Game Lab for Computer Engineering class spring 2024 MATC. |
;;|                                                                              |
;;+------------------------------------------------------------------------------+

.orig x3000

START: ;; CLEAR THE SCREEN
  JSR InitFrameBufferSR

  LD R5,VIDEO
  LD R2,RED
  ST R2,WALL_COLOR

  ; Draw Sides
  JSR DrawTopSR
  JSR DrawSideSR
  JSR DrawBottomSR

  LD R2,GREEN
  ST R2,BRICK_COLOR
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

  LD R0,BALL_COLOR
  ST R0,Color
  LD R0,BALL_X
  ST R0,X
  LD R0,BALL_Y
  ST R0,Y
  JSR DrawPixelSR

  JSR GameLoopSR

HALT

;;+--------------------------------------------------------------+
;;|                         Subroutines                          |
;;+--------------------------------------------------------------+

;-- Constants --;
RED .FILL x7C00
BLACK .FILL x0000
GREEN .FILL x03E0
WHITE .FILL x7FFF
BLUE .FILL x001F

VIDEO .FILL xC000
DISPSIZE .FILL x3E00
BRICK_COLOR .FILL 0
WALL_COLOR .FILL 0

BRICKS_REMAINING .FILL 10

;----------------------------
;; === Initialize frame buffer ===
;; R0
;; R1
;; R2 -> Color
;; R3 -> Iterator value (total pixel count)
;; R4
;; R5 -> Pixel location
;; R6
;; R7 -> Return address
;----------------------------
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

;----------------------------
;;
;; Draw box row
;;
;----------------------------
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

;----------------------------
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

;----------------------------
;;
;; Draw Bottom
;;
;----------------------------
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

;----------------------------
;;
;; Draw Bricks
;;
;----------------------------
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
  
;----------------------------
;;
;; Draw Pixel
;;
;----------------------------
PIXEL_R0 .FILL 0
PIXEL_R1 .FILL 0
PIXEL_R2 .FILL 0
DrawPixelSR
  ST R0,PIXEL_R0
  ST R1,PIXEL_R1
  ST R2,PIXEL_R2
  LD R0, X		; X coordinate of ball starts at location 5	
  LD R1, Y		; Y coordinate of ball starts at location 5
  LD R2, Color
  ST R7,TEMP
  TRAP x40			; Trap to OS to draw the ball
  LD R0,PIXEL_R0
  LD R1,PIXEL_R1
  LD R2,PIXEL_R2
  LD R7,TEMP
  RET

;----------------------------
;;
;; Game Loop
;;
;----------------------------
GAME_LOOP_RET .FILL 0

GameLoopSR
  ST R7,GAME_LOOP_RET
  GameLoop	; This label is used as the main game loop, so return here as long as there are still bricks in the game!
    ; Put some delay to slow down the ball

    JSR DelayLoopSR
    
    LD R0,BALL_X
    LD R1,BALL_Y
    LD R2,BALL_X_DIR
    LD R3,BALL_Y_DIR

    ; Calculates next position, then runs SRs for collisions
    JSR BallTickSR

    LD R0,BRICKS_REMAINING
    ADD R0,R0,#-1
    ST R0,BRICKS_REMAINING

    BRp GameLoop
  LD R7,GAME_LOOP_RET
  RET


;----------------------------
;;
;; Delay Loop
;;
;----------------------------
DELAY .FILL 8000
DELAY_LOOP_RET .FILL 0

DelayLoopSR
  ST R7,DELAY_LOOP_RET

  LD R6,DELAY
  
  DelayLoop:
    ADD R6,R6,#-1
    BRp DelayLoop

  LD R7,DELAY_LOOP_RET
	RET

;----------------------------
;;
;; === Ball Tick ===
;;
;; R0 -> BALL_X
;; R1 -> BALL_Y
;; R2 -> BALL_X_DIR
;; R3 -> BALL_Y_DIR
;; VAR: BALL_COLOR
;; VAR: WALL_COLOR
;; VAR: BRICK_COLOR
;----------------------------
BALLTICK_RET .FILL 0
BALLTICK_R3 .FILL 0

BallTickSR
  
  ST R7,BALLTICK_RET
  JSR NextPositionSR
  
  ;; IN R0 -> x column, R1 -> y row
  ;; OUT R5 -> NextColor
  TRAP x41
  LD R0,BALL_X
  LD R1,BALL_Y
  ST R3,BALLTICK_R3
  AND R3,R3,#0
  ADD R3,R3,R5

  JSR BallCollisionSR
  
  LD R6,BLACK
  ST R6,COLOR
  JSR DrawPixelSR

  ST R0,BALL_X
  ST R0,X
  ST R1,BALL_Y
  ST R1,Y
  ST R2,BALL_X_DIR
  LD R3,BALLTICK_R3
  ST R3,BALL_Y_DIR
  LD R6,BALL_COLOR
  ST R6,COLOR
  
  JSR DrawPixelSR

  LD R7,BALLTICK_RET
  RET
  
;----------------------------
;;
;; === Calculate Next Location ===
;;
;; R0 -> BALL_X
;; R1 -> BALL_Y
;; R2 -> BALL_X_DIR
;; R3 -> BALL_Y_DIR
;; VAR: BALL_COLOR
;----------------------------
NPX .FILL 0
NPY .FILL 0
NP0 .FILL 0
NP1 .FILL 0
NP2 .FILL 0
NP3 .FILL 0
NP4 .FILL 0
NP5 .FILL 0
NP6 .FILL 0
NP7 .FILL 0

NEXTPOS_RET .FILL 0

NextPositionSR
  ST R7,NEXTPOS_RET

  ST R0,NP0
  ST R1,NP1
  ST R2,NP2
  ST R3,NP3
  ST R4,NP4
  ST R5,NP5
  ST R6,NP6
  ST R7,NP7

  ADD R0,R0,R2 ;; Incr/Decr X position -- depends on direction of ball (+1/-1)
  ADD R1,R1,R3 ;; Incr/Decr Y position -- depends on direction of ball (+1/-1)
  ST R0,NPX
  ST R1,NPY
  LD R7,NEXTPOS_RET
  RET

;----------------------------
;;
;; === Ball Collision SR ===
;; 
;; R0 -> BALL_X
;; R1 -> BALL_Y
;; R2 -> BALL_X_DIR
;; R3 -> BALL_Y_DIR
;; R4 -> Color Check
;; R5 -> NEXTCOLOR
;; R6 -> 

;; RED -> x7C00
;; BLACK -> x0000
;; GREEN -> x03E0
;; WHITE -> x7FFF
;; BLUE -> x001F
;;
;----------------------------
COLLISION_RET .FILL 0
TEMP_R0 .FILL 0
TEMP_R1 .FILL 0
TEMP_R2 .FILL 0
TEMP_R3 .FILL 0

BallCollisionSR
  ST R7,COLLISION_RET

  ;; Check for wall
  ;; Negate R4 (wall color) for subtraction
  LD R4,WALL_COLOR
  NOT R4,R4
  ADD R4,R4,#1

  ADD R4,R4,R5
  ST R0,TEMP_R0
  BRz WallCollision

  ;; Check for brick
  ;; Negate R4 (brick color) for subtraction
  LD R4,BRICK_COLOR
  NOT R4,R4
  ADD R4,R4,#1

  ADD R4,R4,R5
  BRz BrickCollision
  
  ;TODO Check if bottom of screen
  ;; Check for bottom
  ;; Negate R4 (height of play area)
  ;; Checking to see if next location >= bottom row (30) (rows start at 0, really 31 rows)
  LD R4,SIDEHEIGHT
  NOT R4,R4
  ADD R4,R4,#1

  ADD R4,R4,R1 ; R1 is the ball height
  BRp BottomCollision

  Collision ; Label to jump to for wall and brick collision. Allows for value updates.
  
  LD R0,NPX
  LD R1,NPY


  ST R0,BALL_X
  ST R1,BALL_Y
  ST R2,BALL_X_DIR
  ST R3,BALL_Y_DIR

  LD R7,COLLISION_RET
  RET



  
  
  

;----------------------------
;;
;; === Wall Collision ===
;;
;----------------------------
WALL_COL_RET .FILL 0

WallCollision
  JSR WallCollisionSR
  BR Collision

WallCollisionSR
  ST R7,WALL_COL_RET
  
  ST R1,TEMP_R1
  ;; Right Wall -> Checks if ball column is column 19
  LD R1,WIDTH
  ADD R1,R1,#-1 ; Set to max position of ball (21-2=19)
  NOT R1,R1
  ADD R1,R1,#1
  ADD R1,R1,R0
  BRz FLIP_VERTICAL

  ;; Left wall -> checks if ball column is column 1
  AND R1,R1,#0
  ADD R1,R1,#-1
  ADD R1,R1,R0
  BRz FLIP_VERTICAL

  ;; Otherwise, horizontal wall was hit -> Flip y direction
  ;; Negation
  LD R1,BALL_Y_DIR
  NOT R1,R1
  ADD R1,R1,#1
  ST R1,BALL_Y_DIR
  
  CollisionReturn

  LD R1,TEMP_R1
  LD R3,BALL_Y_DIR
  LD R2,BALL_X_DIR
  JSR NextPositionSR
  ST R0,TEMP_R0
  LD R7,WALL_COL_RET
  RET

FLIP_VERTICAL
  ;;TODO check for top corner

  ;; TODO check for bottom corner

  ;; Otherwise, flip x direction
  LD R1,BALL_X_DIR
  NOT R1,R1
  ST R1,BALL_X_DIR
  ADD R1,R1,#1
  ST R1,BALL_X_DIR
  BR CollisionReturn

FLIP_CORNER


;----------------------------
;;
;; === Brick Collision ===
;;
;----------------------------
BRICK_COL_RET .FILL 0

BrickCollision
  JSR BrickCollisionSR
  BR Collision

;TODO
BrickCollisionSR
  ST R7,BRICK_COL_RET
  HALT
  LD R7,BRICK_COL_RET
  RET

;----------------------------
;;
;; === Check for bottom of screen ===
;;
;----------------------------
BOTTOM_COL_RET .FILL 0
BottomCollision
  JSR BottomCollisionSR
  BR GAME_OVER

BottomCollisionSR
  ST R7,BOTTOM_COL_RET
  HALT
  LD R7,BOTTOM_COL_RET
  RET

;----------------------------
;;
;; === Ball Direction ===
;;
;----------------------------
BALLDIR_RET .FILL 0

BallDirSR


;----------------------------
;;
;; === Game Over ===
;;
;----------------------------
GAME_OVER
HALT


;----------------------------
;;
;; <======== Hardcoded values ========>
;;
;----------------------------
COLOR .FILL 0
X .FILL 0
Y .FILL 0


WIDTH .FILL 21

ZERO .FILL x0000
SIDEHEIGHT .FILL 30


BRICKWIDTH .FILL 5

BALL_X	.FILL 5
BALL_Y .FILL 5
BALL_X_DIR .FILL #-1
BALL_Y_DIR .FILL 1
BALL_COLOR .FILL x8AA8

TEMP .FILL 0

.end
