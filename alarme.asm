LEDS  equ $E003
SWITCHS  equ $E001
X        equ        $E020
Y        equ        $E022
CTRL     equ        $E024
SOUND   equ     $E031
BLACK    equ        0
BLUE     equ        1
GREEN    equ        2
RED      equ        4
CYAN     equ        GREEN+BLUE
MAGENTA  equ        RED+BLUE
YELLOW   equ        RED+GREEN
WHITE    equ        RED+GREEN+BLUE
TRANSP   equ        8
LF         equ         $0A             ; ASCII code for linefeed
CR         equ         $0D             ; ASCII code for carriage return
PORTE      equ         150
mouseX     equ         $E027           ; x position of mouse
mouseY     equ         $E029           ; y position of mouse
mouseflags equ         $E02A           ; mouse event flags
mouseint   equ         $E02B           ; mouse interrupt enable flags and IRQ level
; mouse interrupt vector address
           org         $100
           dc.l        mouseproc
         include    drawpad.inc
* Programs in user mode cannot be run below address $10000!
        org     $1000           this will generated an exception
*       org     $10000          this is OK

           lea code,a1
           lea BUF,A0
           move.b #0,d4
           move.b #0,d3
           move.b #0,d5
           trap     #15
           dc.w     36             ; show drawpad
           backgrnd   WHITE
           txtout     30,50,txt1,BLACK,3
           line       30,80,320,80,GREEN,2
           rect       200,100,100,200,WHITE,BLACK,2
           *Fenetre gauche
           rect        100,130,120,132,BLACK,BLACK,1
           *Fenetre droite
           rect        180,130,200,132,BLACK,BLACK,1
           *Porte principale
           rect        149,170,151,200,BLACK,BLACK,1
           txtout     150,220,txt2,BLACK,1
*rect     macro      left,top,right,bottom,color,border,width



start
          move.b      #$A5,mouseint   ; left and right button down, mouse moved, IRQ=2
          move.w      #$2000,SR       ; enable all interrupt levels
          bra         *               ; wait for interrupt
; mouse interrupt procedure
mouseproc  movem.l     D0/A0,-(A7)     ; save all registers used in this procedure
lbutton    btst        #0,mouseflags   ; test if left button is clicked
           beq.s       mousemove
           lea         text1,A0        ; yes, print message
           move.b      mouseX,D0       ; print mouse position
           move.b      #0,d4
           cmpi.b      #150,D0
           beq         alarme
           move.b      mouseY,D0
           cmpi.b      #131,D0
           beq         voleur
           bsr.s       prtstr
           bra.s       ready
mousemove  clr.l       D0              ; must be mouse moved
           lea         text3,A0
           bsr.s       prtstr
           move.b      mouseX,D0       ; print mouse position
           bsr.s       prtstr
           bsr.s       prtnum
           lea         text4,A0
           bsr.s       prtstr
           move.b      mouseY,D0
           bsr.s       prtnum
           lea         text5,A0
           bsr.s       prtstr
ready      clr.b       mouseflags  ; Reinitialisation du mouseflag
           movem.l     (A7)+,D0/A0
           rte

prtnum     trap        #15
           dc.w        5
           rts

prtstr     trap        #15
           dc.w        7
           rts
correct
           rect    149,170,151,200,GREEN,GREEN,1 ; Change la couleur de la porte en vert
           move.l  #good,SOUND+1
           move.b  #5,SOUND
           bra     stop
voleur
           move.l  #alarm,SOUND+1
           move.b  #5,SOUND
           rect    149,170,151,200,RED,RED,1 ; Change la couleur de la porte en rouge
           *Fenetre gauche
           rect        100,130,120,132,RED,RED,1
           *Fenetre droite
           rect        180,130,200,132,RED,RED,1
           bra stop
alarme
           trap #15
           dc.w 8
           lea     Code,A1
           move.l (a1),d1
           move.l (a0),d2
           cmp d1,d2
           beq correct
           move.l  #no,SOUND+1
           move.b  #5,SOUND
           add.b #1,d4
           cmp #4,d4
           bne alarme
           rect    149,170,151,200,RED,RED,1 ; Change la couleur de la porte en rouge
           *Fenetre gauche
           rect        100,130,120,132,RED,RED,1
           *Fenetre droite
           rect        180,130,200,132,RED,RED,1
           move.l  #alarm,SOUND+1
           move.b  #5,SOUND

stop



        stop    #$2700          this will generated a privilege violation
*       trap    #15             this is OK
*       dc.w    0

* Numbers cannot be stored below address $10000 in user mode
        org     $2000           this will generate a protection exection
*       org     $20000          this is OK

Code dc.b  "code",0
BUF ds.l 80
no    dc.b    'no.wav',0
alarm    dc.b    'alarm.wav',0
good    dc.b    'correct.wav',0
txt1     dc.b       'Systeme d alarme',0
txt2     dc.b       'Cliquez sur la porte ou les fenetres pour essayer d acceder',0
text1      dc.b        'left button',CR,LF,0
text2      dc.b        'right button',CR,LF,0
text3      dc.b        'mouse: x=',0
text4      dc.b        ' y=',0
text5      dc.b        CR,LF,0