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

LD R5,VIDEO
LD R7,RED ; Pixel color

LD R1,RMAX ; Set inner iterator bound check

LD R4,FOUR

TIMES4

  LD R0,ZERO
  LOOP1

    STR R7,R5,#0 ; Set pixel color

    ADD R0,R0,#1 ; Increment relative pixel position
    ADD R5,R5,#1 ; Increment absolute pixel position

    ;; Check if relative pixel position has exceeded bounds
    LD R3,ZERO
    ADD R3,R3,R0
    NOT R3,R3
    ADD R3,R3,#1
    ADD R3,R1,R3

    BRzp LOOP1

  LOOP1_END

  ;; Increment absolute pixel position to next row
  LD R3,NEXTR
  ADD R5,R5,R3

  ADD R4,R4,#-1 ; Decrement outer loop iterator

  BRp TIMES4

TIMES4_END

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

DRAW_SIDES ; Controls for each row

  LD R1,FOUR ; Iterator bound
  LD R0,ZERO ; Reset relative pixel counter

  DRAW_LEFT

    STR R7,R5,#0 ; Controls drawing pixels in each row
    ADD R0,R0,#1 ; Increment relative counter
    ADD R5,R5,#1 ; Increment absolute counter

    ADD R1,R1,#-1
    BRzp DRAW_LEFT

  DRAW_LEFT_END

  ;; Increment absolute pixel position by next side pixel difference
  LD R3,NEXTSIDE
  ADD R5,R5,R3

  LD R1,FOUR
  LD R0,ZERO

  DRAW_RIGHT

    STR R7,R5,#0 ; Controls drawing pixels in each row
    ADD R0,R0,#1 ; Increment relative counter
    ADD R5,R5,#1 ; Increment absolute counter

    ADD R1,R1,#-1
    BRzp DRAW_RIGHT

  DRAW_RIGHT_END

  LD R3,INCRSIDE
  ADD R5,R5,R3

  ADD R4,R4,#-1
  BRp DRAW_SIDES

DRAW_SIDES_END

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
DRAW_BRICKS ; Loop draws each row for each brick

  LD R2, THREE ; DRAW_IN_ROW iterator
  DRAW_IN_ROW ; Loop used to draw each brick row in row

    LD R0,ZERO ; Relative pointer position, used for drawing
    LD R1,BRICKWIDTH ; DRAW_BRICK_ROW iterator

    DRAW_BRICK_ROW ; Loop used to draw the brick row
      STR R7,R5,#0  

      ;; Increment pointer position
      ADD R0,R0,#1
      ADD R5,R5,#1
      ADD R1,R1,#-1 ; R1-- decr iterator
      
      BRzp DRAW_BRICK_ROW ; If length remaining is >= 0 then loop
    DRAW_BRICK_ROW_END

    ADD R5,R5,#4
    ADD R2,R2,#-1 ; R2-- decr iterator
    BRzp DRAW_IN_ROW ; If number of bricks to draw is >= 0 then loop

  DRAW_IN_ROW_END

  LD R3,BRICKNEXTROW
  ADD R5,R5,R3 ; Set absolute pointer to next row start
  LD R3,ZERO ; Reset register
  ADD R4,R4,#-1 ; R4-- decr iterator

  BRzp DRAW_BRICKS ; If number of rows remaining is >= 0 then loop

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
NEXTSIDE .FILL x0050
INCRSIDE .FILL x0028

BRICKSTART .FILL x0408
BRICKHEIGHT .FILL x0004
BRICKSPACE .FILL x0004
BRICKWIDTH .FILL x0014
BRICKNEXTROW .FILL x0035

SIDE .FILL xC200
.end
