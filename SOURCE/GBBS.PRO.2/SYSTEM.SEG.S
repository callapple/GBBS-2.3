; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2024
; Kevin M. Smallwood
; *******************

; system segment - 1/6/23

 on nocar goto link.term
 on error goto error

 ed=edit(5):dd=110

system
 gosub time
 print \"["x$"]["on$"System Level"of$"] Option (?=Help)";
 l1$="BCDEFGKLMNPQRSTUWX*?!$"
 gosub getone:push system
sys.cmd
 if i$="?" print "Menu":goto menu
 if i$="B" print "Board maintenance":l$="BOARDS":goto dispatch
 if i$="C" print "Configure system parameters":l$="CONFIG":goto dispatch
 if i$="D" print "DOS Command":goto dos
 if i$="E" print "Edit flags":l$="FLAGS":goto dispatch
 if i$="F" print "Show a file":goto file
 if i$="G" print "Edit a text file":goto edit.file
 if i$="K" print "Delete user":goto kill.pass
 if i$="L" print "System Logs":l$="LOGS":goto dispatch
 if i$="N" print "New user":goto new.user
 if i$="P" print "Edit user":goto edit.pass
 if i$="R" print "Read request":goto request
 if i$="S" print "Set a new date":goto set.date
 if i$="T" print "Terminate":goto terminate
 if i$="U" print "Userlist":l$="USERLIST":goto dispatch
 if i$="W" print "Update news":goto welcome
 if i$="X" print "Up/Download":goto xfer
 if i$="*" print "Edit Auto Validation":goto val.flags
 if i$="!" print "Purge users":pop:link "a:userpurge.seg"
 if i$="Q" print "Quit back":pop:link "a:main.seg","fromsys"

 if i$="$" print "Test":pop:link "a:edit.user"

menu
 f$="b:mnu.system.80":if (edit(3)<79) f$="b:mnu.system.40"
menu.1
 open #1,f$:input #1,x$:setint(" "):for l=1 to len(x$)
 addint(mid$(x$,l,1)):next:print \sc$\
 copy #1:if key(3) goto menu.key
 a=key(0):close:setint(""):pop:goto system
menu.key
 close:setint(""):a=key(0)
 if (a>96) and (a<123) a=a-32
 if a=32 pop:goto system
 print:i$=chr$(a):goto sys.cmd

edit.pass
 input @2 \"Account #" i$:if i$="" return
 a=val(i$):if i$="C" then a=un

ed.pass0
 if (a<1) or (a>nu) print \on$"User does not exist."of$:return
 d1$=a1$:d2$=a2$:d3$=a3$:d4$=a4$:d5$=a5$
 move ram,58 to ram2:if a<>un gosub rd.user
 if d1$<>"" goto ed.pass2
 print \"User does not exist - create";:yn=2:gosub getyn
 if i$<>"Y" move ram2,58 to ram:return
ed.pass1
 fill ram,58,0:d1$="NEW":d2$="USER":
 d3$="New User":d4$="City":d5$="ST"
 pa$="PASSWORD":ph$="XXX-XXX-XXXX":nibble(5)=3

