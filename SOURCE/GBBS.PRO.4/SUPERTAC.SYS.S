; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2024
; Kevin M. Smallwood
; *******************

; SuperTAC System segment - 7/22/2023
; Version 6.4
; Written by Andy Nicholas
; Updates and modifications by Paul Lee

set when$=ram+20

sact
 on nocar goto link.term
 on error goto error

sact1
 push sact1
 gosub time:print \"["x$"]["on$"SuperTAC System"off$"] ";
 print "Option (?=Help)";
sact2
 l1$="ACEFKLQRSTUX?"+cr$:if info(5) l1$=l1$+"DMNPVZ/1234"
 gosub getone
 if (i$="Q") or (i$=chr$(13)) print "Quit":pop:goto link.ae
 if i$="R" print "Rename Files"\: goto rename
 if i$="P" and info(5) print "Purge Volumes":pop:link "a:purge.seg"
 if i$="L" goto lock
 if i$="U" goto unlock
 if i$="N" and info(5) goto new
 if i$="D" and info(5) goto dos.cmd
 if i$="E" goto f.edit
 if i$="K" goto kill
 if i$="A" goto leech
 if i$="/" and info(5) goto create
 if i$="M" and info(5) goto makedir
 if i$="?" goto cmnds
 if i$="F" goto free
 if i$="T" goto terminate
 if i$="V" and info(5) f$="volume header":fn$=v1$+":vol.headers":goto filstuf
 if i$="Z" and info(5) pop:link "a:supertac.log"
 if i$="X" print "Change File Type"\:goto xchange
 if i$="C" print "Catalog":goto dir
 if i$="S" and not (info(0)) goto showmast
 if i$="1" and info(5) f$="new upload":fn$=v1$+":new.uploads":goto filstuf
 if i$="2" and info(5) f$="download":fn$=v1$+":downloads":goto filstuf
 if i$="3" and info(5) f$="about upload":fn$=v1$+":about.uploads":goto filstuf
 if i$="4" and info(5) goto passtuf
 goto sact2

cmnds
 setint(1):copy v1$+":menu.system":setint(""):return

rename
 input @2 "Source Filename:" f$:if f$="" return
 gosub filter:gosub name.chk
 open #1,lg$+f$:a=mark(1):close:if a print \on$"No Such File"of$:return
 ab$=f$:input @2"Dest   Filename:"f$:if f$="" return
 gosub filter:ac$=f$
 i$=lg$+ab$:i$=i$+","+ac$
 i$="R "+i$
 use v1$+":xdos",i$
 print \"File renamed"
 return

lock 
 input @2"Lock:"f$:if f$="" return
 if f$="/" f$=f1$
 gosub filter:gosub name.chk 
 f1$=f$:i$=lg$+f$
 gosub dtype:if not(si) print \on$"No Such File"of$:return
 i$="L "+i$
 use v1$+":xdos",i$
 print \"File locked"
 return
 
unlock
 input @2"Unlock:"f$:if f$="" return
 if f$="/" f$=f1$
 gosub filter:gosub name.chk
 f1$=f$:i$=lg$+f$
 gosub dtype:if not(si) print \on$"No Such File"of$:return
 i$="U "+i$
 use v1$+":xdos",i$
 print\"File unlocked"
 return

create
 input @2"Create Directory:"f$:if f$="" return
 if f$="/" f$=f1$
 gosub name.chk:f1$=f$:i$=lg$+f$
 gosub dtype: if si print on$"File Exists"of$:return
 i$="extradir "+i$
 use v1$+":xdos",i$
 if peek(10)>0 print on$"[Error]"of$"...Subdirectory not created"
 return

kill
 input @2"Kill:"f$:if f$="" return
 if f$="/" f$=f1$
 gosub filter:gosub name.chk
 f1$=f$:i$=lg$+f$
 gosub dtype:if not(si) print \on$"No Such File"of$:return
 close:kill i$
 print \"File killed":return
 
dos.cmd
 input @2"ProDOS:"i$:if i$="" return
 use v1$+":xdos",i$
 return
          
