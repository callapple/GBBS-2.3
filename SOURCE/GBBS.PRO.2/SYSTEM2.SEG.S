; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2024
; Kevin M. Smallwood
; *******************

; system2 segment - 12/30/2023

; control program flow from other segments

dispatch
 on nocar goto link.term
 on error goto error

 push dreturn
 if l$="BOARDS" goto maintbrd
 if l$="CONFIG" goto config
 if l$="FLAGS" goto ed.flags
 if l$="LOGS" goto log
 if l$="USERLIST" goto userlist
dreturn
 if z$ link y$,z$:else link y$

terminate
 print \"Terminate from "sn$
 print \"Are you sure";:yn=2:gosub getyn
 if i$<>"Y" return

link.term
 link "a:main.seg","term1"

log
 print  \"(*> System Logs <*)"\
 print "1 -> System log"
 print "2 -> Error log"\
 print "Which log (1-2, Q=Quit)";
 l1$="12Q":gosub getone
 if i$="Q" print "Quit":return
 if i$="1" print "System log":goto log.system
 if i$="2" print "Error log":goto log.error
 goto log
log.system
 print \"System Log: D)elete, S)how, P)rint, "on$"Q"of$")uit";
 l1$="DSPQ"+chr$(13):gosub getone
 if i$="D" print "Delete":kill "b:log.system":goto log
 if i$="S" print "Show":f$="b:log.system":gosub show.file
 if i$="P" print "Print":setint(1):copy "b:log.system",#5:setint("")
 if (i$="Q") or (i$=chr$(13)) print "Quit":goto log
 goto log.system
log.error
 print \"Error Log: D)elete, S)how, P)rint, "on$"Q"of$")uit";
 l1$="DSPQ"+chr$(13):gosub getone
 if i$="D" print "Delete":kill "b:sys.errors":goto log
 if i$="S" print "Show":f$="b:sys.errors":gosub show.file
 if i$="P" print "Print":setint(1):copy "b:sys.errors",#5:setint("")
 if (i$="Q") or (i$=chr$(13)) print "Quit":goto log
 goto log.error

; edit boards
maintbrd
 open #1,"b:data2"
 mark(1)=1120:input #1,ab:close
 gosub time:print \"["x$"]["on$"Board Maint."off$"] Option (?=Help)";
 l1$="ACDELPQS?":gosub getone:push maintbrd
 if i$="P" print "Purge":goto clr.brd
 if i$="A" print "Add":goto add.brd
 if i$="D" print "Delete":goto del.brd
 if i$="E" print "Edit":goto ed.brd
 if i$="S" print "Swap":goto sw.brd
 if i$="L" print "List":goto lst.brd
 if i$="C" print "Create Storage File":goto stocre
 if i$="Q" print "Quit back":pop:return
 print "Help"

 setint(1):print sc$ s$\'
:::::::::::::::::::::::::::::::::::::::
: Board Maintenance  Section Commands :
:::::::::::::::::::::::::::::::::::::::
:      A - Add a Subboard             :
:      C - Create a Storage File      :
:      D - Delete a Subboard          :
:      E - Edit a Subboard            :
:      L - List all Subboards         :
:      P - Purge all Subboards        :
:      S - Swap two Subboards         :
:      Q - Quit back                  :
:::::::::::::::::::::::::::::::::::::::'
 return

; list boards
lst.brd
 print \"Do you want the list sent to your"\"printer";:yn=2:gosub getyn
 if left$(i$,1)<>"Y" s=0:else s=5
 print #s,\"###  Board Name                  File  "
 print #s, "---------------------------------------"
 open #1,"b:data2":mark(1)=1120:input #1,ab
 for l=1 to ab:position #1,128,l+8:input #1,bn$\bf$
 w1$=right$("00"+str$(l),3):if instr(left$(bn$,1),"%$#"):bn$=mid$(bn$,2)
 bn$=left$(bn$+chr$(32,26),26):print #s,w1$"  " bn$"  "bf$:next:close
 print \"Press <"on$"RETURN"off$"> to continue...";:get i$
 print chr$(8,29)chr$(32,29)chr$(8,29)
 return

