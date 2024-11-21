; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2023
; Kevin M. Smallwood
; *******************

; darts segment - 11/15/2024

 on nocar goto link.term
 on error goto error

 print \sn$" Presents..."\
 print \ chr$(32,35) chr$(61,9)
 print chr$(32,37) "Darts"
 print chr$(32,35) chr$(61,9)


 print \ chr$(32,26) "\\\\\\"
 print chr$(32,27) "\\\\\\"chr$(32,16)"\"
 print chr$(32,31) "===================>"
 print chr$(32,27) "//////"chr$(32,16)"/"
 print chr$(32,26) "//////"

 print \"Have you ever played before";:yn=0:gosub GetYN
 if i$="N" f$="b:hlp.darts":gosub show.file

init
 r=0: a1=0: a2=0
start
 r=r+1
get.throw
 print \"Your throw (1-3, Q=Quit)";:l1$="123Q":gosub GetOne
 a3=val(i$)
 if i$="Q" print "Quit":goto link.game
 if (a3<1) or (a3>3) print "Invalid throw!":goto get.throw
 print \\"You throw ";:gosub get.stats:a1=a1+b

old.Man
 a3=random(2)+1:z$=rnd$:print \"The Old Man throws ";
 gosub get.stats:a2=a2+b

chk.for.win
 print \'At the end of round 'r',

   You have 'a1' points, and
   The Old Man has 'a2' points'

 if a1>=200 print \"Congratulations on a game well played!":goto again
 if a2>=200 print \"You lose pal...pay up...": goto again
 goto start

get.stats
 if a3=1 a5=650:a6=550:a7=500:a8=500:print "a fast overarm...":goto get.num
 if a3=2 a5=990:a6=770:a7=430:a8=010:print "a controlled overarm...":goto get.num
 if a3=3 a5=950:a6=750:a7=450:a8=050: print "an underarm..."

get.num
 a9=random(1000):z$=rnd$
 if a9>=a5 print "Bullseye!!  40 points!":b=40:return
 if a9>=a6 print "30 point zone!":b=30:return
 if a9>=a7 print "20 point zone!":b=20:return
 if a9>=a8 print "Lucky!  10 point zone!":b=10:return
 print "Missed the target!  Too bad.":b=0:return

again
 print "Would you like to play again";:yn=0:gosub GetYN
 if i$="Y" print sc$:goto init
 print \"Thanks for playing "a3$", hope you'll play again."

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
 print #1,"Error #"err" ("er$") occurred in DARTS.S at "time$" on "date$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."
 open #2,"b:snap.txt":copy #2,#1
 print #1,"----------------------------------------------------------------"
 close:kill "b:snap.txt"
 goto link.term
