; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2024
; Kevin M. Smallwood
; *******************

; logon segment - 12/30/2023

 public get.pass

 on error goto error

 clear
 set pa$=ram,8:set ph$=ram+8,12
 when$=ram+20:flag=ram+22
 nibble=ram+27:byte=ram+37
 sc$=chr$(12):cr$=chr$(13):es$=chr$(27)

start
 modem(1):close:print sc$

 open #1,"b:data"
 input #1,c1,c2,ct,ct$,da$
 input #1,nu,mn,wm,tm\lu$
 close

 open #1,"b:data1"
 input #1,sn$\sys$\sv$
 input #1,md$\s$\n$
 input #1,lg,fv
 close

 date$=da$:da$=date$

 if ct$=da$ goto start1

; start a new day
 ct=1:ct$=da$

start1
 cn$=str$(c2):if c1 cn$=str$(c1)+right$("000"+cn$,4)
 text:home:x=peek(33)
 x$=" :::::::::::::::::::::::::::::::::::::":y=1:gosub center
 x$=':          GBBS "Pro"  V:2.4          :':y=y+1:gosub center
 x$=': Copyright 1980-2024 Kevin Smallwood :':y=y+1:gosub center
 x$=' :::::::::::::::::::::::::::::::::::::':y=y+1:gosub center

 x$=sn$:y=y+2:gosub center
 x$="Awaiting call "+cn$+" on "+fmtdate$:y=y+2:gosub center
 x$="This will be call "+str$(ct)+" today":y=y+1:gosub center
 x$="Last Caller - "+lu$:y=y+1:gosub center
 t1$=mid$(" "+time$,2)
 x$=t1$:if right$(t1$,1)=" " then x$=left$(t1$,8)
 x$="System reset at "+x$:y=y+1:gosub center

; mail & feedback
 z$="":f$="g:feedback":open #1,f$:a=mark(1):close
 if not a z$="feedback & "
 f$="g:mail.1":open #1,f$:a=mark(1):close
 if not a z$=z$+"mail":else if len(z$) z$=left$(z$,(len(z$)-3))
 if z$="" z$="no mail"
 x$=sy$+" has "+z$+" waiting":y=y+2:gosub center

; new users
 open #1,"b:request"
 if not mark(1) x$="There are new users":y=y+1:gosub center
 close
 
; system errors
 open #1,"b:sys.errors"
 if not mark(1) x$=" System errors have occured ":y=y+2:poke 50,255:gosub center:poke 50,0
 close

; acos.time
 x$="Current time: "
 y=len(x$)+11:if right$(time$,1)=" ":y=len(x$)+8
 print @ (x/2)-(y/2),23 x$
 use "b:acos.time",((x/2)-(y/2))+13,22

 modem(0):bb=0:home:clock(0)

; calc idle time into b1:b2:b3 -- hh:mm:ss
 t2$=mid$(" "+time$,2)
 b4=val(mid$(t2$,1,2)):b5=val(mid$(t2$,4,2)):b6=val(mid$(t2$,7,2))
 a1=val(mid$(t1$,1,2)):a2=val(mid$(t1$,4,2)):a3=val(mid$(t1$,7,2))
 if b6<a3 b3=60+(b6-a3):b5=b5-1:else b3=b6-a3
 if b5<a2 b2=60+(b5-a2):b4=b4-1:else b2=b5-a2
 b1=(b4-a1)+((b4<a1)*24)
;
 d=0:on nocar goto start
 tone(100,50):tone(125,50):tone(150,50):cm$=date$+" "+time$
 i$="":if info(0) goto online
 print "1) Auto Logon    ";:poke 50,255:print "2) Normal Logon":poke 50,0
 print "3) System Logon  4) Logon as a user"\
 print "Which ? ";:get i$
 if (i$="1") or (i$="Y") then x=1:i$="":goto autolog
 if (i$="3") or (i$="S") then x=1:i$="":d=19:goto autolog
 if (i$<>"4") and (i$<>"U") goto online
 input \\"User number to log on as: " i$:x=val(i$):i$="":goto autolog