; clear all boards
clr.brd
 print \"This operation will delete your board"\"configuration."
 print \"Do you wish to continue";:yn=2:gosub getyn
 if i$<>"Y" return
 open #1,"b:data2":mark(1)=1120:input #1,ab
 if ab=0 close:return
 for i=1 to ab:position #1,128,i+8
 input #1,bn$\bf$:kill bf$
 next:mark(1)=1120:print #1,0:close:ab=0
 goto add.brd1

; add a board
add.brd
 print \"Do you wish to add another board to"
 print "your system";:yn=2:gosub getyn
 if i$<>"Y" return
add.brd1
 nb=1:open #1,"b:data2":mark(1)=1120:input #1,ab:close
 bb=ab+1:bn$="New Board":bf$="F:B"+str$(bb)
 b3=1:b4=1:bs=0:bs$="":mb=128:kl=128:kb=1:goto ed.brd2

; edit a board
ed.brd
 open #1,"b:data2":mark(1)=1120:input #1,ab
 nb=0:print \"System has boards from 1-"ab
ed.brd1
 print \"Edit Board (1-"ab", Q=Quit) ?";:input @2 ""i$:bb=val(i$)
 if left$(i$,1)="Q" or i$="" close:return
 if (bb<1) or (bb>ab) print \on$"Invalid number."off$:goto ed.brd1
 position #1,128,bb+8:input #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb:close
ed.brd2
 print sc$:if bs=0:bs$=""
 if bs$="" and (bs=0) w2$="[ No Aux Sysop ]"
 if bs$="" and (bs>0) w2$="[ Use Real Name ]"
 if bs$<>"" and (bs>0) w2$=bs$
 print  \" 1) Name: "bn$"  [#"bb"]"\" 2) File: "bf$
 print \\" 3) Access: "b3"  4) Write: "b4
 print \" 5) Aux Sysop Numb: "bs\" 6) Aux Sysop Name: "w2$
 print \" 7) Max  # of bulletins: "mb\" 8) Auto kill threshold: "kl
 print " 9) Bulletin # to kill: "kb
 print \"10) Abort without Saving"\"11) Save changes and Quit"
 input \"Option (1-11):" i$:a=val(i$)
 if a=1 input @3 \"Board Name: "i$:if i$<>"" bn$=i$
 if a=2 input @2 \"File: "i$:if i$<>"" bf$=i$
 if a=3 input @2 \"Access Flag: "i$:if i$<>"" b3=val(i$)
 if b3>b4 then b4=b3
 if a=4 input @2 \"Write Flag: "i$:if i$<>"" b4=val(i$)
 if b4<b3 then b3=b4
 if a=5 input @2 \"Aux Sysop #: "i$:if i$<>"" bs=val(i$):gosub ed.brd3
 if a=6 print \"Aux Sysop Name: "bs$chr$(8,len(bs$));
 if a=6 input @3 i$:if i$<>"" bs$=i$
 if a=7 input @2 \"Max # of Messages (1-1024): "i$:if i$<>"" mb=val(i$)
 if mb>1024 then mb=1024
 if mb<1 then mb=1
 if mb<kl then kl=mb
 if mb<kb then kb=mb
 if a=8 input @2 \"Auto Kill Threshold: "i$:if i$<>"" kl=val(i$)
 if kl<0 then kl=0
 if kl>mb then kl=mb
 if a=9 input @2 \"Bulletin # to Kill: "i$:if i$<>"" kb=val(i$)
 if kb<1 then kb=1
 if kl=0 then kb=0
 if kb>mb then kb=mb
 if a=10 return
 if a<>11 goto ed.brd2
 print \"Updating..";
 open #1,"b:data2":position #1,128,bb+8
 print #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb
 if nb=1 mark(1)=1120:print #1,bb
 close:print ".board #"bb" updated."
 if nb=1 print \"Create board storage file":goto stocre2
 return