ed.pass2
 print \"A) Full Name       : "d3$
 print  "B) City, State     : "d4$", ";d5$
 print  "C) ID#-Password    : "a"-"pa$
 print  "D) Phone           : "ph$
 print  "E) Access flags    : ";: for x=1 to 34:print flag(x);:next
 print \"F) Time limit      : ";
 if nibble(5)=0 print "Unlimited":else print nibble(5)*10
 print  "G) Calls Today     : "nibble(6)
 print  "H) Total Calls     : "byte(1)+nibble(1)*256
 print  "I) Bulletins       : "byte(2)+nibble(2)*256
 print  "J) Downloads       : "byte(3)+nibble(3)*256
 print  "K) Uploads         : "byte(4)+nibble(4)*256
 e1=byte(14)+byte(15)*256:e2=byte(16)+byte(17)*256
 e$=str$(e2):if e1 e$=str$(e1)+right$("000"+str$(e2),4)
 print  "L) D/Blocks        : "e$
 e1=byte(10)+byte(11)*256:e2=byte(12)+byte(13)*256
 e$=str$(e2):if e1 e$=str$(e1)+right$("000"+str$(e2),4)
 print  "M) U/Blocks        : "e$
 print \'Which (A-M), or press "*" to'
 print "Auto-Validate";
 l1$="ABCDEFGHIJKLM*"+chr$(13):gosub getone:print i$

 if i$="A" gosub ed.name:goto ed.pass2
 if i$="B" input \"City:" d4$:x$=i$:i$=d4$:gosub mixed:d4$=i$:i$=x$
 if i$="B" input \"State:" d5$:d5$=left$(d5$,2):goto ed.pass2
 if i$="C" input \"Pass:" a$:pa$=left$(a$+chr$(32,8),8):goto ed.pass2
 if i$="D" input \"Phone:" a$:ph$=a$:goto ed.pass2
 if i$="F" input \"Time Limit:"x:nibble(5)=x/10
 if i$="G" input \"Calls Today:"x:nibble(6)=x
 if i$="H" input \"Total Calls:"x:byte(1)=x mod 256:nibble(1)=x/256
 if i$="I" input \"Bulletins:"x:byte(2)=x mod 256:nibble(2)=x/256:goto ed.pass2
 if i$="J" input \"Downloads:"x:byte(3)=x mod 256:nibble(3)=x/256:goto ed.pass2
 if i$="K" input \"Uploads:"x:byte(4)=x mod 256:nibble(4)=x/256:goto ed.pass2
 if i$="L" input \"Blocks Down: ";i$:gosub edit.dlb:goto ed.pass2
 if i$="M" input \"Blocks Up: ";i$:gosub edit.ulb:goto ed.pass2

 if i$="*" gosub autoval:goto ed.pass2
 if i$=chr$(13) goto ed.pass5
 if i$<>"E" goto ed.pass2

 gosub flg.ttl
 input @2 a$:if a$="" goto ed.pass2
 if a$="?" goto ed.pass3
 for x=1 to len(a$):if x>34 then x=len(a$)
 flag(x)=(mid$(a$,x,1)="1"):next:goto ed.pass2

ed.pass3
 open #1,"b:data2":for x=1 to 34
 position #1,32,x:input #1,a$:if a$="" goto ed.pass4
 print \a$\"Access (Y,N,S,Q):";:get a$
 if a$="Q" then x=34
 if a$="Y" then flag(x)=1
 if a$="N" then flag(x)=0
ed.pass4
 next:close #1:goto ed.pass2

ed.pass5
 b=len(d1$+d2$+d4$+d5$):if b<32 goto ed.pass6
 print \on$"Name and City are too long."of$
 print \"Max len=32, current len="b:goto ed.pass2

ed.pass6
 print \"S)ave, A)bort, or R)eturn";:l1$="SAR":gosub getone
 if i$="A" print "Abort":move ram2,58 to ram:return
 if i$<>"S" print "Return to editing":goto ed.pass2
 print "Save user":if a>nu then nu=a
 if a<>un gosub wr.user:move ram2,58 to ram:return
 a1$=d1$:a2$=d2$:a3$=d3$:a4$=d4$:a5$=d5$
 tc=byte(1)+nibble(1)*256:bp=byte(2)+nibble(2)*256
 dl=byte(3)+nibble(3)*256:ul=byte(4)+nibble(4)*256
 u1=byte(10)+byte(11)*256:u2=byte(12)+byte(13)*256
 d1=byte(14)+byte(15)*256:d2=byte(16)+byte(17)*256
 ul$=str$(u2):if u1 ul$=str$(u1)+right$("000"+str$(u2),4)
 dl$=str$(d2):if d1 dl$=str$(d1)+right$("000"+str$(d2),4)

