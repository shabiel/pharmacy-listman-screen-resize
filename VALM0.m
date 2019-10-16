VALM0 ;MJK/ALB - List Manager (cont.);08:19 PM  17 Jan 1993 ; 5/10/17 10:47am
 ;;1.0;List Manager;;Aug 13, 1993
 ; Original Routine authored by US Dept of Veteran Affairs
 ; Tag TEMP modified by DSS in 2016
 ;
INIT(NAME,PARMS) ;
 D STACK
 K VALMBCK,VALMQUIT,VALMHDR
 S VALM(0)=$G(PARMS)
 I NAME["^",'$$SETUP^VALM00(.NAME) S VALMQUIT="" G INITQ
 I NAME'["^",'$$TEMP(.NAME) S VALMQUIT="" G INITQ
 D TERM:'VALMEVL,CALC
INITQ K VALMX,X Q
 ;
TERM ; -- set up term characteristics
 D HOME^%ZIS
 S VALMWD=IOM,X=$$IO_";IOBON;IOBOFF;IOSGR0" D ENDR^%ZISS
 S VALMSGR=$S($G(IOSGR0)]"":IOSGR0,1:$G(IOINORM))
 ; -- cursor off/on to avoid bouncing
 S (VALMCON,VALMCOFF)=""
 I $E(IOST,1,4)="C-VT" S VALMCOFF=$C(13,27,91)_"?25l"_$C(13),VALMCON=$C(13,27,91)_"?25h"_$C(13)
 S X="XQORM6" X ^%ZOSF("TEST") D:$T INIT^XQORM6
 S VALMIOXY=^%ZOSF("XY")
 Q
 ;
IO() ; -- what device params
 Q "IORVON;IORVOFF;IOIL;IOSTBM;IOSC;IORC;IOEDEOP;IOINHI;IOINORM;IOUON;IOUOFF"
 ;
STACK ; -- stack vars
 I $D(VALMEVL) D
 .K ^TMP("VALM STACK",$J,VALMEVL)
 .; -- stack'em
 .I $O(^TMP("VALM STACK",$J,VALMEVL,"VALM",""))="" S X="" F  S X=$O(VALM(X)) Q:X=""  S ^(X)=VALM(X)
 .I $O(^TMP("VALM STACK",$J,VALMEVL,"OTHER VARS",""))="" F X="VALMMENU","VALMCAP","VALMAR","VALMCNT","VALMBG","VALMLST","VALMCC","VALMLFT" S ^(X)=$G(@X)
 .K VALMBG,VALM,VALMLFT
 ;
 S VALMEVL=$S($D(VALMEVL):VALMEVL+1,1:0)
 I 'VALMEVL D
 .F X="VALM DATA","VALM VIDEO","VALM VIDEO SAVE","VALMAR" K ^TMP(X,$J)
 .K VALMBG,VALM,VALMLFT
STACKQ Q
 ;
POP ; -- clean up and unstack vars
 K VALMLFT,VALMMENU,VALMCAP,VALMHDR,VALMPGE,VALMUP,VALMDN,VALMDDF,VALMCC,VALMAR,VALMCNT,VALM,VALMBG,VALMLST,LN
 K ^TMP("VALM DATA",$J,VALMEVL) D KILL^VALM10()
 ;
 ; -- final clean up
 I 'VALMEVL D  G POPQ
 .D CLEAR^VALM1
 .S X=VALMWD X ^%ZOSF("RM")
 .S Y=$$IO F I=1:1 S X=$P(Y,";",I) Q:X=""  K @X
 .K IOBON,IOBOFF,IOSGR0,VALMSGR
 .K Y,X,I,VALMEVL,VALMWD,VALMFIND,VALMIOXY,VALMKEY,VALMCON,VALMCOFF,VALMQUIT
 .S X="XQORM6" X ^%ZOSF("TEST") D:$T EXIT^XQORM6
 ;
 ; -- unstack'em
 S VALMEVL=$S(VALMEVL:VALMEVL-1,1:0)
 I $O(^TMP("VALM STACK",$J,VALMEVL,"VALM",""))]"" S X="" F  S X=$O(^(X)) Q:X=""  S VALM(X)=^(X)
 I $O(^TMP("VALM STACK",$J,VALMEVL,"OTHER VARS",""))]"" S X="" F  S X=$O(^(X)) Q:X=""  S @X=^(X)
 K ^TMP("VALM STACK",$J,VALMEVL)
 D COL^VALM
 I $G(^TMP("VALM DATA",$J,VALMEVL,"HIDDEN"))'=$P($G(VALMKEY),U,2) D KEYS^VALM00($G(^("HIDDEN")),1)
 S VALMBCK="R",(VALMUP,VALMDN)=""