ed.brd3
 open #1,"b:users"
 position #1,128,bs
 input #1,a$,b$\c$:close
 if a$<>"" bs$=c$:return
 print \on$"That user does not exist"off$
 if (bs$="") or (bs=0) bs=0:bs$=""
 return

; delete a board
del.brd
 open #1,"b:data2":mark(1)=1120:input #1,ab
 nb=0:print \"System has boards from 1-"ab
del.brd1
 print \"Delete # (1-"ab", Q=Quit) ?";:input @2 ""i$:bb=val(i$)
 if left$(i$,1)="Q" or i$="" return
 if (bb<1) or (bb>ab) print \on$"Invalid number."off$:goto del.brd1
 position #1,128,bb+8:input #1,bn$\bf$
 print \"Delete "bn$;:yn=2:gosub getyn
 if i$<>"Y" close:return
 kill bf$:ab=ab-1:mark(1)=1120:print #1,ab:if bb=(ab+1) close:return
 for l=bb to ab-1
 position #1,128,l+9:input #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb
 position #1,128,l+8:print #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb
 next:close:return

; swap two boards
sw.brd
 open #1,"b:data2":mark(1)=1120:input #1,ab
 nb=0:print \"System has boards from 1-"ab
sw.brd1
 print  \"Swap Board (1-"ab", Q=Quit) ?";:input @2 ""i$:b1=val(i$)
 if left$(i$,1)="Q" or i$="" close:return
 if (b1<1) or (b1>ab) print \on$"Invalid number."off$:goto sw.brd1
sw.brd2
 print "With Board (1-"ab", Q=Quit) ?";:input @2 ""i$:b2=val(i$)
 if left$(i$,1)="Q" or i$="" close:return
 if (b2<1) or (b2>ab) print \on$"Invalid number."off$:goto sw.brd2
 if b2=b1 print \on$"Can't swap with itself!"off$:goto sw.brd2
 position #1,128,b1+8:input #1,bn$:print "Swap board: "bn$
 position #1,128,b2+8:input #1,bn$:print "With board: "bn$
 print \"Correct";:yn=1:gosub getyn
 if i$="N" close:return
 position #1,128,b1+8:input #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb
 position #1,128,b2+8:input #1,w1$\w2$\w3,w4\ws,ws$\wb,wl,kw
 position #1,128,b1+8:print #1,w1$\w2$\w3,w4\ws,ws$\wb,wl,kw
 position #1,128,b2+8:print #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb
 close:return

; create board storage file
stocre
 open #1,"b:data2":mark(1)=1120:input #1,ab
 print \"Enter the number of the board you"
 print "wish to create a storage file for."
stocre1
 print \"Create board storage file for"\"board (1-"ab",Q=Quit) ?";
 input @2 ""i$:bb=val(i$)
 if i$="Q" or i$="" close:return
 if (bb<1) or (bb>ab) print \on$"Invalid number."off$:goto stocre1
 position #1,128,bb+8:input #1,bn$\bf$\b3,b4\bs,bs$\mb,kl,kb:close
stocre2
 input @2 \"Directory Capacity (Default=128): "a$:if a$="" a$="128"
 y=val(a$):if (y<1) or (y>1024) print on$"Invalid number. 1024 max"off$:goto stocre2
stocre3
 input @2 \"Storage Capacity  (Default=128k): "b$:if b$="" b$="128"
 if right$(b$,1)="K" or right$(b$,1)="k" then b$=left$(b$,(len(b$)-1))
 z=val(b$)
 if (z<1) or (z>(y*4)) print on$"Invalid number. "(y*4)"k max"off$:goto stocre3
 print \"Board Specifications:"
 print \"Name: "bn$\"File: "bf$
 print \"Max bulletins: "y\"Max Storage: "z"k"
 print \"Is the above correct";:yn=2:gosub getyn
 if i$<>"Y" return
 w1=0:w1=instr(":",bf$):w1$=mid$(bf$,1,w1):if w1$="" goto stocre5
 print "Make sure "w1$" is on-line."
 print \"Are you ready";:yn=2:gosub getyn
 if i$<>"Y" return
 open #1,bf$:x=mark(1):close:if not x goto stocre6