;top of local screen
 a$=right$("   "+str$(un),4):clear #9
 print #9,cn$,a1$" "a2$" of "a4$", "a5$,nibble(6)
 print #9,tc,ul,dl,bp,ph$,lc$,a$,pa$
 for x=1 to 34:print #9,flag(x);:next
 print ^
 return

ed.name
 input @3 \\"Full Name:"i$
 if i$="" return
 gosub mixed:d3$=i$
 gosub name.cov
 return

autoval
 f$="b:sys.autoval":open #1,f$:if mark(1) close #1:return
 input #1,i$:close #1
 for x=1 to 34:flag(x)=val(mid$(i$,x,1)):next
 return

val.flags
 f$="b:sys.autoval":open #1,f$:a=mark(1)
 if not a input #1,x$:close:goto val.fl1
 x$=chr$(48,34):close:create f$
 open #1,f$:print #1,i$:close
val.fl1
 print \"Current Auto-Validation flags:"
 gosub flg.ttl:print left$(x$,34)
 print \"Do you want to modify the auto-"
 print "validation settings";:yn=2:gosub getyn
 if i$<>"Y" return
val.fl2
 print \"Enter the new auto-valadation flags:"
 gosub flg.ttl:input @2 x$:if x$="" goto val.fl1
 x$=left$(x$+chr$(48,34),34)
 open #1,f$:print #1,x$:close
 goto val.fl1

flg.ttl
 print '
Flag: 0000000001111111111222222222233333
      1234567890123456789012345678901234
Lvl : ';:return

kill.pass
 input \"Kill #"a
 if (a<1) or (a>nu) return
 move ram,58 to ram2:gosub rd.user
 a$=mid$(" "+when$,2)
 if d1$="" print \on$"That user does not exist"of$:move ram2,58 to ram:return
 print \"Kill "d3$\"Last on "a$;:yn=2:gosub getyn
 if i$<>"Y" move ram2,58 to ram:return
 d1$="":gosub wr.user
 print \"User Killed"
 move ram2,58 to ram:return

request
 print \"Read Request File":open #2,"b:request"
 if mark(2) close:print \"File empty":return
 print \"Send file to printer";:yn=2:gosub getyn
 if i$="Y" setint(1):copy #2,#5:mark(2)=0
req2
 input #2,a:b=mark(2):if a goto req3
 close:print \"Delete File";:yn=2:gosub getyn
 if i$="Y" kill "b:request"
 return
req3
 mark(2)=b:print \md$
req3a
 input #2,i$:if i$<>chr$(1) print i$:goto req3a
 print md$
req4
 print \"Request [V, K, "on$"C"of$", R, A, Q]";
 l1$="RQCKVA?"+chr$(13):gosub getone
 if i$="R" print "Reread":goto req3
 if i$="Q" print "Quit":close:return
 if i$="C" or i$=chr$(13) print "Continue":goto req2
 if i$="K" print "Kill":d1$="":gosub wr.user:goto req2
 if i$="V" print "Validate":gosub ed.pass0:goto req2
 if i$="?" print 'Help

(V)alidate, (K)ill, (C)ontinue/skip, (R)e-read, (A)uto-reply, (Q)uit'
 if i$="?" goto req4

 print "Auto-reply"
 f$="mail."+str$(a):gosub chkbox
 sb$="Reply to Application"
 print \"Registered Mail";:yn=2:gosub getyn
 rg=(i$="Y"):if rg:st$="Registered Mail":else st$="Awaiting Reply"
 gosub editor:if not edit(2) gosub abort:goto req4
 print \"Wait...";:x=mark(2):close
 ready mb$:if msg(0)=128 kill #msg(1):crunch
 b=msg(0)+1
 print #msg(b),date$" "time$\a3$" (#"un")",un\st$\sb$\rg
 copy #8,#6:msg(b)=b:update:ready " "
 open #2,"b:request":mark(2)=x
 print ".email sent":goto req4

