; *******************
; GBBS "Pro" V:2.4
; Copyright 1980-2024
; Kevin M. Smallwood
; *******************

; SuperTAC Purge segment - 7/22/2023
; Version 6.4
; Written by Larry Hawkins
; Updates and modifications by Paul Lee

warespur
 on nocar goto link.term
 ed=edit(5):sc$=chr$(12):si=99:nc=0:nl=0:nk=0
 wk=3:wc$="C":ca$="Y":ac$="L":nd$="Y":x=0
 gosub chngvl:gosub find.sdate
 print sc$\"Purge since "lc$;
 gosub chngdt
 print \"Which date:"\" C)reation (uploaded) [Default]"\" M)odification"
 gosub chngwc
 print \"Include [No Date] as date 00/00/00"\" Y)es [Default]"\" N)o"
 gosub chngnd
 print \"Action:"\" L)ist [Default]"\" P)urge"
 gosub chngac:if ac$="L" gosub chkprt:goto wares1
 print \"Confirm actions:"\" Y)es [Default]"\" N)o"\" Q)uit"
 gosub chngcn
wares1
 gosub chkok  
 push link.sys
 print \\"SuperTAC Purge"
 print "Working..."
 xx=lo:gosub makestr
dir10
 z=key(0):if z<>0 return
 ready v1$+":vol.headers"
 input #msg(xx),vp$
 if (un<>1) and (vp$<>"") goto nxtvol
 if si<>0 print #x,\\"Scanning Volume ["on$;
 in$=right$("0"+str$(xx),2)
 print #x,in$of$"]";
 x$=v1$+str$(xx)+":":if (fv>0) and (xx>fv) x$=v2$+str$(xx)+":"
 use V1$+":xcat",0,x$,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
 si=0:ww=0
dir2
 if fn$="               " goto nxtvol
 gosub check.date:if d goto dir3
 si=peek(ed+22)+peek(ed+23)*256
 ww=ww+1:nc=nc+1:if ww=1 print #x,""
 print #x,fn$" "ta$" "bu$" "right$("    "+str$(si),5)" "xd$" "mo$" ";
 gosub kill.list
dir3
 call ed+3,0,fn$,ta$,th$,bu$,mo$,mt$,xd$,xt$,by$
 goto dir2 

nxtvol
 xx=xx+1:if (xx>hi) close:update:gosub prnt.done:return
 print #x,chr$(8,3);:goto dir10

prnt.done
 print #x,\"Number considered: "nc
 if ac$="L" print #x,"Number listed:     "nl
 if ac$="P" print #x,"Number killed:     "nk
 print \"Purge complete":return

link.sys
 link "a:supertac.sys"

check.date
 gosub find.date
 if val(mid$(d$,7,2))>val(mid$(lc$,7,2)) d=1:return
 if val(mid$(d$,7,2))<val(mid$(lc$,7,2)) d=0:return
 if val(mid$(d$,1,2))>val(mid$(lc$,1,2)) d=1:return
 if val(mid$(d$,1,2))<val(mid$(lc$,1,2)) d=0:return
 if val(mid$(d$,4,2))>=val(mid$(lc$,4,2)) d=1:return
 if val(mid$(d$,4,2))<val(mid$(lc$,4,2)) d=0:return
 d=0:return

chngvl
 print \\"Low Volume  #"vl;:print chr$(8,len(str$(vl)));
 input @2 i$:if i$="" i$=str$(vl)
 lo=val(i$):if lo<vl lo=vl
 print  "High Volume #"vh;:print chr$(8,len(str$(vh)));
 input @2 i$:if i$="" i$=str$(vh)
 hi=val(i$):if hi>vh hi=vh
 return

chngdt
 print chr$(8,8);:input @2 i$
 if i$="" return
 if len(i$)<>8 return
 if (mid$(i$,3,1)<>"/") or (mid$(i$,6,1)<>"/") return
 a=val(mid$(i$,1,2)):if (a<1) or (a>12) return
 a=val(mid$(i$,4,2)):if (a<1) or (a>31) return
 a=val(mid$(i$,7,2)):if (a<1) or (a>99) return
 lc$=i$:return

chngwc
 print "Which: "wc$;:print chr$(8,1);:input @2 i$
 if i$="" return
 if len(i$)<>1 return
 if i$="C" or i$="M" wc$=i$:return
 return
 
chngnd
 print "Which: "nd$;:print chr$(8,1);:input @2 i$
 if i$="" return
 if len(i$)<>1 return
 if i$="Y" or i$="N" nd$=i$:return
 return

