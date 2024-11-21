; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2023
; Kevin M. Smallwood
; *******************

; blackjack segment - 11/15/2024

 on nocar goto link.term
 on error goto error

 gosub setup:gosub intro:gosub main

 print \"Your overall stats:"
 print \"Games won.........."b1
 print "Games lost........."b2
 print "Pushes............."b3
 print "$ won.............$"b4
 print "$ lost............$"b5\

 gosub cleanup:goto link.game

setup
 bw$="b:bj.win":create bw$
 open #1,bw$:input #1,win$,hh,rc$:close
 am=500:hg=2000:b1=0:b2=0:b3=0:b4=0:b5=0
 return

intro
 print \sn$" Presents..."\
 print \ chr$(32,33) chr$(61,13)
 print chr$(32,35) "Blackjack"
 print chr$(32,33) chr$(61,13)
 if win$="" goto intro2
 print \ chr$(32,26) "The bank was last broken by:"\
 print @(40-(len(win$)/2)) on$ win$ of$\
 print @29 "on "rc$" with $"hh
intro2
 print \ chr$(32,11) "Warning - Don't lose all your $, or you'll be thrown out!"
 return

cleanup
 bw$="":am=0:hg=0:b1=0:b2=0:b3=0:b4=0:b5=0:win$="":hh=0:rc$="":return

link.game
 link "a:main.seg","game"

link.term
 link "a:main.seg","term1"

main
 if yw=1 print \"Come on... the bank is broke!":return
 i$=""
 if am=0 print \"You're Broke - and outta here...Ha!!":return
 print \"Money left = $"am
 if am>hg print \\"The BANK is broke! Casino closed. Bye!":yw=1
 if am>hg hg=am:goto rec.win

 input "Enter bet (1-200, Q=quit):"i$:b=val(i$)
 if (i$="Q") return
 if b<1 print \"Come on chicken - you have to bet SOMETHING.":goto main
 if b>am print \"Sorry, you don't have that much left.":goto main
 if b>200 print \"House limit is $200.":goto main

blackjack
 x=0:gosub getnum:xx=a:gosub getnum:xy=a
 if xx=1 and xy=10 then x=21:goto black.2
 if xy=1 and xx=10 then x=21:goto black.2
 x=xx+xy:if x>21 goto blackjack
 if x=2 then x=12

black.1
 y=0:gosub getnum:yy=a:gosub getnum:yx=a
 if yy=1 and yx=10 then y=21:goto black.2
 if yx=1 and yy=10 then y=21:goto black.2
 y=yy+yx:if y>21 goto black.1
 if y=2 then y=12

black.2
 z=0
 if x=21 print \"    Blackjack!  YOU win!":am=am+(b*2):goto bj.end
 if y=21 print \"    Blackjack!  Dealer wins!":am=am-(b*2):goto bj.end
 if x=y then nt=0:if x>16 print \"---- Push ----":goto bj.end
 print \"Dealer shows : "yx

bj.comm
 if x>21 print \"You are over 21":goto bj.result
 print "Your total  =  "x\\"H)it  D)ouble  S)tand ?)Help";
 l1$="HDS?":gosub GetOne
 if i$="?" print "Help":gosub bj.help:goto bj.comm
 if i$="H" print "Hit":gosub getnum:x=x+a:goto bj.comm
 if i$="S" print "Stand":goto stand1
 if i$="D" print "Double":goto bj.double

bj.help
 print \\"This game is based on '21', also called 'Black Jack'"
 print "The object of the card game and this game is to get"
 print "as close to 21 points as possible. If you go over"
 print "21 you lose."
 print \\"COMMANDS: "
 print "---------"
 print "H)it Command    - Take another card."
 print "S)tand Command  - Stay where you are at."
 print "D)ouble Command - Double your bet. (Only 1 more card)."
 print "?) Help Command - This Black Jack Help File."
 print \
 return

stand1
 goto com.turn

bj.double
 b=b*2:an=1
 if am<b print \\"You don't have enough to double your bet!":an=0
 if an=0 b=b/2:goto bj.comm
 gosub getnum:x=x+a:gosub getnum:y=y+a:z=1:goto bj.result
 return