file
 input @2 \"File Name (to read):" i$
 f$=i$:if i$="" return
 print \"Show file on printer";:yn=2:gosub getyn
 if i$<>"Y" goto show.file
 setint(1):copy f$,#5:return

; terminate
terminate
 print \"Terminate from "sn$
 print \"Are you sure";:yn=2:gosub getyn
 if i$<>"Y" return

link.term
 link "a:main.seg","term1"

welcome
 print \"Show current welcome to all users";:yn=1:gosub getyn
 if i$="N" return
 wm=mn:mn=mn+1:print \"News updated":return

edit.file
 input @2 \"File Name (to load):" i$
 edit(0):if i$<>"" copy i$,#8
 print \"Enter/Edit File Now: "edit(3)" columns, 4k max"
 print "[DONE]  when finished,  [.H] for help"
 edit(1):if not edit(2) return
 input @2 \"File Name (to save):" i$
 if i$="" return
 kill i$:create i$:open #1,i$
 copy #8,#1:close:return

dos
 on error goto dos.error
 if lg$="" lg$="B:"
 gosub time:print \"["x$"]["on$"DOS Commands"of$" ("lg$")] Option (?=Help)";
 l1$="CDFLPQRTUZ?/"+chr$(13):gosub getone:push dos
dos.cmd
 if i$="P" print "Prefix":goto dos.prefix
 if i$="C" print "Catalog":goto dos.cat
 if i$="L" print "Lock":goto dos.lock
 if i$="U" print "Unlock":goto dos.unlock
 if i$="D" print "Delete":goto dos.delete
 if i$="R" print "Rename":goto dos.rename
 if i$="T" print "FileType":goto dos.ftype
 if i$="/" print "Create Directory":goto dos.create
 if i$="F" print "Free Space":goto dos.free
 if i$="Z" print "Copy":goto dos.copy
 if i$="?" print "Menu":goto dos.menu
 if (i$="Q") or (i$=chr$(13)) on error goto error:pop:print:return

dos.menu
 setint(1):print sc$ s$\'
:::::::::::::::::::::::::::::::::::::::
:             DOS Commands            :
:::::::::::::::::::::::::::::::::::::::
:        P -> Set Prefix              :
:        C -> Catalog                 :
:        D -> Delete                  :
:        L -> Lock                    :
:        U -> Unlock                  :
:        R -> Rename                  :
:        T -> Change Filetype         :
:        F -> Free space              :
:        / -> Create Subdirectory     :
:        Z -> Copy                    :
:        Q -> Quit back               :
:::::::::::::::::::::::::::::::::::::::'
 setint(""):return

dos.prefix
 if lg$<>"" print \"Current Prefix: "lg$:else print
 input @2 "    New Prefix: "i$:if i$="" return
 if right$(i$,1)<>":" i$=i$+":"
 lg$=i$:log lg$
 return
dos.cat
 print \"Input drive ("lg$"): ";:input @2 f$:if f$="" f$=lg$
 if right$(f$,1)<>":" f$=f$+":"
 print \"40 or 80 columns ([4]/8)";:l1$="48"+chr$(13):gosub getone:print
 if (i$=chr$(13)) or (i$="4") use "b:xdos","C "+f$
 if i$="8" use "b:xdos","X "+f$
 return
dos.lock
 input @2 \"Filename: "f$:if f$="" return
 gosub filter
 i$=lg$+f$:gosub dtype:if not(si) print \on$"No Such File"of$:return
 i$="L "+i$
 use "b:xdos",i$
 print \"File "f$" locked"
 return
dos.unlock
 input @2 \"Filename: "f$:if f$="" return
 gosub filter
 i$=lg$+f$:gosub dtype:if not(si) print \on$"No Such File"of$:return
 i$="U "+i$
 use "b:xdos",i$
 print \"File "f$" unlocked"
 return
dos.delete
 input @2 \"Filename: "f$:if f$="" return
 gosub filter
 i$=lg$+f$:gosub dtype:if not(si) print \on$"No Such File"of$:return
 close:kill i$
 print \"File deleted"
 return
