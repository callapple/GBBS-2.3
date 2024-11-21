; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2024
; Kevin M. Smallwood
; *******************

; bbs listing segment - 11/10/2024

 on nocar goto link.term
 on error goto error

main
 gosub time
 print \"["x$"]["on$"BBS List"of$"] Option (?=Help)";
 l1$="ADELQST?":gosub getone:push main

main.cmd
 if i$="A" print "Add":zz=0:goto add
 if i$="D" print "Delete":goto delete
 if i$="E" print "Edit":goto edit
 if i$="L" print "List":z=0:goto list
 if i$="Q" print "Quit":goto link.main
 if i$="S" print "Search":goto search
 if i$="T" print "Terminate":goto terminate
 if i$="?" print "Menu":f$="b:mnu.bbslist":goto show.file

add
 print \"Add a number to the list";:yn=1:gosub getyn
 if i$="N" return

name
 print \"Name of BBS [25 chars max]"
 input @3 ":"na$:if na$="" return
 if len(na$)>25 print \"25 characters only, please.":goto name
 if len(na$)<2 print \"Too short.":goto name
 if zz goto info.confirm

phone
 print \"Number/address:port of BBS [6-30 chars]"
 input @3 ":"hp$:if i$="" return
 if len(hp$)>30 print \"30 characters only, please.":goto phone
 if len(hp$)<6 print \"Too short.":goto phone
 if zz goto info.confirm

type
 print \"Computer type"
 gosub pr.types
 print \"Which? (1-9)";:l1$="12345679":gosub getone 
 x$="GBSAPLIBMTI COMTRSMACATAUNK":x1=(val(i$)-1)*3+1
 sf$=mid$(x$,x1,3):print sf$
 if zz goto info.confirm

updown
 print \"Does "na$" offer Uploads/Downloads";
 yn=1:gosub getyn:dn$=i$
 if zz goto info.confirm

game
 print \"Does "na$" offer Online Games";
 yn=1:gosub getyn:ga$=i$
 if zz goto info.confirm

rpg
 print \"Does "na$" offer Role Playing Games";
 yn=1:gosub getyn:ro$=i$

info.confirm
 zz=1
 print sc$ \"(*> Information Entered <*)"\
 print "1) Bulletin Board Name.:"na$
 print "2) Phone/Address.......:"hp$
 print "3) Computer Type.......:"sf$
 if dn$="Y" then i$="Yes":else i$="No"
 print "4) Uploads Downloads...:"i$
 if ga$="Y" then i$="Yes":else i$="No"
 print "5) Online Games........:"i$
 if ro$="Y" then i$="Yes":else i$="No"
 print "6) Role Playing Games..:"i$

 print \"Option [1-6, S)ave, A)bort]";
 l1$="123456AS":gosub getone
 if i$="A" print "Abort":return
 if i$="1" print "Name":goto name
 if i$="2" print "Phone/address":goto phone
 if i$="3" print "Type":goto type
 if i$="4" print "Uploads Downloads":goto updown
 if i$="5" print "Online Games":goto game
 if i$="6" print "Role Playing Games":goto rpg

 print "Save":nt$=sf$
 if dn$="Y" then nt$=nt$+"-U/D"
 if ga$="Y" then nt$=nt$+"-Gam"
 if ro$="Y" then nt$=nt$+"-RPG"

write
 f$="b:bbs.list":create f$:open #1,f$
 position #1,128,0:input #1,ln:ln=ln+1
 if e1 ln=x:goto write1
 position #1,128,0:print #1,ln
write1
 position #1,128,ln
 print #1,un\na$\hp$\nt$:close #1
 zz=0:return

delete
 f$="b:bbs.list":create f$:open #1,f$
 position #1,128,0:input #1,ln
 if ln=0 print \"No listings to delete":close #1:return
 input @2 \"Delete which entry (#,<CR>):"x
 if x<1 close #1:return
 if x>ln print \"That one doesn't exist":close #1:return
 position #1,128,x
 input #1,y\na$\hp$\nt$
 if ((info(5)) or (y=un)) goto delete1
 print \"Not your listing!":close #1:return