chngac
 print "Which: "ac$;:print chr$(8,1);:input @2 i$
 if i$="" return
 if len(i$)<>1 return
 if i$="L" or i$="P" ac$=i$:return
 return
 
chkprt
 print \"Use the printer: N";:print chr$(8,1);:input @2 i$
 if i$="" return
 if len(i$)<>1 return
 if i$="Y" x=5
 return

chngcn
 print "Which: "ca$;:print chr$(8,1);:input @2 i$
 if i$="" return
 if len(i$)<>1 return
 if i$="Y" or i$="N" ca$=i$:return
 return
 
find.sdate
 mo=val(left$(date$,2))
 da=val(mid$(date$,4,2))
 yr=val(mid$(date$,7,2))
 da=da-(wk*7):if da<1 da=da+30:mo=mo-1:if mo<1 mo=1:yr=yr-1
 lc$=right$("00"+str$(mo),2)+"/"+right$("00"+str$(da),2)+"/"+str$(yr)
 return
 
find.date
 d$="98/98/98":dc$=xd$:if wc$="M" dc$=mo$
 if dc$="[No Date]" and nd$="Y" d$="00/00/00":return
 if mid$(dc$,4,3)="Jan" d$="01/":goto find.fin
 if mid$(dc$,4,3)="Feb" d$="02/":goto find.fin
 if mid$(dc$,4,3)="Mar" d$="03/":goto find.fin
 if mid$(dc$,4,3)="Apr" d$="04/":goto find.fin
 if mid$(dc$,4,3)="May" d$="05/":goto find.fin
 if mid$(dc$,4,3)="Jun" d$="06/":goto find.fin
 if mid$(dc$,4,3)="Jul" d$="07/":goto find.fin
 if mid$(dc$,4,3)="Aug" d$="08/":goto find.fin
 if mid$(dc$,4,3)="Sep" d$="09/":goto find.fin
 if mid$(dc$,4,3)="Oct" d$="10/":goto find.fin
 if mid$(dc$,4,3)="Nov" d$="11/":goto find.fin
 if mid$(dc$,4,3)="Dec" d$="12/":goto find.fin
 return
find.fin
 d$=d$+mid$(dc$,1,2)+"/"+mid$(dc$,8,2)
 return

makestr
 fn$="               ":ta$="   ":th$="   ":bu$="     "
 mo$="         ":mt$="     "
 xd$="         ":xt$="     "
 by$="         ":a=0
 return
 
chkok
 print sc$\"You have chosen the following:"
 Print "Starting volume   : "lo
 print "Stopping volume   : "hi
 print "Action            : ";
 If ac$="L" print "List files only":else print "Purge files"
 print "Printer           : ";
 if x=0 print "Off":else print "On"
 print "Date for action   : ";
 if wc$="C" print "Creation (uploaded) date":else Print "Modification date"
 print "Include [No Date] : ";
 if nd$="Y" print "Yes":else print "No"
 print "Date of action    : "lc$:if ac$="L" goto chkok1
 Print "Confirm each      : ";
 if ca$="Y" print "Yes":else print "No"
chkok1
 print \"Is this selection correct: Y";
 print chr$(8,1);:input @2 i$
 if i$="" return
 if len(i$)<>1 return
 if i$="Q" pop:goto link.sys
 if i$="N" pop:goto warespur
 return
 
kill.list
 sb=peek(ed+7)
 if (ac$="L") and (sb<>227) print #x,"Skipped":nl=nl+1:return
 if ac$="L" print #x,"":nl=nl+1:return
 if ca$="N" goto kill.it
 gosub chk.kill:if kf$="N" print "Passed":return
kill.it
 if sb <> 227 print "Skipped":return
 print "Killed":nk=nk+1
 kill fn$ 
 return

chk.kill
 kf$="Y"
 print "Kill: "kf$;
 yn=2:gosub getyn
 kf$=i$
 return

link.term
 link "a:main.seg","term1"

; *** sub - routines ***

; get a key
; l1$ is the list of available keys
getone
; print ": ";
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
 print "): ";:gosub getone

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
 print #1,"Error #"err" ("er$") occurred in PURGE.SEG.S at "time$" "fmtdate$"."
 print #1,a1$" "a2$ "(#"un") was online when this occured."
 copy "b:snap.txt",#1
 kill "b:snap.txt"
 print #1,"----------------------------------------------------------------"
 close:goto link.term