leech
 print "About User's Habits"
 print \"Dump to Printer";:yn=2:gosub getyn
 if i$<>"Y" cn=0:else cn=5:goto leech.1
 if cn=0 print \"Dump To File";:yn=2:gosub getyn
 if i$<>"Y" cn=0:else cn=2
 if cn=2 f$="USER.HABITS":print \"Dump To (Filename):"f$;
 if cn=2 print chr$(8,len(f$));:input @2 i$:if i$="" i$=f$
 if cn=2 a$=lg$+i$:close:kill a$:create a$
leech.1
 input @2 \"Match letters (<CR>=All):"i$
 open #1,"b:users":x=1
 if cn=2 open #2,a$:append #2
 if left$(i$,1)="#" x=val(mid$(i$,2)):i$=""
 if (x=0) or (x>nu) then x=1
 print #cn,\"Numb  User's Name           Last  On    #Dn   #Up";
 print #cn,"   B-Up   B-Down"\
usrlst2 
 position #1,128,x:input #1,a$,b$
 setint(1):if a$="" goto usrlst3
 a$=a$+" "+b$:if not instr(i$,a$) goto usrlst3
 input #1,c$\d$,e$:position #1,128,x,70
 move ram,58 to ram2:on nocar goto usrlst4:read #1,ram,58
 setint(1)
 print #cn,right$("000"+str$(x),4)"  ";
 print #cn,left$(c$+"....................",20)"  ";
 print #cn,when$"    ";
 e=byte(3)+nibble(3)*256
 print #cn,right$("    "+str$(e),4)"  ";
 e=byte(4)+nibble(4)*256
 print #cn,right$("    "+str$(e),4)"  ";
 e1=byte(10)+byte(11)*256:e2=byte(12)+byte(13)*256
 e$=str$(e2):if e1 e$=str$(e1)+right$("000"+str$(e2),4)
 print #cn,right$("      "+e$,6)"  ";
 e1=byte(14)+byte(15)*256:e2=byte(16)+byte(17)*256
 e$=str$(e2):if e1 e$=str$(e1)+right$("000"+str$(e2),4)
 print #cn,right$("      "+e$,6) 
 move ram2,58 to ram:on nocar goto link.term
usrlst3
 if (not key(1)) and (x<nu) then x=x+1:goto usrlst2
 setint(""):close:return
usrlst4
 move ram2,58 to ram:goto link.term

new
 print "New message files"
 print\chr$(45,30)
 print" 1 - Update new uploads"
 print" 2 - Update downloads"
 print" 3 - Update about files"
 print chr$(45,30)
 print"Choice";
 l1$="123"+cr$:gosub getone
 if i$="1" f$="new upload":fn$=v1$+":new.uploads":goto new.mess
 if i$="2" f$="download":fn$=v1$+":downloads":goto new.mess
 if i$="3" f$="about file":fn$=v1$+":about.uploads":goto new.mess
 print "Exit"
 return

new.mess
 print "Update "f$"s";:yn=2:gosub getyn
 if i$<>"Y" return
 i$=fn$
 goto message

passtuf
 print "Password management"
 print\chr$(45,40)
 print" 1 - Update volume passwords [remove all]"
 print" 2 - Edit a volume password"
 print" 3 - Delete volume password" 
 print chr$(45,40)
 print"Choice";
 l1$="123"+cr$:gosub getone
 if i$="1" goto do.ph
 if i$="2" goto do.edp
 if i$="3" goto do.delp
 print "Exit"
 return

do.ph
 print\\"This action deletes all previous volume passwords!"
 print "Please be sure you want to remove the volume passwords!"\
 print "Update new volume passwords";:yn=2:gosub getyn
 if i$<>"Y" return
 ready v1$+":vol.headers"
 print \"Clearing...Volume password ["on$"00"of$"]";
 for xx=vl to vh
 print chr$(8,3);on$right$("0"+str$(xx),2)of$"]";
 edit(0):input #msg(xx),vp$:copy #6,#8
 kill #msg(xx):print #msg(xx),"":copy #8,#6:update:next:print:return

do.edp
 print "Edit volume password"\
 input @2 "Volume password to edit:" i$:if i$="" return
 a=val(i$):if (a<vl) or (a>vh) or (a=1) print on$"Volume out of range"of$:return
 edit(0):ready v1$+":vol.headers":input #msg(a),vp$:copy #6,#8
 input @2"Enter new volume password:"vp$:if vp$="" return
 kill #msg(a):print #msg(a),vp$:copy #8,#6:update:return

