 PAG
*-------------------------------
* Default Drivspecs
*-------------------------------
* to be created by the config program
*-------------------------------

START RTS

TOVAL DB 159 ;value for timeout (159 = 5 mins)
 DA BBS_PRG ;location of startup setment name
 DB #>CODEND ;location of start of segment space

 DB #>FILTER-START ;location of filter

 DA START1 ;init acos w/ modem interupt
 DA START2 ;init acos w/out modem interupt
 DA FATAL6
 DA TOPBUF

STPCHR ASC ' ' ;stop message char
NXTCHR ASC 'N' ;next message char

WIDTH DB 4 ;index for default
 DB 32,40,64,80

DEVNAM STR '/GBBS.PRO/PROGRAM' A
 STR '/GBBS.PRO/SYSTEM' B
 STR '/GBBS.PRO/GFILES' C
 STR '/GBBS.PRO/DOWNLOAD' D
 STR '/GBBS.PRO/UPLOAD' E
 STR '/GBBS.PRO/BULLETINS' F
 STR '/GBBS.PRO/MAIL' G
 STR '/GBBS.PRO/TEMP' H
 DB 0 I
 DB 0 J
 DB 0 K
 STR '/GBBS.PRO/STAC/VOL.' L
 DS \