online
 print sc$:print "(*> Welcome to "sn$" <*)"
 if info(2)=128:x$="38400":else x$=str$(info(2)*300)
 if info(0) print \"Connect at ["x$"] baud!"
 if info(0) gosub protocol:print \x$
 print \'New users type "NEW"'

logon
 print \"Account Number"
 un=0:input "-->" i$:x=val(i$)
 if i$="NEW" goto new.user

 print \"Enter Password"
 echo="X":input "-->" i$:echo=""
 print \"Verifying your account..."

logon2
 if (x<1) or (x>nu) goto bad.user
 i$=left$(i$+"     ",8)
autolog
 gosub rd.user:if d1$="" goto bad.user
 if i$=pa$ goto login
 if i$="" goto login

bad.user
 bb=bb+1
 if bb>2 print \"Illegal Access":goto start
 print \"You must have an account to access this"
 print "system. Please call back and logon as a"
 print '"NEW" user.'
 goto logon

; *** New User Logon ***

new.user
 print \"Enter your real full name [20 chars max]"
 input @3 ":" i$:if i$="" goto new.user
 if left$(i$,1)=" " print \"No leading spaces, please.":goto new.user
 if len(i$)>20 print \"20 characters only, please.":goto new.user
 if len(i$)<2 print "Too small."\:goto new.user
 if instr(",",i$,1) print \"No commas, please.":goto new.user
 gosub mixed
 d3$=i$:a$="":for l=1 to len(i$)
 x=asc(mid$(i$,l,1)):if x>96 then x=x-32
 a$=a$+chr$(x):next:x=instr(" ",a$,1)
 if not(x) d2$=a$:d1$=".":goto get.city
 d1$=left$(a$,x-1):d2$=mid$(a$,x+1)

get.city
 print \"City [16 chars max]"
 input @3 ":" d4$
 if left$(d4$,1)=" " print \"No leading spaces, please.":goto get.city
 if len(d4$)>16 print "Too long, try again.":goto get.city
 if len(d4$)<2 print "Too small."\:goto get.city
 i$=d4$:gosub mixed:d4$=i$

get.state
 print \"State [Form: XX]"
 input ":" d5$
 if len(d5$)<>2 print "Two letter code only, please.":goto get.state
 fill ram,58,0

get.phone
 print \"Phone number [Form: ###-###-####]"
 input ":" i$
 if len(i$)<>12 print "Follow given format, please.":goto get.phone
 a$=left$(i$,3)+"-"+mid$(i$,5,3)+"-"+right$(i$,4)
;
; force only numbers
 for l=1 to 3:x=asc(mid$(a$,l,1)):if x<48 or x>57 l=3:next:goto bad.phone
 next
 for l=5 to 7:x=asc(mid$(a$,l,1)):if x<48 or x>57 l=7:next:goto bad.phone
 next
 for l=9 to 12:x=asc(mid$(a$,l,1)):if x<48 or x>57 l=12:next:goto bad.phone
 next
 ph$=a$:goto chk.info
bad.phone
 print \"Numeric input only, please.":goto get.phone

chk.info
 print \"We have the following."\
 print d3$\d4$", "d5$\ph$\:input @2 "Is this correct (Y/[N]) ? " i$
 if left$(i$,1)<>"Y" goto logon

get.guest
 nibble(0)=width(0)-1:edit(4)=0
 edit(3)=width(nibble(0)+1)-1
 nibble(5)=6:byte(7)=0
 print \'Type "P" for a password or "G" for'
 print "guest access."
 input @0 "-->" i$
 if i$="P" goto get.pass
 if i$<>"G" goto get.guest

 x=0:pa$="GUEST   ":flag(0)=1
 lc$="UNKNOWN":goto login