do.delp
 print "Delete volume password"\
 input @2 "Volume password to delete:" i$:if i$="" return
 a=val(i$):if (a<vl) or (a>vh) print on$"Volume out of range"of$:return
 edit(0):ready v1$+":vol.headers":input #msg(a),vp$:copy #6,#8
 kill #msg(a):print #msg(a),"":copy #8,#6:update:return

filstuf
 print "Management of "f$"s"
 print\chr$(45,40)
 print" 1 - Update "f$" [remove all]"
 print" 2 - Edit "f$
 print" 3 - Delete "f$
 print chr$(45,40)
 print"Choice";
 l1$="123"+cr$:gosub getone
 if i$="1" goto do.updt
 if i$="2" goto do.edit
 if i$="3" goto do.delet
 print "Exit"
 return

do.updt
 print\\"This action deletes the previous "f$" file!"
 print "Please be sure you want to remove the "f$" file!"\
 print "Update the "f$" file";:yn=2:gosub getyn
 if i$<>"Y" return
 i$=fn$
 goto message

do.edit
 print "Edit "f$\
 print "Which "f$;:input @2" to edit:" i$:if i$="" return
 ready fn$:ml=1:mh=msg(0)
 a=val(i$):if (a<ml) or (a>mh) print on$"The "f$" is out of range"of$:return
 edit(0):input #msg(a),d$:copy #6,#8
 print \"Enter/Edit info now, "edit(3)" columns, 4k max"
 print "[DONE]  when finished,  [.H] for help"
 edit(1):if not edit(2) return
 kill #msg(a):print #msg(a),d$:copy #8,#6:update:return

do.delet
 print "Delete "f$\
 print "Which "f$;:input @2 " to delete:" i$:if i$="" return
 ready fn$:ml=1:mh=msg(0)
 a=val(i$):if (a<ml) or (a>mh) print on$"The "f$" is out of range"of$:return
 msg(a)=0:kill #msg(a):crunch:return

f.edit
 input @2 "Filename:" f$:if f$="" return
 if f$="/" f$=f1$
 gosub filter:gosub name.chk
 f1$=f$:i$=lg$+f$
 edit(0):copy i$,#8
 print \"Enter/Edit file now, "edit(3)" columns, 4k max"
 print "[DONE]  when finished,  [.H] for help"
 edit(1):if not edit(2) return
f.edit1
 input @2 \"Filename:" f$:if f$="" return
 if f$="/" f$=f1$
 gosub filter
 f1$=f$:i$=lg$+f$
 close:kill i$:create i$:open #1,i$
 copy #8,#1:close
 return

makedir
 print "Make Master Directory"
 print \"Low Volume  #"vl;:print chr$(8,len(str$(vl)));
 input @2 i$:if i$="" i$=str$(vl)
 lo=val(i$):if lo<vl lo=vl
 print  "High Volume #"vh;:print chr$(8,len(str$(vh)));
 input @2 i$:if i$="" i$=str$(vh)
 hi=val(i$):if hi>vh hi=vh
 print \"Create Master-Directory";:yn=2:gosub getyn
 if i$<>"Y" return
 i$=v1$+":directory"
 gosub message:ready i$:x=lo:gosub makestr
 print \"Scanning Volume [";
dir10
 z=key(0):if z<>0 return
 in$=right$("0"+str$(x),2)
 print on$ in$ of$"]";
 x$=v1$+str$(x)+":":if (fv>0) and (x>fv) x$=v2$+str$(x)+":"
 use v1$+":xcat",0,x$,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
 clear #8:ready i$
 print #msg(x),date$" "time$
dir2
 if fn$="               " copy #8,#6:goto nxtvol
 si=peek(ed+22)+peek(ed+23)*256 
 print #6,fn$" "ta$" "bu$" "right$("    "+str$(si),5)" "xd$
 call ed+3,0,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
 goto dir2 

nxtvol
 x=x+1:if (x>hi) close:update:print:return
 print chr$(8,3);:goto dir10

showmast
 print"Show Master Directory on Printer"\
 print"Low Volume: "vl;:print chr$(8,len(str$(vl)));
 input @2 i$:lv=val(i$):if i$="" lv=vl
 print"High Volume: "vh;:print chr$(8,len(str$(vh)));
 input @2 i$:hv=val(i$):if i$="" hv=vh
 x=lv-1
