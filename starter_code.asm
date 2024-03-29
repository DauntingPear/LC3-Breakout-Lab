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


;;
;;<==== TOP FILL ====>
;;
LD R5,VIDEO

LD R1,RMAX
LD R7,RED

;; TOP SIDE
LD R4,FOUR
TIMES4 LD R0,ZERO
LOOP1 STR R7,R5,#0
ADD R0,R0,#1
ADD R5,R5,#1
LD R3,ZERO

ADD R3,R3,R0
NOT R3,R3
ADD R3,R3,#1
ADD R3,R1,R3
BRzp LOOP1
LD R3,NEXTR
ADD R5,R5,R3
ADD R4,R4,#-1
BRp TIMES4


;; <==== RIGHT FILL ====>
LD R5,VIDEO

LD R6,EIGHTY
ADD R5,R5,#4
ADD R5,R5,R6
LD R6,ZERO

LD R1,FOUR
LD R7,RED

LD R4, ONE24
RIGHTLOOP LD R0,ZERO
RIGHTCOL STR R7,R5,#0
ADD R0,R0,#1
ADD R5,R5,#1
LD R3,ZERO
ADD R3,R3,R0
NOT R3,R3
ADD R3,R3,#1
ADD R3,R1,R3
BRzp RIGHTCOL
LD R3,NEXTC
ADD R5,R5,R3
ADD R4,R4,#-1
BRp RIGHTLOOP

;; <==== LEFT FILL ====>
LD R5,VIDEO
LD R1,FOUR
LD R7,RED

LD R4, ONE24
LEFTLOOP LD R0,ZERO
LEFTCOL STR R7,R5,#0
ADD R0,R0,#1
ADD R5,R5,#1
LD R3,ZERO
ADD R3,R3,R0
NOT R3,R3
ADD R3,R3,#1
ADD R3,R1,R3
BRzp LEFTCOL
LD R3,NEXTC
ADD R5,R5,R3
ADD R4,R4,#-1
BRp LEFTLOOP

;;
;; <==== BRICKS FILL ====>
;;
;; Here you will draw the three bricks with spacing and dimensions as listed in the homework.
;; Bricks should be 4x20, and have 4 pixels between themselves and the walls and other bricks.
;; It is suggested you use a different color for bricks than for walls.

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
LD R4,BRICKHEIGHT

DRAW_BRICKS

  LD R2, THREE
  DRAW_IN_ROW; Draws the brick

    ;; Initialize Register values

    LD R0,ZERO
    LD R1,BRICKWIDTH

    DRAW_BRICK_ROW
      STR R7,R5,#0  

      ;; Increment pointer position
      ADD R0,R0,#1
      ADD R5,R5,#1
      ADD R1,R1,#-1
      
      BRzp DRAW_BRICK_ROW ; If length remaining is >= 0 then loop
    DRAW_BRICK_ROW_END

    ADD R5,R5,#4
    ADD R2,R2,#-1
    BRzp DRAW_IN_ROW

  DRAW_IN_ROW_END

  LD R3,BRICKNEXTROW
  ADD R5,R5,R3
  LD R3,ZERO
  ADD R4,R4,#-1

  BRzp DRAW_BRICKS

DRAW_BRICKS_END

;; ----

HALT

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

NEXTR .FILL x002C
RMAX .FILL x0053
NEXTC .FILL x007C

BRICKSTART .FILL x0408
BRICKHEIGHT .FILL x0004
BRICKSPACE .FILL x0004
BRICKWIDTH .FILL x0014
BRICKNEXTROW .FILL x0035

SIDE .FILL xC200
.end