delete1
 x=x+1
 for x1=x to ln
 position #1,128,x1
 input #1,y\na$\hp$\nt$
 position #1,128,x1-1
 print #1,y\na$\hp$\nt$
 next
 position #1,128,0
 print #1,ln-1:close #1:print \"Deleted.":return

edit
 f$="b:bbs.list":create f$:open #1,f$
 position #1,128,0:input #1,ln
 if ln=0 print \"No listings to delete":close #1:return
 input @2 \"Edit which entry (#,<CR>):"x
 if x<1 close #1:return
 if x>ln print \"That one doesn't exist":close #1:return
 position #1,128,x
 input #1,y\na$\hp$\nt$:close #1
 if ((info(5)) or (y=un)) goto edit1
 print \"Not your listing!":return
edit1
 sf$=left$(nt$,3)
 i$="U/D":if instr(i$,nt$) dn$="Y":else dn$="N"
 i$="Gam":if instr(i$,nt$) ga$="Y":else ga$="N"
 i$="RPG":if instr(i$,nt$) ro$="Y":else ro$="N"
 e1=1:gosub info.confirm
 return

search
 print \"Enter Search Key (1-6, ?, ["on$"Q"of$"]uit)";
 l1$="123456?Q"+chr$(13):gosub getone
 if (i$="Q") or (i$=chr$(13)) print "Quit":z=0:return
 if i$="?" print 'Search Keys

1) BBS Name
2) Phone #/Address:port
3) Computer Type
4) Uploads/Downloads
5) Online Games
6) Role-Playing Games':goto search

 z=1:i=val(i$)
 if i<3 goto search1
 if i=4 i$="U/D":goto list
 if i=5 i$="Gam":goto list
 if i=6 i$="RPG":goto list

 print "Computer type"
 gosub pr.types
 print \"Which? (1-9)";
 l1$="123456789"+chr$(13):gosub getone
 if i$=chr$(13) print:z=0:return
 x$="GBSAPLIBMTI COMTRSMACATAUNK":x1=(val(i$)-1)*3+1
 i$=mid$(x$,x1,3):goto list
 
search1
 if i=1 print "Name"
 if i=2 print "Phone/Address"
 input @2 \"Search string: "i$
 if i$="" z=0:return

list
 print sc$ \"Num  Name                       Phone/Address                   ";
 print "Notes"
 print "---  -------------------------  ------------------------------  ";
 print "---------------"
 f$="b:bbs.list":create f$:open #1,f$
 position #1,128,0:input #1,ln
 if ln=0 then close #1:return
 for x=1 to ln
 position #1,128,x
 input #1,y\na$\hp$\nt$
 if ((z) and (i=1)) and (not instr(i$,na$)) next:close #1:return
 if ((z) and (i=2)) and (not instr(i$,hp$)) next:close #1:return
 if ((z) and (i>2)) and (not instr(i$,nt$)) next:close #1:return
 setint(1):print right$("   "+str$(x),3)"  "left$(na$+chr$(32,25),25);
 print "  "left$(hp$+chr$(32,30),30)"  "nt$
 if key(1) x=ln:setint("")
 next:close #1:return

; terminate from system and recycle
terminate
 print \"Terminate from "sn$
 print \"Are you sure";:yn=2:gosub getyn
 if i$<>"Y" return

link.term
 link "a:main.seg","term1"

link.main
 link "a:main.seg","fromsys"

; *** sub - routines ***

; show computer types

pr.types
 print '
1) GBBS              6) TRS
2) Other Apple       7) MAC
3) IBM               8) Atari
4) TI PC             9) Other/Unknown
5) Commodore'
 return

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

; get time remaining before logoff
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
 print #1,"Error #"err" ("er$") occurred in BBSLIST.SEG.S at "time$" on "date$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."
 open #2,"b:snap.txt":copy #2,#1
 print #1,"----------------------------------------------------------------"
 close: kill "b:snap.txt"
 goto link.term
