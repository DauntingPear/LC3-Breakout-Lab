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
  ; Reset Game values
  JSR ResetGameSR

  ; Initial Game Setup and Frame Buffer Initialization
  ; Preconditions: None
  ; Postconditions: Video buffer filled with black pixels, R0/R1/R4/R6 preserved
  JSR InitFrameSR

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

ZERO .FILL 0
ONE .FILL 1

BOUNDARY_WIDTH .FILL 20
BOUNDARY_HEIGHT .FILL 31

RIGHT_COL .FILL 20
BOTTOM_ROW .FILL 30

;;+------------------------------+
;;|       Game Init Section      |
;;+------------------------------+

;----------------------------
;; Resets game constants
;----------------------------
ResetGameSR
  AND R0,R0,#0
  ST R0,BRICK_COLOR
  ST R0,WALL_COLOR
  ADD R0,R0,#2
  ST R0,BRICK_COL
  LD R0,ZERO
  ADD R0,R0,#5
  ST R0,BALL_X
  ST R0,BALL_Y
  LD R0,ZERO
  ADD R0,R0,#1
  ST R0,BALL_Y_DIR
  ST R0,BALL_X_DIR
  ADD R0,R0,#2
  ST R0,Bricks_Remaining
  RET

;----------------------------
;; Clears the frame buffer
;----------------------------
InitFrameSR
  LD R5, VIDEO
  LD R2, BLACK
  LD R3, DISPSIZE
  DrawBuffer:
    STR R2,R5,#0
    ADD R5,R5,#1
    ADD R3,R3,#-1
    BRp DrawBuffer
  RET

;----------------------------
;; Initializes game environment
;----------------------------
INIT_RET .FILL 0
InitializeGameSR
  ST R7,INIT_RET
  LD R2,RED
  ST R2,WALL_COLOR ; For descriptive use later

  ; Load Top boundary values, color is already set
  LD R0,ZERO ; col start pos
  LD R1,ZERO ; row start pos
  LD R3,BOUNDARY_WIDTH ; load width of rect
  LD R4,ONE ; load height of rect
  JSR DrawBoundarySR

  ; Load left boundary values
  LD R0,ZERO ; col start pos
  LD R1,ZERO ; row start pos
  LD R3,ONE ; load width of rect
  LD R4,BOUNDARY_HEIGHT ; load height of rect
  JSR DrawBoundarySR

  ; Load right boundary values
  LD R0,RIGHT_COL ; col start pos (20th col)
  LD R1,ZERO ; row start pos
  LD R3,ONE ; load width of rect
  LD R4,BOUNDARY_HEIGHT ; load height of rect
  JSR DrawBoundarySR

  ; Load bottom boundary values
  LD R0,ZERO ; col start pos
  LD R1,BOTTOM_ROW ; row start pos
  LD R3,BOUNDARY_WIDTH ; load width of rect
  LD R4,ONE ; load height of rect
  JSR DrawBoundarySR

  ; Draw Bricks
  LD R2,BLUE
  ST R2,BRICK_COLOR
  JSR DrawBrickSR
  JSR DrawBrickSR
  JSR DrawBrickSR

  ; Draw Ball
  LD R0,BALL_X
  LD R1,BALL_Y
  LD R2,GREEN
  ST R2,BALL_COLOR
  LD R2,BALL_COLOR
  TRAP x40

  LD R7,INIT_RET
  RET
HALT

;----------------------------
;; Draws Boundary
;; Inputs: R0 as start col, R1 as start row, R2 as color, R3 as width, R4 as height
;----------------------------
DRAW_BOUNDARY_RET .FILL 0
DRAW_WIDTH .FILL 0
DRAW_COL .FILL 0
DRAW_ROW .FILL 0
DRAW_HEIGHT .FILL 0
DrawBoundarySR
  ST R7,DRAW_BOUNDARY_RET
  ST R3,DRAW_WIDTH
  ST R0,DRAW_COL

  HeightLoop:
    LD R3,DRAW_WIDTH ; reset WidthLoop iterator
    LD R0,DRAW_COL

    WidthLoop:
      TRAP x40
      ADD R0,R0,#1 ; incr col pointer
      ADD R3,R3,#-1 ; decr width iterator
      BRp WidthLoop
    ;-- WidthLoop end

    ADD R1,R1,#1 ; incr row pointer
    ADD R4,R4,#-1 ; decr height iterator
    BRp HeightLoop
  ;-- HeightLoop end

  LD R7,DRAW_BOUNDARY_RET
  RET