POPQ Q
 ;
TEMP(NAME) ; -- use list template
 N VALM0,VALM1,NODE
 S VALM=+$O(^SD(409.61,"B",NAME,0)),VALM0=$G(^SD(409.61,VALM,0)),VALM1=$G(^(1))
 G:VALM0="" TEMPQ
 ;
 F NODE="ARRAY","HDR","EXP","HLP","INIT","FNL" S VALM(NODE)=$G(^SD(409.61,VALM,NODE))
 S VALM("IFN")=VALM D COL^VALM
 S VALM("TYPE")=$P(VALM0,U,2)
 S VALM("TM")=$P(VALM0,U,5)
 S VALM("BM")=$P(VALM0,U,6)
 ; DSS/SMH BEGIN MODS - Use IOSL by default for bottom margin (BM was previous written to an offset of 24)
 D
 . I $G(XQY),$$GET^XPAR("ALL","VFD VALM BM BY OPTION",XQY,"I") QUIT
 . S VALM("BM")=$S($G(IOSL):IOSL-(24-$P(VALM0,U,6)),1:$P(VALM0,U,6))
 ; DSS/SMH END MODS
 S VALM("FIXED")=$S($G(^SD(409.61,VALM("IFN"),"COL",+$O(^SD(409.61,VALM("IFN"),"COL","AIDENT",1,0)),0))]"":$P(^(0),U,2)+$P(^(0),U,3),1:0)
 S VALM("RM")=$S($P(VALM0,U,4):$P(VALM0,U,4),1:80)
 ; DSS/SMH BEGIN MODS - Use IOM by default for right margin
 D
 . I $G(XQY),$$GET^XPAR("ALL","VFD VALM BM BY OPTION",XQY,"I") QUIT
 . S VALM("RM")=IOM
 ; DSS/SMH END MODS
 S VALMCC=+$P(VALM0,U,8)
 S VALM("ENTITY")=$P(VALM0,U,9)
 S VALM("PROTOCOL")=$P(VALM0,U,10)
 S VALM("PRT")=$P(VALM1,U)
 S VALM("TITLE")=$S($P(VALM0,U,11)]"":$P(VALM0,U,11),1:$P(VALM0,U))
 S VALM("MAX")=$S($P(VALM0,U,12):$P(VALM0,U,12),1:1)
 S VALM("DAYS")=$S($P(VALM0,U,13):$P(VALM0,U,13),1:30)
 S VALM("DEFS")=$S($P(VALM0,U,14)=0:0,1:1)
 S VALM("HIDDEN")=$P(VALM1,U,2)
 I VALM("HIDDEN")="",VALM("TYPE")=2 S VALM("HIDDEN")="VALM HIDDEN ACTIONS"
TEMPQ Q VALM0]""
 ;
CALC ; -- calculate derived parmeters
 N NODE,X,I,X,Y
 F NODE="HIDDEN","DAYS","EXP","HLP","INIT","FNL" I $G(VALM(NODE))]"" S ^TMP("VALM DATA",$J,VALMEVL,NODE)=VALM(NODE) K VALM(NODE)
 S VALMAR=$E(VALM("ARRAY"),2,50) K VALM("ARRAY")
 S:VALMAR="" VALMAR="^TMP(""VALMAR"",$J,VALMEVL)"
 S VALM("LINES")=(VALM("BM")-VALM("TM"))+1
 S:VALM("TM")<3 VALM("TITLE")=" "_VALM("TITLE")
 S:VALM("TYPE")=2 VALM("DEFS")=1
 ; -- set up protocol
 S X="VALM DISPLAY" ; default protocol
 I VALM("TYPE")=1,VALM("PROTOCOL")]"" S X=VALM("PROTOCOL")
 I VALM("TYPE")=2,$D(^TMP("VALM DATA",$J,VALMEVL,"EXP")) S X=X_" W/EXPAND"
 S VALM("PROTOCOL")=+$O(^ORD(101,"B",X,0))_";ORD(101,"
 ;
 S (VALMUP,VALMDN)=""
 I VALMCC S Y=$$IO F I=1:1 S X=$P(Y,";",I) Q:X=""  I $G(@X)="" S VALMCC=0 Q
 S VALMCAP=$$CAPTION^VALM D ATR^VALM00
 I $G(^TMP("VALM DATA",$J,VALMEVL,"HIDDEN"))'=$P($G(VALMKEY),U,2) D KEYS^VALM00($G(^("HIDDEN")),1)
 S:$G(^DISV($S($D(DUZ)#2:DUZ,1:0),"VALMMENU",VALM("PROTOCOL")))="" ^(VALM("PROTOCOL"))=1 S VALMMENU=^(VALM("PROTOCOL"))
 Q
