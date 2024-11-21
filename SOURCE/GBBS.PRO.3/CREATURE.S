; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2023
; Kevin M. Smallwood
; *******************

; creature segment - 11/15/2024

 on nocar goto link.term
 on error goto error

start
 am=150:rk=10:st=10:mq=15
 print \sn$" Presents..."\
 print \ chr$(32,29) chr$(61,21)
 print chr$(32,31) "The Creature Game"
 print chr$(32,29) chr$(61,21)
 print \\"You are about to meet your demise..."

 print \"Have you played before";:yn=0:gosub GetYN
 if i$="N" f$="b:hlp.creature":gosub show.file
 goto begin

reset
 rk=10:st=10:mq=15
 print \"Would you like to continue";:yn=0:gosub GetYN
 if i$="N" goto link.game

begin
 x$=rnd$:x=(random(999) mod 3)+1

begin2
 fl=0:if rk<1 then fl=1
 print \"You are "st" step(s) from the Swamp's end."
 print "You have "rk" rock(s) in your pocket."
 print "The CREATURE is "mq" step(s) behind you."

 print \\"Action (1=step, 2=stay, 3=rock, Q=Quit)";
 l1$="123Q":gosub GetOne
 if i$="Q" print "Quit":goto link.game
 ac=val(i$)
 if ac=3 print "Throw a rock"
 if (fl=1) and (ac=3) goto begin
 if ac=1 print "Take a step.":goto take.step
 if ac=2 print "Stay put":goto stay.put

; throw.rock
 print \"Throw (1=left 2=right 3=straight, Q=Quit)";
 l1$="123Q":gosub GetOne
 if i$="Q" print "Quit":goto link.game
 wx=val(i$):fl=1
 if wx=1 print "Left"
 if wx=2 print "Right"
 if wx=3 print "Straight"
 if x<>wx print \"You hear it SPLASH !!!"
 if x=wx print \"You hear it THUD !!!"
 rk=rk-1
 if mq<1 then goto ending
 goto begin2

take.step
 print \"Step (1=left 2=right 3=straight, Q=Quit)";
 l1$="123Q":gosub GetOne
 if i$="Q" print "Quit":goto link.game
 wx=val(i$):fl=1:x$=rnd$
 if wx=1 print "Left"
 if wx=2 print "Right"
 if wx=3 print "Straight"
 if wx<>x then print \"SPLASH!!!  You're sinking fast!!!"
 z=(random(999) mod 3)+1
 if (wx<>x) and (z=1) mq=mq-1:print \"But you pull yourself out!!!"
 if (wx<>x) and (z<>1) print \"You can't get out":goto ending2
 if wx=x then st=st-1:print \"You stepped safely..."
 if mq<1 then goto ending
 if st<1 then goto ending3
 goto begin

stay.put
 mq=mq-1:if mq>0 then goto begin2

ending
 print "The SWAMP CREATURE has caught you!!! As he feasts on your flesh he says..."
 print \a3$" tastes DELICIOUS!!!"
 goto lose50

ending2
 print "You sink slowly in quicksand and die. Alas, poor "a3$"..."
 print "We knew you well...."

lose50
 am=am-50
 print \"You lost 50 points. You now have "am" points left."
 if am>49 goto reset
 goto link.game

ending3
 print \\"YOU MADE IT !!! Hooray for "a3$" !!!"
 print \"The SWAMP CREATURE turns and walks away.  He will be here waiting
for"
 print "you NEXT TIME !!!'
 goto points

points
 am=am+100
 print \"Adding 100 points. You now have "am" points."
 if am>49 goto reset

link.game
 link "a:main.seg","game"

link.term
 link "a:main.seg","term1"


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
 open #1,f$:if mark(1) close #1:return
 setint(1):print \s$\
showfl2
 copy (20) #1
 if (eof(1) or key(1)) setint(""):close #1:return
 if not flag(35) goto showfl2
 print "Press <"on$"RETURN"of$"> ";:l1$=chr$(13):gosub getone
 print chr$(8,17);chr$(32,17);chr$(8,17);
 if i$=" " setint(""):close #1:print:return
 setint(1):goto showfl2

; report an error
error
 close:on error:
 use "b:snapshot","b:snap.txt"
 print\sc$"A fatal error has occured. One moment, please..."\
 open #1,"b:error.list":position #1,32,err:input #1,er$:close
 f$="b:sys.errors":create f$:open #1,f$:append #1
 print #1,"Error #"err" ("er$") occurred in CREATURE.S at "time$" on "date$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."
 open #2,"b:snap.txt":copy #2,#1
 print #1,"----------------------------------------------------------------"
 close:kill "b:snap.txt"
 goto link.term