;----------------------------
;; Draws Bricks
;; Inputs: R2 as color
;----------------------------
BRICK_COL .FILL 2
DRAW_BRICK_RET .FILL 0
BRICK_WIDTH .FILL 5
BRICK_ROW .FILL 2
DrawBrickSR
  ST R7,DRAW_BRICK_RET
  LD R0,BRICK_COL
  LD R3,BRICK_WIDTH
  LD R1,BRICK_ROW

  BrickLoop:
    TRAP x40
    ADD R0,R0,#1
    ADD R3,R3,#-1
    BRp BrickLoop
  ;-- BrickLoop end

  ; Store for next iteration
  ADD R0,R0,#1
  ST R0,BRICK_COL

  LD R7,DRAW_BRICK_RET
  RET

;;+------------------------------+
;;|       Game Loop Section      |
;;+------------------------------+

;-- Game Constants
BALL_X .FILL 5
BALL_Y .FILL 5
BALL_X_DIR .FILL 1
BALL_Y_DIR .FILL 1
BALL_COLOR .FILL 0
Bricks_Remaining .FILL 3

GameLoopSR
  GameLoop:
    JSR DelayLoopSR

    LD R0,BALL_X
    LD R1,BALL_Y
    LD R3,BALL_X_DIR
    LD R4,BALL_Y_DIR

    JSR NextPosSR

    JSR BallCollisionSR

    LD R0,BALL_X
    LD R1,BALL_Y
    LD R2,Black
    TRAP x40

    LD R0,NPX
    LD R1,NPY
    ST R0,BALL_X
    ST R1,BALL_Y

    LD R2,BALL_COLOR
    TRAP x40
    LD R6,Bricks_Remaining
    BRp GameLoop
  HALT

;----------------------------
;; Detects if ball has hit a wall, corner, brick, or bottom
;; Inputs: R0 as col, R1 as row, R3 as x dir, R4 as y dir, R5 as -(nextcolor)
;; R6 used as temp value to check if color - nextcolor = 0
;----------------------------
COLL_RET .FILL 0
COLL_TEMP .FILL 0
NEXTCOLOR_TEMP .FILL 0
BallCollisionSR
  ST R7,COLL_RET
  ; Check for wall
  LD R2,WALL_COLOR
  ADD R6,R2,R5
  BRnp BrickCol
  JSR WALL

  BrickCol
  ST R5,COLL_TEMP
  LD R2,BRICK_COLOR
  ADD R6,R2,R5
  BRnp BottomCol
  JSR BRICK
  LD R7,COLL_RET
  BRnzp BallCollisionSR

  BottomCol
  ;BRnzp BOTTOM

  LD R7,COLL_RET
  RET

;----------------------------
;; Checks to see if hitting a horizontal and/or vertical wall. Flips direction accordingly.
;; This also checks for corner as well.
;----------------------------
WallCol_RET .FILL 0
WALL:
  ST R7,WallCol_RET
  ST R5,NEXTCOLOR_TEMP

  ; If next column is left wall, flip x direction
  LeftWall
    LD R6,NPX
    BRnp RightWall
    JSR FLIP_X

  ; If next column is right wall, flip x
  RightWall
    LD R6,RIGHT_COL
    LD R7,NPX
    NOT R7,R7
    ADD R7,R7,#1
    ADD R6,R6,R7
    BRnp TopWall
    JSR FLIP_X

  ; If next row is top wall, flip y
  TopWall
    LD R6,NPY
    BRnp BottomWall
    JSR FLIP_Y

  ; If next row is bottom wall, flip y
  BottomWall
    LD R6,BOTTOM_ROW
    LD R7,NPY
    NOT R7,R7
    ADD R7,R7,#1
    ADD R6,R6,R7
    BRnp WallFinish
    JSR FLIP_Y

  WallFinish
    JSR NextPosSR
    LD R7,WallCol_RET
    RET