dos.rename
 input @2 \"Filename: " f$:if f$="" return
 gosub filter
 i$=lg$+f$:gosub dtype:if not(si) print \on$"No Such File"of$:return
 close:ab$=f$:input @2 \"New Filename: "f$:if f$="" return
 gosub filter:ac$=f$
 i$=lg$+ab$:i$=i$+","+ac$
 i$="R "+i$
 use "b:xdos",i$
 print \"File "ab$" renamed to "ac$
 return
dos.ftype
 input @2 \"Filename: " f$:if f$="" return
 gosub filter
 i$=lg$+f$:gosub dtype:if not(si) print \on$"No Such File"of$:return
 ab$=f$:input @2 \"New Filetype: "f$:if f$="" return
 ac$=f$
 i$=lg$+ab$:i$=i$+","+ac$
 i$="T "+i$
 use "b:xdos",i$
 print \"File type changed"
 return
dos.create
 input @2 \"Create Directory: "f$:if f$="" return
 gosub filter:i$=lg$+f$
 gosub dtype:if si print \on$"File Exists"of$:return
 i$="extradir "+i$
 use "b:xdos",i$
 if peek(10)>0 print on$"Error"of$"...Subdirectory not created"
 return
dos.free
 print \"Input drive ("lg$"): ";:input @2 f$:if f$="" f$=lg$
 if f$="" f$=lg$
 if right$(f$,1)<>":" f$=f$+":"
 use "b:xdos","F "+f$
 return
dos.copy
 input @2 \"Input source (ex. a:filename): "f$:if f$="" return
 open #1,f$:a=mark(1):close:if a print \on$"No Such File"of$:return
 input @2 \"Input target (ex. a:newfile): "f2$
dos.cpy2
 use "b:xcopy",f$,f2$
 a=peek(-25085)
 if a=0 print "File copied":return
 if a<>71 print \on$"Copy aborted....error #"aof$:return
 print \"File exists...overwrite it";:yn=2:gosub getyn
 if i$="Y":kill f2$:goto dos.cpy2
 return
dos.error
 if err=22 print \on$"Invalid drive"of$:else goto error
 return

; file transfer section
xfer
 if lg$="" gosub dos.prefix:if i$="" return
 print \"Current prefix: "lg$
 print \"(U)pload, (D)ownload, (C)atalog"
 print "(L)og new drive, (Q)uit back";
 push xfer
 l1$="CDLQU"+chr$(13):gosub getone

 if i$="C" print "Catalog":goto dir
 if i$="D" print "Download":goto download
 if i$="L" print "Log a new drive":goto dos.prefix
 if (i$=chr$(13)) or (i$="Q") print "Quit back":pop:return
 if i$="U" print "Upload":goto upload

upload
 input @2 \"Filename to receive via Xmodem: " f$: if f$="" return
 gosub filter:f1$=f$:i$=lg$+f$:gosub chkfile
 if (not a) gosub upload1
 print \"Press  <CR>  to begin,  <ESC>  to abort"
 print  "---------------------------------------";:get i$:print
 if i$<>chr$(13) print on$"Aborted"of$:return
 print "Receving via Xmodem..<CTRL-X> to Cancel"\
 i$=lg$+f$:use "b:prot.up",dd,0,i$
 if (peek(10)=255) print \\"Error in transfer...["on$"Aborted"off$"]":return
 gosub dtype:print \bi" ProDOS Blocks Received" 
 return
upload1
 print \on$"File Already Exists"of$
 print \"Overwrite";:yn=2:gosub getyn
 if i$<> "Y" print \"Aborted":pop:return
 kill i$
 return