get.pass
 flag(0)=0:on nocar goto start
 print \"Finding your account."
 print \"Checking "nu" user files...[001]";
 open #1,"b:users"
 a=1:z=0:a$=d1$+","+d2$

add.user
 position #1,128,a
 input #1,b$,c$
 i$=b$+","+c$
 if a$=i$ close:print \\"Your name is being used.":goto logon

 if (i$=",") and (z=0) then z=a
 a=a+1:print chr$(8,4);o$right$("00"+str$(a),3)of$"]";
 if a<=nu goto add.user
 a=z:if z=0 then nu=nu+1:a=nu
 close

 print sc$:copy "b:sys.newinfo":x=0:print
 create "b:temp":open #1,"b:sys.questions":open #2,"b:temp"

info
 input #1,a$:if a$="*" goto info.1
 if eof(1) goto info.2
 print a$:goto info

info.1
 input \":" i$:print #2,i$:goto info

info.2
 print \"Would you like to leave the Sysop"
 print "a Message (Y/[N]): ";
 input @2 i$:if left$(i$,1)<>"Y" goto info.3
 print \"Enter message now, 40 columns, 4k max"
 print "[DONE]  when finished,  [.H] for help"
 edit(0):edit(1):if not edit(2) goto info.3
 print #2:append #2:copy #8,#2:append #2:print #2

info.3
 close:edit(0):copy "b:temp",#8:kill "b:temp"
info.3a
 print \"Please enter a password [4-8 Characters]"
 input @2 ":" i$:if i$="" for x=1 to 5:i$=i$+rnd$:next
 x=len(i$):if x<4 print \"Password must be at least 4 chars":goto info.3a
 pa$=left$(i$+"     ",8)
 print \\"You will be user #"a
 print "Password will be :"pa$
 print \"Please write them down as you"
 print "will need them next time you call."
 when$=date$
 open #1,"b:users"
 position #1,128,a
 print #1,d1$,d2$\d3$\d4$,d5$
 position #1,128,a,70
 write #1,ram,58:close

 create "b:request":open #1,"b:request":a$="(> "
 append #1:print #1,a\a$"NEW USER DATA"
 print #1,a$;d3$\a$;d4$", "d5$\a$;"#"a"-"pa$
 print #1,a$;ph$\a$;date$" "time$\:append #1
 copy #8,#1:append #1:print #1,chr$(1):close
 mb$="g:mail."+str$(a):kill mb$

; send welcome email
 open #1,"b:welcome.email":if mark(1) close:goto info4
 close:gosub msg:ready mb$
 print #msg(1),date$" "time$\"Sysop (#1)",1\"Awaiting Reply"\"Welcome"\0
 copy "b:welcome.email",#6
 msg(1)=1:update:ready " "

info4
 print \"Press <CR> to enter "sn$;
 input @3 i$:x=a:i$=pa$:goto logon2

; *** Main Logon Routine ***

login
 if lc$<>date$ then nibble(6)=0:flag(36)=0:byte(7)=0
 lr=byte(5)+byte(6)*256:if lr>mn then lr=0
 nb=lr:un=x:info(3)=byte(0):b=byte(7):if flag(1) flag(0)=0
 if (b<nibble(5)*10) or flag(34) goto login1
 print \\"Daily time expired. Call tomorrow":goto start
login1
 if (flag(34) and (nibble(5)=0)) b=0:goto login1a
 b=((nibble(5)*10)-byte(7))*60
login1a
 clock(2)=b:b=((clock(2)-clock(1))/60)+1
 a1$=d1$:a2$=d2$:a3$=d3$:a4$=d4$:a5$=d5$
 tc=byte(1)+nibble(1)*256:bp=byte(2)+nibble(2)*256
 dl=byte(3)+nibble(3)*256:ul=byte(4)+nibble(4)*256

