;;+------------------------------------------------------------------------------+
;;|                                                                              |
;;|  Author: Adrian Brady                                                        |
;;|  Date: 04/01/2024                                                            |
;;|  Purpose: Breakout Game Lab for Computer Engineering class spring 2024 MATC. |
;;|                                                                              |
;;+------------------------------------------------------------------------------+

;;+------------------------------+
;;|       Initialization         |
;;+------------------------------+
.orig x3000
START:
  ; Initial Game Setup and Frame Buffer Initialization
  ; Preconditions: None
  ; Postconditions: Video buffer filled with black pixels, R0/R1/R4/R6 preserved
  JSR InitFrameBufferSR

  ; Initial boundary and Gameplay Objects Drawing
  ; Preconditions: None
  ; Postconditions: Draws game boundaries, initializes game environment,
  ; draws ball. Register returns not considered. R7 is return address.
  JSR InitializeGameSR

  ; Main Game loop
  ; Preconditions: None
  ; Postconditions: End of game, program has finished
  JSR GameLoopSR

HALT

;;+------------------------------+
;;|       Subroutine Section     |
;;+------------------------------+

;; --- Constants Definition ---
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
;; End of Constants

;; --- Initialize Frame Buffer ---

;----------------------------
;; Clears the Frame Buffer
;; Modifies: R5, R2, R3
;; Uses: R2 for pixel color, R3 pixels in the display - iterator, R5 pixel address
;; Preserves: R7 (return address)
;----------------------------
InitFrameBufferSR
  LD R5,VIDEO ; R5 <- pointer to where pixels will be written
  LD R2,BLACK ; R2 <- Pixel color value
  LD R3,DISPSIZE ; R3 <- Total number of pixels in the display - Iterator value
  DrawBuffer:
    STR R2,R5,#0 ; Set pixel color
    ADD R5,R5,#1 ; Increment pixel
    ADD R3,R3,#-1 ; Decrement iterator
    BRp DrawBuffer
  RET

;; --- Initialize Game Environment ---

;----------------------------
;; Initializes the Game environment
;; Modifies: N/A
;; Uses: None
;----------------------------
INITGAME_RET .FILL 0
INITGAME_TEMP .FILL 0
InitializeGameSR
  ST R7, INITGAME_RET ; Store return address for later use
  LD R5,VIDEO
  LD R2,RED
  ST R2,WALL_COLOR ; Store color for later use

  ; Draw top of boundary
  ; Preconditions: R2 boundary color
  ; Postconditions: Top of boundary is drawn. R2,R3,R5,R6 preserved.
  ;   R0, R1, R4 used. R7 is return address.
  JSR DrawTopSR

  ; Draw side of boundary
  ; Preconditions: R2 bondary color
  ; Postconditoins: Sides of boundary is drawn. R2, R4, R6 preserved.
  ;   R0, R1, R3, R5 used. R7 is return address.
  JSR DrawSideSR

  ; Draw bottom of boundary
  ; Preconditions: R2 boundary color
  ; Postconditions: Bottom of boundary is drawn. R2, R5, R6 preserved.
  ;   R0, R1, R3, R4 used. R7 is return address.
  JSR DrawBottomSR

  LD R2,GREEN ; Load color of brick
  ST R2,BRICK_COLOR ; Store for later use
  ; Set column
  AND R0,R0,#0 ; Clear register
  ADD R0,R0,#2 ; Set column for brick

  ; Set row
  AND R1,R1,#0 ; Clear register
  ADD R1,R1,#2 ; Set row for brick

  ; Draw Bricks
  ST R3,INITGAME_TEMP ; Store for later use
  AND R3,R3,#0 ; Clear register
  ADD R3,R3,#3 ; Load 3, 3 bricks in game

  DrawBricksLoop:
    ; Draws bricks
    ; Preconditions: R0 starting column, R1 starting row, R2 color
    ; Postconditions: Bricks are drawn, R4, R2, R1 and R0 used. R7 is return address.
    JSR DrawBrickSR
    ADD R0,R0,#1 ; Jump over space between bricks
    ADD R3,R3,#-1 ; Decrement iterator
    BRp DrawBricksLoop ; Branch to DrawBricksLoop if iterations remaining

  LD R3,INITGAME_TEMP ; Restore

  ; R0 no longer needed, using for copying values
  LD R0,BALL_COLOR
  ST R0,Color
  LD R0,BALL_X
  ST R0,X
  LD R0,BALL_Y
  ST R0,Y

  ; Draws the ball, is a TRAP x40 wrapper
  ; Preconditions: None
  ; Postconditions: R7 return address
  JSR DrawPixelSR

  LD R7, GAMEINIT_RET ; Restore return value
  RET