download
 print \"Send via Xmodem"
 c=0:bz=0:gosub fsel:gosub dtype
 print\"[ Filename Selected ] "f$
 print "[ ProDOS Blocks     ] "bi
 print "[ Xmodem Blocks     ] "si
 print "[ Bytes:  "by$" ]"
 print \"Press  <CR>  to begin,  <ESC>  to abort"
 print  "---------------------------------------";:get i$:print
 if i$<>chr$(13) print on$"Aborted"of$:return
 print "Sending via Xmodem...<CTRL-X> to Cancel"
 i$=lg$+f$:use "b:prot.down",dd,0,i$
 if peek(10)=255 print \\"Error in transfer...[Aborted]"
 return

dir
 print \\"Volume "lg$\
 gosub add
 dc=0:gosub dir.head
 gosub makestr
 use "b:xcat",0,lg$,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
dloop
 if fn$="               " goto endloop
 if (flag(35) and (dc>15)) gosub dir.header:else dc=dc+1
 si=peek(ed+22)+peek(ed+23)*256:a=a+1
 print right$("00"+str$(a),2)"  "fn$"  "ta$"  "bu$"  "right$("    "+str$(si),5)
dloop2
 if key(1) setint(""):print \on$"Aborted"of$:setint(1):goto endlp2
 call ed,0,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$:goto dloop
endlp2
 use "b:xcat",0,lg$,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
 setint(""):return
endloop
 if a=0 print \on$"No files on this volume"of$:setint(""):return
 print chr$(45,38)
 setint(""):return
dir.head
 if dc<>0 print "Press [RETURN] ";:get j$:dc=0:print sc$
 print sc$"##  Filename         Typ   Blks   Xmdm"
 print chr$(45,38)
 return

fsel
 b=1:gosub getfnum
 if fn$="               " print on$"No files"of$:pop:return 
fsel1
 print\"[Select File #, or ?]: ";
 input @2 i$:z$=i$:if i$="" pop:return
 if i$="?" gosub dir:goto fsel1
 if bz=1 return
fsel2
 b=val(i$):if b<1 print \on$"No such file number"off$:pop:return
fsel3
 gosub getfnum
 if fn$="               " print \on$"No such file number"of$:pop:return
 f$=a$:f1$=f$:i$=lg$+f$
 return

getfnum
 gosub makestr
 use "b:xcat",b,lg$,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
 z=peek(ed+6):a$=left$(fn$,z)
 return

makestr
 fn$="               ":ta$="   ":th$="   ":bu$="     "
 mo$="         ":mt$="     "
 xd$="         ":xt$="     "
 by$="         ":a=0
 return

add
 setint(cr$):addint(e$):addint(" "):addint(chr$(8))
 addint(chr$(21)):addint(chr$(10)):addint(chr$(11))
 addint("L"):addint("D"):return

new.user
 print \"Add a new user";:yn=2:gosub getyn
 if i$<>"Y" return
 move ram,58 to ram2
 a=nu+1:goto ed.pass1

set.date
 print \"Current date: "date$
 input @2 \"Today's Date: "i$:date$=i$
 print \"New date: "date$:return

; y$=segment to return to upon completion
; z$=label to return to

dispatch
 y$="a:system.seg"
 z$=""
 link "a:system2.seg"

; *** sub-routines ***

; check for valid prodos filename
filter
 if len(f$) > 15 print \on$"Filename Too Long"of$:pop:return
 if (left$(f$,1) < "A") or (left$(f$,1) > "Z") print \on$"Illegal Filename"of$:pop:return 
 i$="":for p=1 to len(f$):a=asc(mid$(f$,p,1))
 if (a>64) and (a<91) goto filter1
 if (a>96) and (a<123) goto filter1
 if (a>47) and (a<58) goto filter1
 if a=46 goto filter1:else goto filter2
filter1
 i$=i$+chr$(a):next:f$=i$:return
filter2
 i$=i$+chr$(46):next:f$=i$:return

chkfile
 open #1,i$:a=mark(1):si=size(1):close:return

; get file info
dtype
 use "b:xdos","getinfo "+i$:x=peek(ed+7)
 ty$=str$(x):si=peek(ed+21)+peek(ed+22)*256
 bi=peek(ed+11)+peek(ed+12)*256
 return