direct1
 x=x+1:if x>hv return
 ready v1$+":vol.headers"
 input #msg(x),vp$
 if (un<>1) and (vp$<>"") goto direct1
 edit(0):copy #6,#8
 ready v1$+":directory"
 input #msg(x),d$:if d$="" d$=date$+""
 setint(1)
 print #5,"Volume "right$("0"+str$(x),2)" - "left$(d$,8)
 copy #8,#5
 print #5,\"Filename        Typ  Blks  Xmdm  Uploaded"
 print #5,chr$(45,41)
 copy #6,#5
 print #5,chr$(12)
 setint(""):if key(1) return
 goto direct1

free
 print "Free Space"
 use v1$+":xdos","freespace "+lg$
 return

xchange
 input @2 "Filename:" f$:if f$="" return
 gosub filter:gosub name.chk
 open #1,lg$+f$:a=mark(1):close:if a print \on$"No Such File"of$:return
 ab$=f$:input @2"New Filetype:"f$:if f$="" return
 ac$=f$
 i$=lg$+ab$:i$=i$+","+ac$
 i$="T "+i$
 use v1$+":xdos",i$
 print \"File type changed"
 return

dir
 i$="c "+lg$
 if cc=2 i$="x "+lg$
 gosub add
 use v1$+":xdos",i$
 setint(""):return

add
 setint(cr$):addint(e$):addint(" "):addint(chr$(8))
 addint(chr$(21)):addint(chr$(10)):addint(chr$(11))
 addint("L"):addint("D"):return

terminate
 print "Terminate"
 print \"Terminate from "sn$
 print \"Are you sure";:yn=2:gosub getyn
 if i$<>"Y" return
 pop: link "a:main.seg","term1"
 
message
 ready " ":close:kill i$
 create i$:open #1,i$:clear #8:ed=edit(5):fill ed,255,0:poke ed,16:poke ed+1,16
 write #1,ed,2:fill ed,255,0:for x=1 to 16:write #1,ed,255:next
 write #1,ed,22:close:ready " "
 a$="T "+i$+",BIN":use v1$+":xdos",a$
 return

name.chk
 if left$(f$,2)="E." and not(flag(25)) print"E. = Elite":pop:return
 if left$(f$,2)="M." and not(flag(28)) print"M. = Board Manager":pop:return
 if left$(f$,2)="S." and not(info(5)) print "S. = Sysop":pop:return
 return

filter
 if len(f$) > 15 print on$"Filename Too Long"of$:pop:return
 if (left$(f$,1) < "A") or (left$(f$,1) > "Z") print on$"Illegal Filename"of$:pop:return 
 i$="":for p=1 to len(f$):a=asc(mid$(f$,p,1))
 if (a>64) and (a<91) goto filter1
 if (a>96) and (a<123) goto filter1
 if (a>47) and (a<58) goto filter1
 if a=46 goto filter1:else goto filter2
filter1
 i$=i$+chr$(a):next:f$=i$:return
filter2
 i$=i$+chr$(46):next:f$=i$:return
 
makestr
 fn$="               ":ta$="   ":th$="   ":bu$="     "
 mo$="         ":mt$="     "
 xd$="         ":xt$="     "
 by$="         ":a=0
 return
      
dtype
 use v1$+":xdos","getinfo "+i$:x=peek(ed+7)
 ty$=str$(x):si=peek(ed+21)+peek(ed+22)*256
 bi=peek(ed+11)+peek(ed+12)*256
 return

link.term
 link "a:main.seg","term1"

link.ae
 link "a:supertac","ae.ret"

; *** sub - routines ***

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
 if yn:l1$=l1$+cr$
 if yn=1 print "["on$"Y"of$"]";:else print "Y";
 print "/";
 if yn=2 print "["on$"N"of$"]";:else print "N";
 print ")";:gosub getone

 if i$=cr$:i$=mid$("YN",yn,1)
 if i$="Y" print "Yes":else print "No"
 yn=0:return

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
 print #1,"Error #"err" ("er$") occurred in SUPERTAC.SYS.S at "time$" "fmtdate$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."
 copy "b:snap.txt",#1
 kill "b:snap.txt"
 print #1,"----------------------------------------------------------------"
 close:goto link.term