;; --- Draw Game Boundary Walls ---

;----------------------------
;; Draws the top part of the boundary
;; Modifies: R4, R0, R1
;; Uses: R0 as column, R1 as row, R2 as color
;; Preserves: R7 (return address)
;----------------------------
DrawTopSR
	LD R4,WIDTH	; We need 4 such rows of length 84 decimal each
	AND R0,R0, #0
	LD R1, ZERO

	ST R7, TEMP
  DrawTop:
    ; Draws a 4x4 pixel
    ; Preconditions: R0 column, R1 row, R2 color
    ; Postconditions: R0-7 Preserved
    TRAP x40
    ADD R0, R0, #1
    ADD R4, R4, #-1
    BRp DrawTop;
    LD R7, TEMP
    RET

;----------------------------
;; Draws sides of boundary
;; Modifies: R0, R1, R3, R5
;; Uses: R2 as pixel color, R3 as height to draw. R5 as right side offset
;;  R1 as row, R0 as column
;; Preserves: R7 (return address)
;----------------------------
DrawSideSR
  ; Set draw column
  AND R1,R1,#0
  ADD R1,R1,#1
  LD R3,SIDEHEIGHT ; Set number of rows to draw (iterator)
  LD R5,WIDTH ; Set position of right side
  ADD R5,R5,#-1 ; off by 1
  ST R7,TEMP
  DrawSide:
    AND R0,R0,#0 ; Set Column pointer
    ; Draws a 4x4 pixel
    ; Preconditions: R0 column, R1 row, R2 color
    ; Postconditions: R0-7 Preserved
    TRAP x40 ; Draw Left Side
    ADD R0,R0,R5
    TRAP x40 ; Draw Right Side
    ADD R1,R1,#1 ; Increment Row
    ADD R3,R3,#-1 ; Decrement iterator
    BRp DrawSide
  LD R7,TEMP
  RET

;----------------------------
;; Draws bottom side of boundary
;; Modifies: R0, R1, R3, R4, R7
;; Uses: R0 as column, R1 as row, R2 as color, R4 as width to draw,
;;  R3 as height offset
;; Preserves: R7 (return address)
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
    ; Draws a 4x4 pixel
    ; Preconditions: R0 column, R1 row, R2 color
    ; Postconditions: R0-7 Preserved
    TRAP x40
    ADD R0,R0,#1
    ADD R4,R4,#-1
    BRp DrawBottom
  LD R7,TEMP
  RET

;; --- Initialize Gameplay Elements ---

;----------------------------
;; Draws Bricks
;; Modifies: R4, R0, R7
;; Uses: R4 as brick width iterator, R0 as column, R2 as color, R1 as row
;; Preserves: R1-R3, R5, R6, R7 (return address)
;----------------------------
DrawBrickSR
  LD R4,BRICKWIDTH

  ST R7,TEMP
  DrawBrick:
    ; Draws a 4x4 pixel
    ; Preconditions: R0 column, R1 row, R2 color
    ; Postconditions: R0-7 Preserved
    TRAP x40
    ADD R0,R0,#1
    ADD R4,R4,#-1
    BRp DrawBrick
  LD R7,TEMP
  RET