;check mailbox status and create if not present
chkbox
 mb$="g:"+f$:open #1,mb$:x=mark(1):close #1
 if not x ready " ":return
 print "Making Mailbox..."
 gosub msg
 ready " ":return

; create mail file
msg
 kill mb$:create mb$:open #1,mb$:ed=edit(5):fill ed,255,0:poke ed,4:poke ed+1,4
 write #1,ed,2:fill ed,255,0:for xz=1 to 4:write #1,ed,255:next
 write #1,ed,10:close #1:ready " "
 a$="T "+mb$+",BIN":use "b:xdos",a$
 return

;kill off the message file if not mail was sent
abort
 ready mb$:if not msg(0) kill mb$
 ready " ":return

rd.user
 open #1,"b:users"
 position #1,128,a
 input #1,d1$,d2$\d3$\d4$,d5$
 position #1,128,a,70
 read #1,ram,58
 close #1
 return

wr.user
 open #1,"b:users":position #1,128,a
 if d1$="" then d1$="":d2$=""
 print #1,d1$","d2$\d3$\d4$","d5$
 position #1,128,a,70
 write #1,ram,58:close #1
 if d1$="" kill"g:mail."+str$(a)
 return

name.cov
 a$="":for l=1 to len(i$)
 x=asc(mid$(i$,l,1)):if x>96 then x=x-32
 a$=a$+chr$(x):next:x=instr(" ",a$,1)
 if not(x) d2$=a$:d1$=".":return
 d1$=left$(a$,x-1):d2$=mid$(a$,x+1)
 return

; convert i$ to mixed case
; uses i$,a$,x,l
mixed
 x=asc(left$(i$,1)):if (x>96) x=x-32
 a$=chr$(x):for l=2 to len(i$)
 x=asc(mid$(i$,l,1))
 if ((x>64) and (x<91)) x=x+32
 if x=32 a$=a$+" ":l=l+1:x=asc(mid$(i$,l,1)):if ((x>96) and (x<123)) x=x-32
 if x=45 a$=a$+"-":l=l+1:x=asc(mid$(i$,l,1)):if ((x>96) and (x<123)) x=x-32
 a$=a$+chr$(x)
 next
 i$=a$:return

; edit download/upload blocks

edit.dlb
 x=val(i$)
 if x<0 print "Must be 0 to 32767":get i$:return
 d1=0:d2=x
ed.dlb1
 if d2>9999 d1=d1+1:d2=d2-10000
 if d2>9999 goto ed.dlb1
 dl$=str$(d2):if d1 dl$=str$(d1)+right$("000"+str$(d2),4)
 byte(14)=d1 mod 256:byte(15)=d1/256
 byte(16)=d2 mod 256:byte(17)=d2/256
 return

edit.ulb
 x=val(i$)
 if x<0 print "Must be 0 to 32767":get i$:return
 u1=0:u2=x
ed.ulb1
 if u2>9999 u1=u1+1:u2=u2-10000
 if u2>9999 goto ed.ulb1
 ul$=str$(u2):if u1 ul$=str$(u1)+right$("000"+str$(u2),4)
 byte(10)=u1 mod 256:byte(11)=u1/256
 byte(12)=u2 mod 256:byte(13)=u2/256
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

; enter a message
editor
 print \"Enter message now, "edit(3)" columns, 4k max"
 print "[DONE]  when finished,  [.H] for help"
 edit(0):edit(1)
 return

; report an error
error
 close:on error:
 use "b:snapshot","b:snap.txt"
 print\sc$"A fatal error has occured. One moment, please..."\
 open #1,"b:error.list":position #1,32,err:input #1,er$:close
 f$="b:sys.errors":create f$:open #1,f$:append #1
 print #1,"Error #"err"-"er$" occurred in SYSTEM.SEG.S at "time$" on "date$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."\
 open #2,"b:snap.txt":copy #2,#1
 print #1,"----------------------------------------------------------------"
 close:kill "b:snap.txt"
 goto link.term
