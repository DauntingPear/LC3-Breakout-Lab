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

LD R5,VIDEO ; This is in preparation for drawing the top border, row by row. Each row has
; length 80 decimal
LD R1,RMAX ;
LD R7,RED ; The value of a red pixel

;; TOP SIDE
LD R4,FOUR ; We need 4 such rows of length 80 decimal each
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
BRzp LOOP1 ;
LD R3,NEXTR ; Here we do the same thing 4 times..
ADD R5,R5,R3 ; ..but remember that the display pointer must now point to the next row's
;starting address
ADD R4,R4,#-1 ;
BRp TIMES4 ;

;; LEFT AND RIGHT SIDES
;; Here you will write the code which will draw the left and right walls with the spacing
;; and dimensions listed in the homework problem. There should be 76 pixels of space between
;; the inside of the left and right walls, and the left and right walls should be 4 pixels.

;; BRICKS
;; Here you will draw the three bricks with spacing and dimensions as listed in the homework.
;; Bricks should be 4x20, and have 4 pixels between themselves and the walls and other bricks.
;; It is suggested you use a different color for bricks than for walls.
HALT

;;And now define all the constants we need...
VIDEO .FILL xC000
DISPSIZE .FILL x2E00
ZERO .FILL x0000
RMAX .FILL x0053
RED .FILL x7C00
BLACK .FILL x0000
FOUR .FILL x0004
NEXTR .FILL x002C
SIDE .FILL xC200
.end