bj.result
 if x>21 then nt=0:if y>21 print \"PUSH - Both over 21.":b3=b3+1:goto bj.end
 if x=y print \"---- Push ----":b3=b3+1:goto bj.end
 if y>21 nt=0:if x<22 print \\"You win!":am=am+b:b1=b1+1:b4=b4+b:goto bj.end
 if x>21 nt=0:if y<22 print \\"Dealer wins!":am=am-b:b2=b2+1:b5=b5+b:goto bj.end
 if x>y nt=0:if x<22 print \\"You win!":am=am+b:b1=b1+1:b4=b4+b:goto bj.end
 if y>x nt=0:if y<22 print \\"Dealer wins!":am=am-b:b2=b2+1:b5=b5+b

bj.end
 print \"Your total     = "x
 print "Dealer's total = "y:print \:goto main

com.turn
 if y>16 goto bj.result
 gosub getnum:y=y+a:goto com.turn

rec.win
 win$=a3$
 kill bw$:create bw$
 open #1,bw$:append #1
 print #1,win$,am,date$
 close
 return

link.game
 link "a:main.seg","game"

link.term
 link "a:main.seg","term1"

getnum
 o$=rnd$
 if o$="A" or o$="Z" then a=1
 if o$="B" or o$="Y" then a=2
 if o$="C" or o$="X" then a=3
 if o$="D" or o$="W" then a=4
 if o$="E" or o$="V" then a=5
 if o$="F" or o$="U" then a=6
 if o$="G" or o$="T" then a=7
 if o$="H" or o$="S" then a=8
 if o$="I" or o$="R" then a=9
 if o$="J" or o$="Q" then a=10
 if o$="K" or o$="P" then a=10
 if o$="L" or o$="M" or o$="N" or o$="O" then a=10
 return

; *** Sub - Routines ***

; get a key
; l1$ is the list of available keys
getone
 print ": ";
getone.2
 get i$
 if instr(i$,l1$) return
 goto getone.2

; This routine gets a Yes/No answer
; A prompt is printed, hilighting the default
; response (if any)

; Input parameters are:

; yn	= 0:	No default
; yn	= 1:	Default is yes
; yn	= 2:	Default is no

getyn
 print " (";:l1$="YN"
 if yn:l1$=l1$+chr$(13)
 if yn=1 print "["on$"Y"of$"]";:else print "Y";
 print "/";
 if yn=2 print "["on$"N"of$"]";:else print "N";
 print ")";:gosub getone

 if i$=chr$(13):i$=mid$("YN",yn,1)
 if i$="Y" print "Yes":else print "No"
 yn=0:return

; show a disk file
show.file
 setint(1):print \s$\:open #1,f$:if mark(1) close #1:return
showfl2
 copy (20) #1
 if (eof(1) or key(1)) setint(""):close #1:return
 if not flag(35) goto showfl2
 print "Press ["on$"RETURN"off$"] ";:get i$:if i$=chr$(13) print " ";
 print chr$(8,16);chr$(32,16);chr$(8,16);
 if i$=" " setint(""):close #1:return
 setint(1):goto showfl2

;get minutes online & time limit
time
 x=(clock(2)-clock(1))/60:y=clock(2):x$=right$("0"+str$(x),2)
 if clock(1)>clock(2) x$="!!"
 if x=0 x$="--"
 if not y x$="**"
 if info(5) x$="::"
 return

; report an error
error
 close:on error:
 use "b:snapshot","b:snap.txt"
 print\sc$"A fatal error has occured. One moment, please..."\
 open #1,"b:error.list":position #1,32,err:input #1,er$:close
 f$="b:sys.errors":create f$:open #1,f$:append #1
 print #1,"Error #"err" ("er$") occurred in BLACKJACK.S at "time$" on "date$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."
 open #2,"b:snap.txt":copy #2,#1
 print #1,"----------------------------------------------------------------"
 close:kill "b:snap.txt"
 goto link.term
