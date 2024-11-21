********************************
*                              *
*    Config Program - Start    *
*                              *
********************************

*-------------------------------
* Date: 5/29/91
*-------------------------------

begin sta $c051 ;text mode
 sta $c00e ;Turn MouseText off
 bit $c082

 lda #<do_quit ;fudge reset vector
 sta reset
 lda #>do_quit
 sta reset+1
 eor #$a5
 sta reset+2

 ldx #$f0 ;reset stack
 txs

 jsr findcon ;find the config disk,logit

 jsr VideoStartup ; Init the video driver
 jsr do_main

* jmp loadg ;force to reconfig

 jsr cls ; clear screen
 jsr print
 db 1,7,0
 asc 'When  you do an  initial configure, all',0d
 asc 'previous  data  will be  destroyed  and',0d
 asc 'replaced with the new configuration.',0d,0d,0d,00

 jsr print
 asc '       ALL OLD DATA WILL BE LOST!',0d,0d,0d,00

 jsr print
 asc 'Do you want to do an Initial',0d
 asc 'Configure [Y/N] ? ',00
 jsr inpyn ; input yes/no

 bcs loadg
 jsr ldacos ; load in acos file
 jmp doinit ; do initial config

srcblocks db 0

*-------------------------------

loadg jsr ldconfg ; load config segment

start lda #0 ; turn off escape handler
 sta refnum
 jsr escape
 jsr close ; close all files
 jsr logcon

 jsr do_main

 jsr cls ; clear screen
 jsr print
 asc 'Select an Option:',0d,0d
 asc '     1 - Reconfigure Modem',0d
 asc '     2 - Reconfigure Video',0d
 asc '     3 - Reconfigure Printer',0d
 asc '     4 - Reconfigure Clock',0d
 asc '     5 - Reconfigure Storage',0d
 asc '     6 - Edit Profanity Filter',0d
 asc '     7 - Edit Bulletin Board Info',0d
 asc '     8 - Sort and Print Userlist',0d
 asc '     9 - Purge Users From System',0d
 asc '    10 - Exit Configure',0d,0d

 asc 'Which? [1-10] ',00

 ldx #10 ; get a number [1-10]
 jsr inpnum

 pha
 ldx #<start
 lda #>start
 jsr escape ;esc goes back to here
 pla
 asl a
 tax

 lda jumptable,x
 sta prn
 inx ;push low
 lda jumptable,x
 sta prn+1
 jmp (prn)

jumptable dw 0
 da re_mdm
 da re_vid
 da re_pr
 da re_clk
 da re_stor
 da do_filt
 da brdedit
 da usrlist
 da usrkill
 da do_quit

*-------------------------------
* print the top box

do_main jsr TopBox
 jsr print
 db 1,2,3
 asc 'GBBS Config Program - Version 2.4',00
 jsr print
 db 1,4,2
 asc 'Copyright 1986-2024 Kevin Smallwood',00
 rts

*-------------------------------

init db 0

usrname db 5
 asc 'USERS'
gname db 8
 asc 'ACOS.OBJ'