; create storage file up to 'y' entries with 'z' k in storage
stocre4
 y=(y/128)*128:z=(z/128)*128:l=(y/32)+(z/128)
 fill ram2,64,0:poke ram2,z/128:poke ram2+1,y/32
 ready " ":close:kill bf$
 create bf$:open #1,bf$
 write #1,ram2,8:fill ram2,64,0:for x=1 to l:write #1,ram2,64
 write #1,ram2,64:next:close:ready " "
 a$="T "+bf$+",BIN":use "b:xdos",a$
 print "Done.":return
stocre5
 print \"Error: This board does not have a drive"
 print "       specifier in its filename.
 print \"Press <"on$"RETURN"off$"> to continue...";:get i$
 print chr$(8,29)chr$(32,29)chr$(8,29)
 return
stocre6
 print \"Error: There is already a board storage"
 print "       file with this name. If you pro-"
 print "       cede, the messages in that file"
 print "       will be destroyed."
 print \"Do you wish to continue";:yn=2:gosub getyn
 if i$="Y" kill bf$:goto stocre4
 return

; edit flag descriptions
ed.flags
 print \"Select (V=View, E=Edit, Q=Quit)";:l1$="VEQ":gosub getone
 if i$="Q" print "Quit":return
 push ed.flags
 if i$="E" print "Edit":goto ed.flgs1

 print "View"
 open #1,"b:data2":for l=0 to 16
 position #1,32,l:input #1,a$:position #1,32,l+17:input #1,b$
 print right$(" "+str$(l),2)". "left$(a$+chr$(32,32),32)"  ";
 print right$(" "+str$(l+17),2)". "b$:next
 position #1,32,34:input #1,a$:print chr$(32,38)"34. "a$:close
 return
ed.flgs1
 input @2\"Edit text for flag #" i$:if i$="" return
 l=val(i$)
 if (l<0) or (l>34) print \"Invalid flag number":goto ed.flgs1
 open #1,"b:data2":position #1,32,l:input #1,a$
ed.flgs2
 print "<RETURN>=No Change, ^=Delete, D=Default"
 print \"Old Text: "a$
 input @3 "New Text: "i$
 if len(i$)>31 print \"Entry too long. Try again.":goto ed.flgs2
 if i$="" return
 if (i$="D" or i$="d") print \"Set flag to default";:yn=2:gosub getyn:if i$<>"Y" return:else i$="Access to Level "+str$(l)::goto ed.flgs3
 if i$<>"^" goto ed.flgs3
 print \"Clear this flag";:yn=2:gosub getyn:if i$<>"Y" return
 i$=""
ed.flgs3
 position #1,32,l:print #1,i$:close:goto ed.flgs1

config
 print  \"(*> System Parameters <*)"\
 print  "1 -> System name: "sn$
 print  "2 -> Sysop name: "sy$
 print  "3 -> Remote password: "sv$
 print  "4 -> System logging: ";:if lg print on$"ON"of$:else print "OFF"
 print  "5 -> Forced voting: ";:if fv print on$"ON"of$:else print "OFF"

 print \"Set (1-5 or Q=Quit)";
 l1$="12345Q":gosub getone
 if i$="1" print "System Name":goto conf.sn
 if i$="2" print "Sysop Name":goto conf.sy
 if i$="3" print "Remote password":goto conf.rpw
 if i$="4" print "Logging":goto conf.log
 if i$="5" print "Forced Voting":goto conf.fv
 if i$="Q" print "Quit back":goto conf.quit
conf.log
 input \"System logging (ON, OFF): "i$
 print \"Logging is ";
 if i$="ON" lg=1:print on$"ON"of$
 if i$="OFF" lg=0:print "OFF"
 goto config
conf.sn
 print \"    System Name: "sn$
 input @3 "New System Name: "i$:if i$="" goto config
 sn$=i$:goto config