; ul/dl bytes
 u1=byte(10)+byte(11)*256:u2=byte(12)+byte(13)*256
 d1=byte(14)+byte(15)*256:d2=byte(16)+byte(17)*256
 ul$=str$(u2):if u1 ul$=str$(u1)+right$("000"+str$(u2),4)
 dl$=str$(d2):if d1 dl$=str$(d1)+right$("000"+str$(d2),4)

 info(5)=flag(34):if not flag(1) info(5)=0
 if (not info(5)) or (not info(0)) goto login2

 print \"Remote Password":echo="X":input "-->" i$
 echo="":if i$<>sv$ then info(5)=0

login2
 print \"Logging you into the system"

; top box statistics
 a$=right$("   "+str$(un),4):clear #9
 print #9,cn$,a1$" "a2$" of "a4$", "a5$,nibble(6)
 print #9,tc,ul,dl,bp,ph$,lc$,a$,pa$
 for x=1 to 34:print #9,flag(x);:next
 print ^

; write to caller log
 f$="b:log.caller":create f$:open #1,f$
 input #1,x:x=x+1:if x>20 x=1
 a=clock(1)
 position #1,80,x
 print #1,a/60,a mod 60
 position #1,80,x,10
 if info(2)=128:x$="38400":else x$=str$(info(2)*300)
 print #1,d3$,date$" "time$,x$
 mark(1)=0:print #1,x
 close

; check terminal emulation
 gosub termemul

 f$="g:mail."+str$(un):open #1,f$:em=mark(1):close
 f$="g:feedback":open #1,f$:fb=mark(1):close

 print sc$ \"User Name      : "left$(a3$+chr$(32,20),20)"   ";
 print "Last Date On   : "lc$
 print "Caller Number  : "left$(cn$+chr$(32,20),20)"   ";
 print "Today is       : "fmtdate$
 print "Caller # Today : "left$(str$(ct)+chr$(32,20),20)"   ";
 print "Terminal Emul. : "on$x$of$
 print "Mail Waiting   : ";
 if (not em) print on$"Yes"off$chr$(32,20);:else print "No"chr$(32,21);
 if not info(5) print \:goto login3

 print "Feedback       : ";
 if (not fb) print on$"Yes"off$:else print "No"

 if b1=1 a$=str$(b1)+" hour ":else a$=str$(b1)+" hours "
 if b2=1 b$=str$(b2)+" minute":else b$=str$(b2)+" minutes"
 c$=" and ":if b3=1 c$=c$+str$(b3)+" second.":else c$=c$+str$(b3)+" seconds"
 print \ sn$" was idle for "a$;:if edit(3)<79 print
 print b$c$\

login3
 if lr<wm then f$="b:sys.news":gosub show.file:print
 if lr+1=wm then lr=wm

login4
 bb=1:a=mn-lr:if lr=0 then a=tm
 if a gosub new.msgs

 if not info(5) goto login5
 open #1,"b:request":a=mark(1):close
 if not a poke 50,255:print \on$"There are new users"of$:poke 50,0

login5
 edit(4)=nibble(0)/4:ch=1:edit(3)=width((nibble(0) mod 4)+1)-1
 if (info(5)) and (d=19) link "a:system.seg"
 if em goto login6
 print \"Would you like to read your mail now ["on$"Y"of$"/N]: ";
 get i$:if i$="N" print "No":goto login6
 print "Yes":link "a:mail.seg","mailread"

login6
 link "a:main.seg"

; *** Sub - Routines ***

; New bulletin scan
new.msgs
 print \on$"The following boards have new messages."of$\
 bb=0
