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
LD R5,VIDEO ; This is in preparation for drawing the top border, row by row. 
; Each row has length 80 decimal

LD R1,RMAX ;
LD R7,RED ; The value of a red pixel

;; TOP SIDE
LD R4,FOUR ; We need 4 such rows of length 80 decimal each (uses a label FOUR, look at end of file)
TIMES4 LD R0,ZERO ; This loop repeats 4 times, once for each row
LOOP1 STR R7,R5,#0 ; Storing a red pixel at the present display pointer, and incrementing the pointer
ADD R0,R0,#1 ;
ADD R5,R5,#1 ;
LD R3,ZERO ; In this loop, we check if the length limit has been reached. If not, we go
; back to LOOP1
ADD R3,R3,R0 ;
NOT R3,R3 ;
ADD R3,R3,#1 ;
ADD R3,R1,R3 ;
BRzp LOOP1 ; break on negative number
LD R3,NEXTR ; Here we do the same thing 4 times.. Uses NEXTR label (for next row)
ADD R5,R5,R3 ; ..but remember that the display pointer must now point to the next row's
;starting address
ADD R4,R4,#-1 ; subtract 1 from register which holds number of rows to make
BRp TIMES4 ;


;; LEFT AND RIGHT SIDES
;; Here you will write the code which will draw the left and right walls with the spacing
;; and dimensions listed in the homework problem. There should be 76 pixels of space between
;; the inside of the left and right walls, and the left and right walls should be 4 pixels.

;;
;; <==== RIGHT FILL ====>
;;
;; 84 -> 0x53 <- Start of column to draw
;; 128 - 84 -> 44 (0x2C) <- distance to end of row

;; R5 -> pixel address (absolute in memory)
;; R7 -> Color Value
;; R4 -> Number of rows
;; R0 -> Position of pixel to insert, relative from start of row
;; R1 -> Length of row

LD R5,VIDEO ; This is in preparation for drawing the top border, row by row. 
; Each row has length 80 decimal
LD R6,EIGHTY
ADD R5,R5,R6
LD R6,ZERO

LD R1,FOUR ;
LD R7,RED ; Pixel Color

LD R4, ONE24 ; We need 124 such rows of length 4 decimal each
RIGHTLOOP LD R0,ZERO ; This loop repeats 124 times, once for each row
RIGHTCOL STR R7,R5,#0 ; Storing a red pixel at the present display pointer, and incrementing the pointer
ADD R0,R0,#1 ;
ADD R5,R5,#1 ;
LD R3,ZERO ; In this loop, we check if the length limit has been reached. If not, we go
; back to RIGHTCOL
ADD R3,R3,R0 ;
NOT R3,R3 ;
ADD R3,R3,#1 ;
ADD R3,R1,R3 ;
BRzp RIGHTCOL ; break on negative number
LD R3,NEXTC ; Here we do the same thing 4 times.. Uses NEXTR label (for next row)
ADD R5,R5,R3 ; ..but remember that the display pointer must now point to the next row's
;starting address
ADD R4,R4,#-1 ; subtract 1 from register which holds number of rows to make
; Can HALT here to ensure overwriting 4 pixels from top row
BRp RIGHTLOOP ;

;;
;; <==== LEFT FILL ====>
;;
;; Height <- 124 (0x7C)
;; 128 - 124 = 0x7C <- Distance to end of row

LD R5,VIDEO ; This is in preparation for drawing the top border, row by row. 
; Each row has length 80 decimal

LD R1,FOUR ; Initialize the width
LD R7,RED ; The value of a red pixel

LD R4, ONE24 ; We need 124 such rows of length 4 decimal each
LEFTLOOP LD R0,ZERO ; This loop repeats 124 times, once for each row
LEFTCOL STR R7,R5,#0 ; Storing a red pixel at the present display pointer, and incrementing the pointer
ADD R0,R0,#1 ;
ADD R5,R5,#1 ;
LD R3,ZERO ; In this loop, we check if the length limit has been reached. If not, we go
; back to LOOP1
ADD R3,R3,R0 ;
NOT R3,R3 ;
ADD R3,R3,#1 ;
ADD R3,R1,R3 ;
BRzp LEFTCOL ; break on negative number
LD R3,NEXTC ; Here we do the same thing 4 times.. Uses NEXTR label (for next row)
ADD R5,R5,R3 ; ..but remember that the display pointer must now point to the next row's
;starting address
ADD R4,R4,#-1 ; subtract 1 from register which holds number of rows to make
BRp LEFTLOOP ;

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