conf.rpw
 print \"Enter a new remote sysop password [1-20 characters]"
 echo="X":input @2 ":"a$:echo="":if i$="" goto config
 print \"Please enter it again"
 echo="X":input @2 ":"b$:echo=""
 if a$<>b$ print \"Passwords don't match.":goto conf.rpw
 print \"New password accepted."
 sv$=b$:goto config
conf.sy
 print \"    Sysop Name: "sy$
 input @3 "New Sysop Name: "i$:if i$="" goto config
 sy$=i$:goto config
conf.fv
 input \"Forced voting (ON, OFF): "i$
 print \"Forced voting is ";
 if i$="ON" fv=1:print on$"ON"of$
 if i$="OFF" fv=0:print "OFF"
 goto config
conf.quit
 kill "b:data1":create "b:data1":open #1,"b:data1"
 print #1,sn$\sys$\sv$
 print #1,md$\s$\n$
 print #1,lg,fv
 close:return

; print a list of systems users
userlist
 gosub time
 print \"["x$"]["on$"User List"of$"] ";
 print "Option (?=Help)";
 l1$="123456Q?"+chr$(13):gosub getone
 push userlist
user2
 y=32
 if i$="1" print "Name":a=1:f$="h:srt.name":goto user3
 if i$="2" print "User Number":a=2:f$="h:srt.num":goto user3
 if i$="3" print "Password":a=3:f$="h:srt.pw":y=64:goto user3
 if i$="4" print "Phone":a=4:f$="h:srt.ph":y=64:goto user3
 if i$="5" print "Last Called":a=5:f$="h:srt.date":y=64:goto user3
 if i$="6" print "Security":a=6:f$="h:srt.sec":y=64:goto user3
 if i$="Q" or i$=chr$(13) print "Exit":pop:return
 if i$="?" print "Menu":goto usermenu
 return

usermenu
 print '
:::::::::::::::::::::::::::::::::::::::
:           Sorted Userlist           :
:::::::::::::::::::::::::::::::::::::::
:    1 -> Sorted by last name         :
:    2 -> Sorted by user number       :
:    3 -> Sorted by password          :
:    4 -> Sorted by phone number      :
:    5 -> Sorted by last date on      :
:    6 -> Sorted by security level    :
:                                     :
:    Q -> Return to main menu         :
:::::::::::::::::::::::::::::::::::::::'
 return

user3
 fs$="h:filesort":a=val(i$)
 print \"Show passwords";:yn=2:gosub getyn
 if i$="Y" pa=1:else pa=0
 i$="N":if not info(0) print \"Output to printer";:yn=2:gosub getyn
 if i$="Y" s=5:nl=58:else s=0:nl=15
 move ram,58 to ram2:on nocar goto user9
 z=0:print sc$\
 close:print "Reading data...";
 open #1,"b:users":kill f$:create f$:open #2,f$
 for l=1 to nu:position #1,128,l
 if not l mod 5 print ".";
 if not l mod 125 print

 input #1,d1$,d2$\d3$:if d1$="" goto user4
 position #1,128,l,70:read #1,ram,58
 t$=d2$+" "+d1$
 if a=2:t$=right$("    "+str$(l),4)
 if a=3:t$=mid$(" "+pa$+"       ",2,8)+t$
 if a=4:i$=right$(chr$(32,12)+ph$,12)
 if a=4:t$=left$(i$,3)+"-"+mid$(i$,5,3)+"-"+right$(i$,4)+t$
 if a=5:t$=right$(when$,2)+"/"+left$(when$,5)+t$
 if a=6:i$="":for x=1 to 34:i$=i$+str$(flag(x)):next x:t$=i$+t$
 z=z+1:position #2,y,z:print #2,t$\l
user4
 next
user5
 close:print \"Sorting data...";
 gosub sort
 if s=5 print \"Printing...":else print sc$
 z=1:open #2,f$:open #1,"b:users":ln=1:r=0