new.msg1
 bb=bb+1
 bl=bb:open #1,"b:data2":mark(1)=1120:input #1,ab
 if bb>ab close: bf$="":bl=0:return
 position #1,128,bb+8
 input #1,bn$\bf$\b3,b4\bs,bs$
 b1=1:if b3 then b1=flag(b3)
 b2=1:if b4 then b2=flag(b4)
 close: if bf$="" then bl=0:return
 if not b1 goto new.msg1
 if (b1) ready bf$:nn=nb
 if nn>msg(msg(0)) goto new.msg1
 x=msg(0):if not lr z=x:else gosub new.msg2
 print "Board #"right$((" "+str$(bb)),2)": "on$;bn$;of$" -> "on$;z;of$" new"
 goto new.msg1
new.msg2
 setint("")
 if nn=<msg(x) a=x:x=x-1:if x goto new.msg2
 x=msg(0):z=(x+1)-a:return

; create storage file up to 'y' entries with 'z' k in storage
msg
 y=128:z=512
 y=(y/128)*128:z=(z/128)*128:l=(y/32)+(z/128)
 fill ram2,64,0:poke ram2,z/128:poke ram2+1,y/32
 ready " ":close
 kill mb$:create mb$:open #1,mb$
 write #1,ram2,8:fill ram2,64,0:for x=1 to l:write #1,ram2,64
 write #1,ram2,64:next:close:ready " "
 a$="T "+bf$+",BIN":use "b:xdos",a$
 print "Done.":return

rd.user
 open #1,"b:users"
 position #1,128,x
 input #1,d1$,d2$\d3$\d4$,d5$
 position #1,128,x,70
 read #1,ram,58
 lc$=mid$(" "+when$,2)
 close #1
 return

show.file
 setint(1):print \s$\:copy f$:setint(""):return

; show x$ centered at line y
center
 print @ (x/2)-len(x$)/2,y x$
 return

; check for terminal emulation
termemul
 te=0:on$="":off$="":x$="Plain Text"
 if not info(0) x$="Local":return

; check for ansi
ansichk
 print chr$(27)"[6n"
 for i=1 to 100
 x=key(0)
 if (x=0) and (zz=1) i=100:goto ansinext
 if x=27 zz=1:te=2
ansinext
 next
 if te=2 goto termvars

; check for proterm
 setint(chr$(29)) 
 print chr$(5);chr$(1,info(2)*15); 
 for i=1 to 100
 if key(0)=29 te=1:i=100
 next:setint("")

termvars
 if te=1 x$="ProTerm Special":on$=chr$(15):off$=chr$(14)
 if te=2 x$="ANSI":on$=chr$(27)+"[7m":off$=chr$(27)+"[0m"
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

protocol
 x$="":y$="":x=peek(4540):y=peek(4541)
 x$="No Error Correction"
 if x=71 x$="LAP-B Error Correction"
 if x=72 x$="LAP-B/HDX Error Correction"
 if x=73 x$="AFT Error Correction"
 if x=74 x$="X.25/LAP-B Error Correction"
 if x=75 x$="X.25/LAP-B/HDX Error Correction"
 if x=76 x$="X.25/LAP-B/AFT Error Correction"
 if x=77 x$="LAP-M Error Correction"
 if x=78 x$="LAP-M/HDX Error Correction"
 if x=79 x$="LAP-M/AFT Error Correction"
 if x=80 x$="Alternative/MNP Error Correction"

 y$="No Compression"
 if y=66 y$="Class 5 Compression (MNP 5)"
 if y=67 y$="V42.bis Compression"
 if y=68 y$="Hayes Adaptive Data Compression"
 x$=x$+" & "+y$+" detected."
 return

; report an error
error
 close:on error:
 use "b:snapshot","b:snap.txt"
 print\sc$"A fatal error has occured. One moment, please..."\
 open #1,"b:error.list":position #1,32,err:input #1,er$:close
 f$="b:sys.errors":create f$:open #1,f$:append #1
 print #1,"Error #"err" ("er$") occurred in LOGON.SEG.S at "time$" on "date$"."
 open #2,"b:snap.txt"
 copy #2,#1
 print #1,"----------------------------------------------------------------"
 close: kill "b:snap.txt"
 goto start