;----------------------------
;; Draws a 4x4 pixel
;; Modifies: R7
;; Uses: R0 as column, R1 as row, R2 as color
;; Preserves: R7
;----------------------------
PIXEL_R0 .FILL 0
PIXEL_R1 .FILL 0
PIXEL_R2 .FILL 0
DrawPixelSR
  ; Store previous values to be restored later
  ST R0,PIXEL_R0
  ST R1,PIXEL_R1
  ST R2,PIXEL_R2
  ST R7,TEMP ; Store to return later

  ; Load values
  LD R0, X		; X coordinate of ball starts at location 5
  LD R1, Y		; Y coordinate of ball starts at location 5
  LD R2, Color

  ; Draws a 4x4 pixel
  ; Preconditions: R0 column, R1 row, R2 color
  ; Postconditions: R0-7 Preserve
  TRAP x40

  ; Reload values
  LD R0,PIXEL_R0
  LD R1,PIXEL_R1
  LD R2,PIXEL_R2
  LD R7,TEMP
  RET

;; --- Main Gameplay Loop ---

;----------------------------
;; Runs the game loop
;; Modifies: N/A
;; Uses: N/A
;; Preserves: N/A
;----------------------------
GAME_LOOP_RET .FILL 0

GameLoopSR
  ST R7,GAME_LOOP_RET
  GameLoop	; This label is used as the main game loop, so return here as long as there are still bricks in the game!
    ; Put some delay to slow down the ball

    ; Delay between frame updates
    ; Preconditions: None
    ; Postconditions: Passes time, R6 used as delay. R7 is return address.
    JSR DelayLoopSR

    LD R0,BALL_X
    LD R1,BALL_Y
    LD R2,BALL_X_DIR
    LD R3,BALL_Y_DIR

    ; Calculates next position, then runs SRs for collisions
    ; Preconditions: R0 as ball X position, R1 as ball Y position,
    ;   R2 as ball X direction, R3 as ball Y direction
    ; Postconditions:
    JSR BallTickSR

    LD R0,BRICKS_REMAINING
    ADD R0,R0,#-1
    ST R0,BRICKS_REMAINING

    BRp GameLoop
  LD R7,GAME_LOOP_RET
  RET

;; --- Utility Functions ---

;----------------------------
;; Delay loop adds delay between game ticks
;; Modifies: R6, R7
;; Uses: R6 as delay value
;; Preserves: R7 as return value
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

;; --- Ball Physics and Collision Detection ---

;----------------------------
;; Performs a "Tick" for the game
;; Modifies:
;; Uses:
;; Preserves: R7 as return address,
;----------------------------
BALLTICK_RET .FILL 0
BALLTICK_R3 .FILL 0

BallTickSR

  ST R7,BALLTICK_RET ; store return address for later
  ; Calculates next position
  ; Preconditions: R0 as current column, R1 as current row, R2 as
  ;   X direction, R3 as Y direction
  ; Postconditions: The next position is calculated and stored in NPX,NPY,
  ;   R0 is next position column, R1 is next position row. R7 is return address.
  JSR NextPositionSR

  ; Gets color at next location
  ; Preconditions: R0 as next position column, R1 as next position row
  ; Postconditions: R5 as color at next position. R7 as return address.
  TRAP x41

  LD R0,BALL_X ; replace next pos column with current
  LD R1,BALL_Y ; replace next pos row with current
  ST R3,BALLTICK_R3 ; store Y direction in temp variable
  ; store color in R3
  AND R3,R3,#0
  ADD R3,R3,R5

  ; Determines wall collision, brick collision, bottom collision
  ; Preconditions: R0 as current ball X, R1 as current ball Y,
  ;   R2 as ball X direction, R3 as next color, R5 as next color
  ; Postconditions: R4 used, R0 changed, R1 changed, R3 may change,
  ;    R2 may change. Ball moves or game ends.
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
;; Ball Collision Logic
;; Modifies:
;; Uses: R0, R4, R1,
;; Preserves:
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
;; Logic for ball colliding with a wall
;; Inputs: R0
;; Modifies: R1, R0, R3, R2
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
;; Logic for ball colliding with a brick
;; Inputs:
;; Modifies:
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
;; Logic for ball colliding with the bottom of the border, out of bounds
;; Inputs:
;; Modifies:
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

;-- Game Over Logic --;

;----------------------------
;; Game Over Logic
;;
;;
;----------------------------
GAME_OVER
HALT


;; --------------------------------------------------------------------------------
;; End of Program. Below are the placeholders and dummy values for game elements.
;; --------------------------------------------------------------------------------

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