;----------------------------
;; Handles hitting a brick. Only checks the ball's X value as its y does not matter.
;; Inputs: None
;; Uses: R0, R1, R2, R5, R4, R6
;----------------------------
TEMP .FILL 0
BrickSR_RET .FILL 0
Brick:
  ST R7,BrickSR_RET
  LD R0,NPX ; Load ball next column
  ; Load Data for SR
  AND R5,R5,#0
  ADD R5,R5,#6 ; Load right bound
  AND R4,R4,#0
  ADD R4,R4,#-6
  LD R6,NPX
  JSR GetBrickSR

  HALT ; should not reach

; Checks to see if column is <= brick right bound, from brick1 to brick3 (LTR)
GET_BRICK_RET .FILL 0
GetBrickSR
  ST R7,GET_BRICK_RET
  AND R6,R6,#0
  ADD R6,R6,#4 ; Iterator
  GetBrickLoop:
    ADD R6,R0,R4
    BRnz DestroyBrick
    ADD R4,R4,#-6
    ADD R6,R6,#-1
    BRp GetBrickLoop
    HALT ; should not reach

DestroyBrick ; Destroys brick
  ; Set R7 to 5 (iterator)
  AND R6,R6,#0
  ADD R6,R6,#5

  LD R2,BLACK
  LD R1,NPY
  NOT R4,R4
  ADD R4,R4,#1
  ADD R0,R4,#0 ; Set R0 to the column that R4 pointed to
  DBLoop:
    TRAP x40
    ADD R0,R0,#-1
    ADD R6,R6,#-1
    BRp DBLoop
  ;-- End DBLoop
  ; Check to see if horizontal or vertical flip
  LD R0,Bricks_Remaining
  ADD R0,R0,#-1
  ST R0,Bricks_Remaining
  LD R4,BALL_Y_DIR
  JSR FLIP_Y
  LD R0,BALL_X
  LD R1,BALL_Y
  JSR NextPosSR
  LD R7,BrickSR_RET
  RET

;----------------------------
;; Flips Ball_X_Dir
;; Inputs: R3 as ball X dir
;; Returns R3 as new ball X dir
;----------------------------
FLIP_X
  NOT R3,R3
  ADD R3,R3,#1
  ST R3,BALL_X_DIR
  RET

;----------------------------
;; Flips Ball_Y_Dir
;; Inputs: R4 as ball Y dir
;; Returns R4 as new ball Y dir
;----------------------------
FLIP_Y
  NOT R4,R4
  ADD R4,R4,#1
  ST R4,BALL_Y_DIR
  RET




;----------------------------
;; Calculates next position based on current position and direction
;; Inputs: R0 as current col, R1 as current row, R3 as x dir, R4 as y dir
;----------------------------
NPX .FILL 0
NPY .FILL 0
NP0 .FILL 0
NP1 .FILL 0
NextColor .FILL 0
NP_RET .FILL 0

NextPosSR
  ST R0,NP0
  ST R1,NP1
  ST R7,NP_RET

  ADD R0,R0,R3 ; incr/decr col
  ADD R1,R1,R4 ; incr/decr row
  ST R0,NPX
  ST R1,NPY

  TRAP x41 ; color(R0,R1) -> R5
  NOT R5,R5
  ADD R5,R5,#1
  ST R5,NextColor ; store -(color)

  ; Restore
  LD R0,NP0
  LD R1,NP1
  LD R7,NP_RET
  RET


;----------------------------
;; Adds delay to each game tick
;----------------------------
DELAY .FILL 9000
DELAY_TEMP .FILL 0
DelayLoopSR
  ST R6,DELAY_TEMP
  LD R6,DELAY
  DelayLoop:
    ADD R6,R6,#-1
    BRp DelayLoop
  LD R6,DELAY_TEMP
  RET