user6
 position #2,y,z:input #2,t$\l:if t$="" goto user8
 position #1,128,l:input #1,d1$,d2$\d3$
 position #1,128,l,70:read #1,ram,58
 setint(1):if ln<>1 goto user7
 if r and (s=0) print "Press any key to continue..:";:get i$
 if r print #s,sc$;
 print #s,\"**  GBBS Pro Userlist  -  Version 2.30  -  List Sorted By: ";
 if a=1 print #s,"User Name     ";
 if a=2 print #s,"User Number   ";
 if a=3 print #s,"Password      ";
 if a=4 print #s,"Phone Number  ";
 if a=5 print #s,"Last Date on  ";
 if a=6 print #s,"Security level";
 r=1:print #s,'   **
[Name]                     [Phone]    [User] [Pass]    [Sec]    [Last]  [Time]
[Alias]                    [Number]   [Numb] [Word]    [Lvl]    [Call] [Limit]'
 print #s,""
user7
 print #s,left$(d3$+chr$(32,25),25);
 print #s,ph$;
 print #s,right$("     "+str$(l),6)"-";
 if pa print #s,pa$;:else print #s,"********";
 print #s,"  ";:for x=1 to 7:print #s,flag(x);:next x
 print #s,"  "when$;
 print #s,right$("    "+right$(("0"+str$(nibble(5)*10)),2),5)
 z=z+1:ln=ln+1:if ln>nl ln=1
 goto user6
user8
 close:setint("")
 if s=0 print \"Press any key to continue...";:get i$
 print #s,sc$;:move ram2,58 to ram
 kill f$:kill fs$
 return
user9
 move ram2,58 to ram:close:setint("")
 kill f$:kill fs$
 goto link.term

; *** sub - routines ***

; sort elements inclusive of f-l

sort
 kill fs$:create fs$
 open #1,f$:open #2,fs$
 ss=s:ll=l:zz$=z$
 s=0:f=1:l=z:qq=0
sort1
 m=((l+f)/2):i=f:j=l
 position #1,y,m
 input #1,m$:input #1,m1
sort2
 qq=qq+1:if not qq mod 5 print ".";
 if not qq mod 125 print
 position #1,y,i
 input #1,i$:input #1,i1
sort3
 position #1,y,j
 input #1,j$:input #1,j1
 if i$<m$ then i=i+1:goto sort2
 if j$>m$ then j=j-1:goto sort3
 if i>j then goto sort5
 if i=j then goto sort4
 z$=i$:i$=j$:j$=z$:z1=i1:i1=j1:j1=z1
 position #1,y,i
 print #1,i$:print #1,i1
 position #1,y,j
 print #1,j$:print #1,j1
sort4
 i=i+1:j=j-1
 if i<=j then goto sort2
sort5
 if i>=l then goto sort6
 position #2,20,s
 print #2,i:print #2,l:s=s+1
sort6
 l=j
 if f<l then goto sort1
 if s=0 then goto sort7
 s=s-1:position #2,20,s
 input #2,f:input #2,l:goto sort1
sort7
 s=ss:l=ll:z$=zz$
 print ".sorted"
 close:return

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

; enter a message
editor
 on nocar goto editor1
 print \"Enter message now, "edit(3)" columns, 4k max"
 print "[DONE]  when finished,  [.H] for help"
 cl=clock(2):clock(2)=0:edit(0):edit(1):clock(2)=cl
 on nocar goto link.term:return
editor1
 pop:clock(2)=cl:goto link.term

; report an error
error
 close:on error:
 use "b:snapshot","b:snap.txt"
 print\sc$"A fatal error has occured. One moment, please..."\
 open #1,"b:error.list":position #1,32,err:input #1,er$:close
 f$="b:sys.errors":create f$:open #1,f$:append #1
 print #1,"Error #"err"-"er$" occurred in SYSTEM2.SEG.S at "time$" on "date$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."\
 open #2,"b:snap.txt":copy #2,#1
 print #1,"----------------------------------------------------------------"
 close:kill "b:snap.txt"
 goto link.term
