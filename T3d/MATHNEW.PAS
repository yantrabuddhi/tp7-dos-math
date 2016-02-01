{$M 2048,0,2048}
{stack was overflowing in case of excessive recursions like in file
 'recr_tst.fnc' when default was set.}
{$R-,S-,L-}
(**************************************************************************)
PROGRAM MATHEMATICS;
(**************************************************************************)
USES CRT,GRAF16,EVAL,MOUSE;
{PURPOSE TO DISPLAY 1 FUNCTION AT A TIME,(*CAN USE FOR DIFFERENTIATING*)}
{FOR AREAS,CURVES i.e INTEGRATION- MORE THAN A GRAPH AT A TIME}
{ZOOM FEATURE IS TO BE CORRECTED}
{A good software for graph should provide the user with handy,analytic
things like a pop-up scientific calculator & function value evaluater
at a perticular value along with other graph functions, as this enhances
the vision of user towards graph analysis.}
(**************************************************************************)
CONST MAXBUTNS=23;
      FNTFILE='DEFAULT.FNT';
      Hlpfile='Math.hl';
      AXIS=5;
      LIN=1;
(**************************************************************************)
TYPE BUTN=RECORD
     {graphic:boolean;if grafic then icon:icn(bitmap)}
     X1,Y1,X2,Y2:INTEGER;
     FORCOL,BKCOL,PMARGIN,RMARGIN,GCOL,DCOL:BYTE;{DCOL=RMARGIN}
     TOGGLE,SCROLL:BOOLEAN;
     {Textcol- if Pressable=false}
     VERT:BOOLEAN;{VERTICAL WRITE}
     DOWN:BOOLEAN;{WRITE DOWNWARDS}
     NAME:STRING;
     END;{scroll text i/o function to be added}

     FUNCFILE = RECORD
     XMIN,YMIN,XMAX,YMAX:REAL;
     NAME:STRING;
     END;

    Hlp_Page=array[1..20] of string[40];
             {20 lines of 40 length in a page}
    Hlp_book_page=record
    Page_Name:string[30];
    Topic_no,
    Page_no:word;
    Help_Page:hlp_page;
             end;

     MAXX=0..501;

     PLOTTYPE = RECORD
     Y:ARRAY[MAXX] OF REAL;
     ERR:ARRAY[MAXX] OF BOOLEAN;
     END;

     PUTMODE=word;{=(PAND,POR,PXOR,PREP)}

     charset=set of char;

     BUTNCOUNT=1..MAXBUTNS;

     BUTNS=RECORD
     BTN  :ARRAY[BUTNCOUNT] OF BUTN;
     INUSE:BUTNCOUNT;
     END;

     FONT=ARRAY[0..255,0..7] OF byte;

{CHARS ARE 8*8, SO ROWS=Y/8 & COLS=X/8}
(**************************************************************************)
VAR BUTCONT: BUTNCOUNT;
    SMAL: FONT;
    Help_Book:File of Hlp_book_page;
    SMALF: FILE OF FONT;
    FUNC:EXPSTR;
    STORE:FUNCFILE;
    SAVFNC:FILE OF FUNCFILE;
    XR1,YR1,XR2,YR2:REAL;{SET A DEFAULT RANGE}
    RX1,RY1,RX2,RY2:INTEGER;{ZOOM}
    XSCALE,YSCALE:REAL;
    I : INTEGER;
    PL:PLOTTYPE;
    GRFBTN,
    WORDS:BUTN;
    ONBTN:BYTE;
    FLAG,ER,ERP,EXPERR:BOOLEAN;{USE ERP INSTEAD OF EXPERR}
    {SET AUTO SCALING ,CALCULATE BY RANGE}
(**************************************************************************)
FUNCTION INBTN(BUTS:BUTN;X,Y:INTEGER):BOOLEAN;
BEGIN
WITH BUTS DO
INBTN:=(X>=X1) AND (Y>=Y1) AND (X<=X2) AND (Y<=Y2);
END;
(**************************************************************************)
PROCEDURE SETPIXL16(X,Y:INTEGER;CLR:BYTE;BUTS:BUTN;MODE:PUTMODE);
BEGIN
IF INBTN(BUTS,X,Y) THEN PUTPIXEL16(X,Y,CLR,MODE);
END;
(**************************************************************************)
PROCEDURE COUT(S:CHAR;X,Y:INTEGER;BUTS:BUTN;MODE:PUTMODE;MASK:BOOLEAN);
VAR B,C,D:BYTE; E:WORD;
BEGIN
B:=ORD(S);
FOR C:=0 TO 7 DO BEGIN
E:=SMAL[B,C];
FOR D:=0 TO 7 DO BEGIN
{error in buttons is that outline of button strikes upper text line}
IF (E AND 128)=128 THEN SETPIXL16(X+D,Y+C,BUTS.FORCOL,BUTS,MODE) ELSE
IF MASK THEN SETPIXL16(X+D,Y+C,BUTS.BKCOL,BUTS,MODE);
E:=E SHL 1;
{ADD VERTICAL,DOWN OR ANGLED WRITE MODES IN FUTURE}
END;{FOR D}
END;{FOR C}
END;
(**************************************************************************)
procedure box(X1,Y1,X2,Y2:integer;CLR:BYTE;attr:PUTMODE);
var x,y:integer;
begin
if y1>y2 then
BEGIN
Y:=Y1;Y1:=Y2;Y2:=Y;
END;
if x1>x2 then
BEGIN
X:=X1;X1:=X2;X2:=X;
END;

for x:=x1 to x2 do
begin
PUTPIXEL16(x,y1,CLR,attr);
PUTPIXEL16(x,y2,CLR,attr);
end;

for y:=(y1+1) to (y2-1) do
begin
PUTPIXEL16(x1,y,CLR,attr);
PUTPIXEL16(x,y,CLR,attr);
end;
end;{PROC}
(**************************************************************************)
procedure fildBox(X1,Y1,X2,Y2:integer;CLR:BYTE);
var x,y:integer;
begin
if y1>y2 then
BEGIN
Y:=Y1;Y1:=Y2;Y2:=Y;
END;
if x1>x2 then
BEGIN
X:=X1;X1:=X2;X2:=X;
END;
for y:=y1 to y2 do
for x:=x1 to x2 do PUTPIXEL16(x,y,CLR,PREP);
end;
(**************************************************************************)
PROCEDURE GWRITE(BUTS:BUTN;MODE:PUTMODE;MASK:BOOLEAN);
VAR L,N:BYTE;
    s  :string;
    X,Y:INTEGER;
BEGIN
HIDE_MOUSE;
s:=buts.name;{string to be printed}
L:=LENGTH(S);
X:=BUTS.X1;
Y:=BUTS.Y1;
FOR N:=1 TO L DO BEGIN
COUT(S[N],X,Y,BUTS,MODE,MASK);
X:=X+8;
IF X>BUTS.X2-8 THEN BEGIN X:=BUTS.X1; Y:=Y+8;END;
END;
SHOW_MOUSE;
END;
(**************************************************************************)
procedure GREAD(var BUTS:BUTN;UP:BOOLEAN;ch:charset;MASK:BOOLEAN);
{HERE WE USE BUTTONS FOR WINDOWS}
VAR S:STRING;
    X,Y:INTEGER;
    C:CHAR;
BEGIN   {MODE IS ALWAYS PXOR}
HIDE_MOUSE;
S[0]:=#0; {MASK SHOULD BE TRUE}
X:=BUTS.X1; {A BOX SHOULD BE DEFINED TO SHOW READ AREA}
Y:=BUTS.Y1;
REPEAT
IF UP THEN C:=UPCASE(READKEY) ELSE C:=READKEY;
IF ((C<>#13) AND (C<>#27) AND (C<>#8) and (c in ch)) THEN
BEGIN
S:=S+C;
COUT(C,X,Y,BUTS,PXOR,MASK);
X:=X+8;
END;
IF (C=#8) AND (LENGTH(S)>0) THEN
BEGIN
X:=X-8;
COUT(S[LENGTH(S)],X,Y,BUTS,PXOR,MASK);
DEC(S[0]);
END;

UNTIL ( (C=#13) OR (X>BUTS.X2-10) OR (C=#27) );
buts.name:=S;
GWRITE(BUTS,PXOR,MASK);
{experimental step might be deleted}
if c=#27 then s[0]:=#0;
buts.name:=s;
{exp ends}
SHOW_MOUSE;
END;{PROC}
(**************************************************************************)
PROCEDURE PUTBUTNS(BUTS:BUTNS);
var b:byte;
BEGIN
with buts do
     for b:=1 to inuse do begin
         with btn[b] do begin
         fildbox(x1-3,y1-3,x2+3,y2+3,rmargin);
         fildbox(x1,y1,x2,y2,bkcol);
         gwrite(btn[b],prep,TRUE);
         end;
     end;

END;{PROC}
(**************************************************************************)
(*
PROCEDURE DIM_BTN(BUTS:BUTN;BT,DIMCOL:BYTE);
VAR CTDN:BYTE;
BEGIN
WITH BUTS DO
IF ((BT<=BUTS.INUSE) AND (BT>0)) THEN
BEGIN
{ADD GLOWCOL FOR MARGINS NOW & LATER TEXT}
WITH BTN[BT] DO BEGIN
{SHOW BTN PRESSED}
FOR CTDN:=1 TO 3 DO
BOX(X1-CTDN,Y1-CTDN,X2+CTDN,Y2+CTDN,DIMCOL,PREP);
                                    {GLOW MARGIN COLOR}
END;{WITH BTN}
END;{WITH BUTN}
END;
*)
(**************************************************************************)
PROCEDURE GLOW_BTN(BUTS:BUTNS;BT,GLOW_COL:BYTE);
VAR CTDN:BYTE;
BEGIN
{HIDE MOUSE}
WITH BUTS DO
IF ((BT<=BUTS.INUSE) AND (BT>0)) THEN
BEGIN
{ADD GLOWCOL FOR MARGINS NOW & LATER TEXT}
WITH BTN[BT] DO BEGIN
{SHOW BTN PRESSED}
FOR CTDN:=1 TO 3 DO
BOX(X1-CTDN,Y1-CTDN,X2+CTDN,Y2+CTDN,GLOW_COL,PREP);
                                    {GLOW MARGIN COLOR}
END;{WITH BTN}
END;{WITH BUTN}
{SHOW MOUSE}
END;
(**************************************************************************)
FUNCTION MOUSE_ON_BTN(BUTS:BUTNS):BYTE;
VAR BTP,NUM:BYTE;
    MX,MY:INTEGER;

BEGIN
BTP:=0;
GETMOUSEXY(MX,MY);
WITH BUTS DO  BEGIN
FOR NUM:=1 TO INUSE DO
IF INBTN(BTN[NUM],MX,MY) THEN BTP:=NUM;
END;{WITH}
MOUSE_ON_BTN:=BTP;
END;
(**************************************************************************)
Procedure active_btns_left(buttn:butns);
BEGIN
flag:=false;(**)
ONBTN:=MOUSE_ON_BTN(BUTTN);
IF ONBTN<>0 THEN
BEGIN
FLAG:=TRUE;
HIDE_MOUSE;
GLOW_BTN(BUTTN,ONBTN,BUTTN.BTN[ONBTN].GCOL);
SHOW_MOUSE;
repeat
until (isleftdown or (mouse_on_btn(buttn)=0));
END;
IF FLAG THEN BEGIN
FLAG:=FALSE;
HIDE_MOUSE;
GLOW_BTN(BUTTN,ONBTN,BUTTN.BTN[ONBTN].DCOL);
SHOW_MOUSE;
END;
end;
(**************************************************************************)
{IF MOUSE CLICKED THEN DETECT BUTTON ,ALSO SHOW PRESS & RELEASE}
(**************************************************************************)
FUNCTION BUTNPRESSED(BUTS:BUTNS):BYTE;
VAR BTP,CTDN:BYTE;

BEGIN
{RELEASE WHEN LEFT IS NOT DOWN..JUST COLOUR THE MARGINS BLACK OR WHITE}
BTP:=MOUSE_ON_BTN(BUTS);
{
GETMOUSEXY(MX,MY);
WITH BUTS DO  BEGIN
FOR NUM:=1 TO INUSE DO
IF INBTN(BTN[NUM],MX,MY) THEN BTP:=NUM;
}
WITH BUTS DO  BEGIN

IF (BTP>0) { NOT(BTN[BTP].SCROLL)}
THEN
IF NOT(BTN[BTP].SCROLL) THEN
BEGIN

HIDE_MOUSE;
(*
WITH BTN[BTP] DO BEGIN
{SHOW BTN PRESSED}
FOR CTDN:=1 TO 3 DO
BOX(X1-CTDN,Y1-CTDN,X2+CTDN,Y2+CTDN,PMARGIN,PREP);
                                    {PRESSED MARGIN COLOR}
*)
GLOW_BTN(BUTS,BTP,BTN[BTP].PMARGIN);
REPEAT
UNTIL NOT(ISLEFTDOWN);
{SHOW BTN RELEASED}
(*IF SCROLL THEN DELAY(1);{REMOVE THIS IF DELAY FOR PLOT IS MUCH}*)

(*FOR CTDN:=3 DOWNTO 1 DO
BOX(X1-CTDN,Y1-CTDN,X2+CTDN,Y2+CTDN,RMARGIN,PREP);
                                    {RELEALSE MARGIN COLOR}
END{WITH BTN};
*)
GLOW_BTN(BUTS,BTP,BTN[BTP].RMARGIN);
SHOW_MOUSE;
END;{IF BTP}
END;{WITH BUTS}
BUTNPRESSED:=BTP;
END;
(**************************************************************************)
procedure AXES;
BEGIN
BOX(0,0,502,402,AXIS,PREP);
BOX(0,0,251,402,AXIS,PREP);
BOX(0,0,502,201,AXIS,PREP)
END;
(**************************************************************************)
PROCEDURE CLEAN;
VAR X,Y:INTEGER;
BEGIN
FILDBOX(1,1,501,401,0);
AXES;
FOR X:=0 TO 50 DO
FOR Y:=199 TO 203 DO PUTPIXEL16(X*10+1,Y,14,PREP);
FOR Y:=0 TO 40 DO
FOR X:=250 TO 252 DO PUTPIXEL16(X,Y*10+1,14,PREP);
END;
(**************************************************************************)
PROCEDURE SHEET;
VAR X:INTEGER;
BEGIN
FOR X:=0 TO 50 DO BOX(0,0,1+X*10,401,LIN,PREP);
FOR X:=0 TO 40 DO BOX(0,0,501,1+X*10,LIN,PREP);
AXES;
END;
(**************************************************************************)
PROCEDURE SHOWSCALE;
VAR STRNG:STRING;
BEGIN
WITH WORDS DO BEGIN
   X1:=0;X2:=639;
   Y1:=430;Y2:=440;
   FORCOL:=15;
   BKCOL:=0;
   NAME:=FUNC;
   GWRITE(WORDS,PREP,TRUE);

X1:=515;X2:=616;
STR(YR1:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=105;Y2:=115;
GWRITE(WORDS,PREP,TRUE);
STR(XR1:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=75;Y2:=85;
GWRITE(WORDS,PREP,TRUE);
STR(YR2:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=165;Y2:=175;
GWRITE(WORDS,PREP,TRUE);
STR(XR2:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=135;Y2:=145;
GWRITE(WORDS,PREP,TRUE);
(*SCALE STARTS*)
X1:=505;X2:=639;
STR(XSCALE:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
Y1:=230;Y2:=240;
GWRITE(WORDS,PREP,TRUE);
STR(YSCALE:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
Y1:=260;Y2:=270;
GWRITE(WORDS,PREP,TRUE);
END;
END;
(**************************************************************************)
PROCEDURE POINT(X,Y:INTEGER;CLR:BYTE);{PIXEL ON GRAPH}
BEGIN
IF INBTN(GRFBTN,X,401-Y) THEN
PUTPIXEL16(X,401-Y,CLR,PXOR);
END;
(**************************************************************************)
PROCEDURE PUTPIXLS;
VAR XCOUNT,RESULT:REAL;XC:INTEGER;
BEGIN
IF NOT(EXPERR) AND (YSCALE<>0) THEN BEGIN
HIDE_MOUSE;
{PLOTTING}
XCOUNT:=1;
WHILE (XCOUNT<502) DO BEGIN
XC:=ROUND(XCOUNT);
RESULT:=PL.Y[XC];
IF (PL.ERR[XC] AND (RESULT<=YR2) AND (RESULT>=YR1))
THEN
POINT(XC,ROUND((RESULT-YR1)/YSCALE),15);
XCOUNT:=XCOUNT+1;
END;{WHILE}
SHOW_MOUSE;
END;{IF EXEPRR}
END;
(**************************************************************************)
PROCEDURE PLOT(AUTO:BOOLEAN);
VAR F,INF,INF_REC:BOOLEAN;
    RESULT,XCOUNT:REAL;
    XC:INTEGER;
BEGIN
XSCALE:=(XR2-XR1)/500;{501-1}
XCOUNT:=1;{GRFBTN.X1}
{what is F for???}
F:=TRUE; {X^2 - GRAPH INCORRECT, NOT PLOTTING THE NEG PART}
EXPERR:=FALSE;
INF_REC:=FALSE;
WHILE (XCOUNT<502{GRFBTN.X2}) AND NOT(EXPERR) DO
BEGIN             {<501 PREVIOUSLY}
XC:=ROUND(XCOUNT);
EVALUATE(FUNC,XR1+(XCOUNT-1)*XSCALE,RESULT,EXPERR,INF);
PL.Y[XC]:=RESULT;
PL.ERR[XC]:=NOT(INF);{inf= infinity error,true if err occurs}
                     {pl.err[xc]:=not(inf) means putpixl:=true}
IF INF THEN INF_REC:=TRUE;
IF AUTO AND NOT(INF) THEN
BEGIN
IF F THEN BEGIN
F:=FALSE;
YR1:=PL.Y[XC];
YR2:=YR1;
END ELSE
IF PL.Y[XC]>YR2 THEN YR2:=PL.Y[XC]
ELSE
IF PL.Y[XC]<YR1 THEN YR1:=PL.Y[XC];
END;{ IF AUTO}
XCOUNT:=XCOUNT + 1;
END;{WHILE}
YSCALE:=(YR2-YR1)/400;{401-1}{if yr1>yr2 then swap values..similar for x}
PUTPIXLS;
SHOWSCALE;
WITH WORDS DO BEGIN
IF EXPERR THEN NAME:='ERROR IN EXPRESSION.'
ELSE IF INF_REC THEN
               NAME:='INFINITY EVALUATED..'
               {i.e infinity(out of range evaluation) discarded..}
               {out of range eval. means Big-Number or Uncalculatable value}
         else  NAME:=' Done....           ';
FORCOL:=10;
BKCOL:=1;
X1:=4;X2:=204;
Y1:=460;Y2:=470;{THIS CAN BE SHARED}
END;{WITH}
GWRITE(WORDS,PREP,TRUE);
END;
(**************************************************************************)
procedure getbox(var x1,y1,x2,y2:INTEGER);
{purpose to get x1,y1,x2,y2 co-ordinates using mouse xor to restore before leaving}
{for saving screen for mrk undo,or ellipse,or rectangle ect.}
{setpixl converts the co-ordinates nothing else required}
var X,Y,xnew,ynew:INTEGER;
begin
repeat
GETMOUSEXY(X,Y);
until (ISLEFTDOWN) AND INBTN(GRFBTN,X,Y);
HIDE_MOUSE;
X1:=X;Y1:=Y;
X2:=X;Y2:=Y;
while isleftdown do
REPEAT
{box(x1,y1,X2,Y2,pxor);}
XNEW:=X2;YNEW:=Y2;
repeat
getmousexy(X2,Y2);
until (((x2<>XNEW) AND (y2<>YNEW))
      OR NOT(ISLEFTDOWN))
      AND INBTN(GRFBTN,X2,Y2);
box(x1,y1,XNEW,YNEW,4,pxor);
box(x1,y1,x2,y2,4,pxor);
UNTIL ((X2<>X1) AND (Y2<>Y1)) AND NOT(ISLEFTDOWN);
box(x1,y1,X2,Y2,4,pxor);
if x1>x2 then BEGIN
X:=X1;
X1:=X2;
X2:=X;
END;
if y1>y2 then BEGIN
Y:=Y1;
Y1:=Y2;
Y2:=Y;
END;
SHOW_MOUSE;
end;
(**************************************************************************)
PROCEDURE ZOOM(PLUS:BOOLEAN);
var xr,yr:real;
BEGIN
PUTPIXLS;
XR:=50*XSCALE; {SET X ZOOM RATE & Y ZOOM RATE BY BUTTONS}
YR:=40*YSCALE;
   IF PLUS THEN
      IF ((YR2-YR)>(YR1+YR)) AND ((XR2-XR)>(XR1+XR)) THEN
      BEGIN
      YR2:=YR2-YR;
      YR1:=YR1+YR;
      XR1:=XR1+XR;
      XR2:=XR2-XR;
      END;

   IF NOT(PLUS) THEN
      IF (YR2+YR<9999999999.0) AND (XR2+XR<9999999999.0)
      AND (YR1-YR>-999999999.0) AND (XR1-XR>-999999999.0)
      THEN BEGIN
      YR2:=YR2+YR;
      YR1:=YR1-YR;
      XR1:=XR1-XR;
      XR2:=XR2+XR;
      END;
PLOT(FALSE);
END;
(**************************************************************************)
PROCEDURE PGUP(UP,FAST:BOOLEAN);{PARAM FAST TO BE THERE}
VAR Y:REAL;
    STRNG:STRING;
BEGIN
Y:=YR2-YR1;
IF Y>=0 THEN BEGIN
PUTPIXLS;
   IF UP THEN
      IF ((YR2+Y)<9999999999.0) THEN
      BEGIN
      YR1:=YR1+Y; YR2:=YR2+Y;
      END;
   IF NOT(UP) THEN
      IF (YR1>(-999999999.0+Y)) THEN
      BEGIN
      YR1:=YR1-Y; YR2:=YR2-Y;
      END;

PUTPIXLS;
IF NOT FAST THEN
WITH WORDS DO BEGIN
FORCOL:=15;
BKCOL:=0;
X1:=515;X2:=616;
STR(YR1:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=105;Y2:=115;
GWRITE(WORDS,PREP,TRUE);

STR(YR2:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=165;Y2:=175;
GWRITE(WORDS,PREP,TRUE);

END;{WITH}
END; {IF Y}
END;
(**************************************************************************)
PROCEDURE PGLFT(LFT:BOOLEAN);
VAR X:REAL;
BEGIN
X:=XR2-XR1;
IF X>=0 THEN BEGIN
PUTPIXLS;
   IF LFT THEN
      IF ((XR1-X)>-999999999.0) THEN
      BEGIN
      XR1:=XR1-X; XR2:=XR2-X;
      END;
   IF NOT(LFT) THEN
      IF (XR2<(9999999999.0-X)) THEN
      BEGIN
      XR1:=XR1+X; XR2:=XR2+X;
      END;
PLOT(FALSE);
END;{IF}
END; {PROC}
(**************************************************************************)
PROCEDURE UPSCRL(UP,FAST:BOOLEAN);
VAR STRNG:STRING;
    Y:REAL;
BEGIN
Y:=YR2-YR1;
IF Y>=0 THEN BEGIN
{SCROLLING IS LOCKED AT EXTREME RANGE}
PUTPIXLS;
IF (NOT(UP) AND (YR1>(-999999999.0+YSCALE))) THEN
BEGIN
YR1:=YR1-YSCALE;
YR2:=YR2-YSCALE;
END;
IF (UP AND (YR2<(9999999999.0-YSCALE))) THEN
BEGIN
YR1:=YR1+YSCALE;
YR2:=YR2+YSCALE;
END;
PUTPIXLS;
IF NOT FAST THEN
WITH WORDS DO BEGIN
FORCOL:=15;
BKCOL:=0;
X1:=515;X2:=616;
STR(YR1:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=105;Y2:=115;
GWRITE(WORDS,PREP,TRUE);

STR(YR2:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=165;Y2:=175;
GWRITE(WORDS,PREP,TRUE);

END;{WITH}
END;{IF}
END;
(**************************************************************************)
PROCEDURE SCROL(LFT,FAST:BOOLEAN);{GET PARAM FAST:BOOLEAN}
VAR X:INTEGER;
    B:BOOLEAN;
    STRNG:STRING;
BEGIN
(*SHOW ONLY CHANGING XR1 & XR2*)
PUTPIXLS;
IF LFT AND (XR1>(-999999999.0+XSCALE)) THEN
   BEGIN

   FOR X:=500 DOWNTO 1 DO
   BEGIN
   PL.Y[X+1]:=PL.Y[X];
   PL.ERR[X+1]:=PL.ERR[X];
   END;
         XR1:=XR1-XSCALE;
         XR2:=XR2-XSCALE;
         EVALUATE(FUNC,XR1,PL.Y[1],EXPERR,B);
         PL.ERR[1]:=NOT(B);
   END;
IF NOT(LFT) AND (XR2<(9999999999.0-XSCALE)) THEN
   BEGIN
   FOR X:=1 TO 500 DO
   BEGIN
   PL.Y[X]:=PL.Y[X+1];{SET VALUE SCROLL}
   PL.ERR[X]:=PL.ERR[X+1];
   END;
    XR1:=XR1+XSCALE;
    XR2:=XR2+XSCALE;
    EVALUATE(FUNC,XR2,PL.Y[501],EXPERR,B);
         PL.ERR[501]:=NOT(B);
    END;{IF}
PUTPIXLS;
{MAKE A BTN FAST SCROLL FOR WHICH IF TOGGLE THEN DON'T
SHOW INSTANTANIOUS CHANGE}
IF NOT FAST THEN
WITH WORDS DO BEGIN
FORCOL:=15;
BKCOL:=0;
X1:=515;X2:=616;
STR(XR1:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=75;Y2:=83;
GWRITE(WORDS,PREP,TRUE);
STR(XR2:10:8,STRNG);
STRNG[0]:=#10;
NAME:=STRNG;
   Y1:=135;Y2:=143;
GWRITE(WORDS,PREP,TRUE);
END;{WITH}
{SHOW NEW XR1 &XR2}
END;
(**************************************************************************)
PROCEDURE SAVE;
VAR FINE:BOOLEAN;
BEGIN
WITH STORE DO BEGIN
XMIN:=XR1; YMIN:=YR1;
XMAX:=XR2; YMAX:=YR2;
NAME:=FUNC;
END;
WITH WORDS DO
BEGIN
X1:=0;Y1:=444;X2:=639;Y2:=452;
FORCOL:=10;
BKCOL:=4;
END;
GREAD(WORDS,FALSE,[#0..#31,#33..#255],TRUE);
if words.name[0]<>#0 then begin
ASSIGN(SAVFNC,WORDS.NAME);
{$I-}
REWRITE(SAVFNC);{NO ERROR DETECTED ON INCORRECT TYPE OF NAME}
{$I+}
FINE:=IORESULT=0;
WITH WORDS DO BEGIN
IF NOT(FINE) THEN NAME:='ERROR IN SAVING....'
   ELSE BEGIN     WRITE(SAVFNC,STORE);
                  CLOSE(SAVFNC);
                  NAME:='SAVED...           ';
                  END;
FORCOL:=10;
BKCOL:=1;
X1:=4;X2:=204;
Y1:=460;Y2:=468;{THIS CAN BE SHARED}
END;{WITH}
GWRITE(WORDS,PREP,TRUE);
end;{if words.name[0]<>#0}
END;
(**************************************************************************)
PROCEDURE LOAD;
VAR FINE:BOOLEAN;
BEGIN
WITH WORDS DO
BEGIN
X1:=0;Y1:=444;X2:=639;Y2:=452;
FORCOL:=10;
BKCOL:=4;
END;
GREAD(WORDS,FALSE,[#0..#31,#33..#255],TRUE);
if words.name[0]<>#0 then begin
ASSIGN(SAVFNC,WORDS.NAME);
{$I-}
RESET(SAVFNC);
{$I+}
FINE:=IORESULT=0;
WITH WORDS DO BEGIN
IF NOT(FINE) THEN NAME:='ERROR IN LOADING....'
   ELSE
   BEGIN
   NAME:='LOADED...           ';
   READ(SAVFNC,STORE);
   CLOSE(SAVFNC);
WITH STORE DO BEGIN
XR1:=XMIN; YR1:=YMIN;
XR2:=XMAX; YR2:=YMAX;
END;
FUNC:=STORE.NAME;
END;{IF FINE}

FORCOL:=10;
BKCOL:=1;
X1:=4;X2:=204;
Y1:=460;Y2:=468;{THIS CAN BE SHARED}
END;{WITH}
GWRITE(WORDS,PREP,TRUE);
end;{if words.name[0]<>#0}
END;
(**************************************************************************)
PROCEDURE MENU;
VAR BUTTN:BUTNS;
    PRES:BYTE;
BEGIN
(**********************************************)
WITH BUTTN DO
     BEGIN

     INUSE:=23;

     WITH BTN[1] DO BEGIN
     NAME:='NEW-FUNCTION [F(X)]';
     SCROLL:=FALSE;
     X1:=4; Y1:=415;
     X2:=156; Y2:=423;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     {PRESSED MARGIN COLOUR}
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     {RELEASED MARGIN COLOUR}
     END;{BTN[1]}

     WITH BTN[2] DO BEGIN
     NAME:=' PRINT ';{OR DOS SHELL}
     SCROLL:=FALSE;
     X1:=513; Y1:=180;{ASM INT-5H; PRINT SCREEN-INTERRUPT}
     X2:=569; Y2:=188;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[2]}

     WITH BTN[3] DO BEGIN
     NAME:='X-RANGE(MAX)';
     SCROLL:=FALSE;
     X1:=513; Y1:=120;
     X2:=609; Y2:=128;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[3]}

     WITH BTN[4] DO BEGIN
     NAME:='Y-RANGE(MAX)';
     SCROLL:=FALSE;
     X1:=513; Y1:=150;
     X2:=609; Y2:=158;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[4]}

     WITH BTN[5] DO BEGIN
     NAME:='X-RANGE(MIN)';{1..501=COUNTSCALE} {501 * 401 GRAPH RES}
     SCROLL:=FALSE;
     X1:=513; Y1:=60;
     X2:=609; Y2:=68;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[5]}

     WITH BTN[6] DO BEGIN
     NAME:='Y-RANGE(MIN)'; {1..401}
     SCROLL:=FALSE;
     X1:=513; Y1:=90;
     X2:=609; Y2:=98;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[6]}

     WITH BTN[7] DO BEGIN
     NAME:='*   PLOT   *';
     SCROLL:=FALSE;
     X1:=513; Y1:=20;
     X2:=609; Y2:=28;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[7]}

     WITH BTN[8] DO BEGIN
     NAME:=' AUTO-RANGE ';
     SCROLL:=FALSE;
     X1:=513; Y1:=40;
     X2:=609; Y2:=48;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[8]}

     WITH BTN[9] DO BEGIN
     NAME:=' EXIT ';
     SCROLL:=FALSE;
     X1:=515; Y1:=390;
     X2:=563; Y2:=398;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[9]}

     WITH BTN[10] DO BEGIN
     NAME:=' CLEAN ';
     SCROLL:=FALSE;
     X1:=534; Y1:=350;
     X2:=590; Y2:=358;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[10]}

     WITH BTN[11] DO BEGIN
     NAME:='  MATHKIT  ';
     SCROLL:=FALSE;
     X1:=510; Y1:=290;
     X2:=598; Y2:=298;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[11]}

     WITH BTN[12] DO BEGIN
     NAME:='GRAPH-SHEET (1 BLOCK:=10 POINTS)';
     SCROLL:=FALSE;
     X1:=300; Y1:=415;
     X2:=556; Y2:=423;
     FORCOL:=14;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[12]}

     WITH BTN[13] DO BEGIN
     NAME:=' SAVE ';
     SCROLL:=FALSE;
     X1:=539; Y1:=330;
     X2:=587; Y2:=338;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[13]}

     WITH BTN[14] DO BEGIN
     NAME:=' LOAD ';
     SCROLL:=FALSE;
     X1:=539; Y1:=310;
     X2:=587; Y2:=318;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[14]}

     WITH BTN[15] DO BEGIN
     NAME:='<-';
     SCROLL:=TRUE;
     X1:=380; Y1:=465;
     X2:=396; Y2:=473;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[15]}

     WITH BTN[16] DO BEGIN
     NAME:='->';
     SCROLL:=TRUE;
     X1:=420; Y1:=465;
     X2:=436; Y2:=473;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[16]}

     WITH BTN[17] DO BEGIN
     NAME:='UP';
     SCROLL:=TRUE;
     X1:=460; Y1:=465;
     X2:=476; Y2:=473;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[17]}

     WITH BTN[18] DO BEGIN
     NAME:='DN';
     SCROLL:=TRUE;
     X1:=490; Y1:=465;
     X2:=506; Y2:=473;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[18]}

     WITH BTN[19] DO BEGIN
     NAME:='SCRL SPEED';
     SCROLL:=FALSE;
     X1:=530; Y1:=465;
     X2:=610; Y2:=473;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[19]}

     WITH BTN[20] DO BEGIN
     NAME:='PG';
     SCROLL:=FALSE;
     X1:=305; Y1:=465;
     X2:=321; Y2:=473;
     FORCOL:=4;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[20]}

     WITH BTN[21] DO BEGIN
     NAME:='+';
     SCROLL:=TRUE;
     X1:=234; Y1:=415;
     X2:=242; Y2:=423;
     FORCOL:=14;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[21]}

     WITH BTN[22] DO BEGIN
     NAME:='-';
     SCROLL:=TRUE;
     X1:=254; Y1:=415;
     X2:=262; Y2:=423;
     FORCOL:=14;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[22]}

     WITH BTN[23] DO BEGIN
     NAME:='ZOOM IN';
     SCROLL:=FALSE;
     X1:=535; Y1:=370;
     X2:=591; Y2:=378;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[23]}
     END;{BUTTN}

(**********************************************)
{WRITE ALL DEFUALT VALUES}
{DEFAULT RANGE SET}
XR1:=-250;YR1:=-200;
XR2:=250;YR2:=200;{2>1 ALWAYS}
FUNC:='X';
XSCALE:=1;
YSCALE:=1;
{MAKE proc set_scale}
WITH WORDS DO BEGIN
FORCOL:=15;
BKCOL:=0;
X1:=505;X2:=639;
NAME:=' SCALE ';
Y1:=200;Y2:=210;
GWRITE(WORDS,PREP,TRUE);
NAME:='X (1 IS TO):';
Y1:=215;Y2:=225;
GWRITE(WORDS,PREP,TRUE);
NAME:='Y (1 IS TO):';
Y1:=245;Y2:=255;
GWRITE(WORDS,PREP,TRUE);
NAME:='0:(MAX+MIN)/2';
X1:=505;X2:=639;
Y1:=270;Y2:=280;
FORCOL:=11;
BKCOL:=9;
GWRITE(WORDS,PREP,TRUE);
END;
(**********************************************)
{PUT BUTTONS}
PUTBUTNS(BUTTN);
SHOWSCALE;
SHOW_MOUSE;
(**********************************************)
{WAIT FOR BUTN PRESS}
PRES:=0;
REPEAT
IF (PRES>14) AND (PRES<19) AND NOT (ISLEFTDOWN) AND BUTTN.BTN[19].TOGGLE
   AND  NOT(BUTTN.BTN[20].TOGGLE AND (PRES>14) AND (PRES<17))
THEN SHOWSCALE;
IF IsLeftDown THEN PRES:=BUTNPRESSED(BUTTN) ELSE
begin
active_btns_left(buttn);
PRES:=0;
END;

{PUT RIGHT CLICK FOR INSTANT HELP, ADD HELP FEATURE}
CASE PRES OF

0:;{LEAVE}

1: BEGIN
(* message*)
   WITH WORDS DO BEGIN
   NAME:='Enter the Function..';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   WITH WORDS DO
   BEGIN
   X1:=0;X2:=639;
   Y1:=430;Y2:=440;
   FORCOL:=15;
   BKCOL:=0;
   END;
WORDS.NAME:='                                                                               ';
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,TRUE,[#0..#255],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   FUNC:=WORDS.NAME;
   END;

2: BEGIN
(* message*)
   WITH WORDS DO BEGIN
   NAME:='Printing the Graph..';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   HIDE_MOUSE;
   {$I-}
   ASM
   INT 5H;
   END;
   {$I+}
(* message*)
   WITH WORDS DO BEGIN
   NAME:=' Printing sent...   ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   SHOW_MOUSE;
   END;

3: REPEAT
(* message*)
   WITH WORDS DO BEGIN
   NAME:='Enter a Number..    ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   WITH WORDS DO
   BEGIN
   X1:=515;X2:=615;
   Y1:=135;Y2:=145;
   FORCOL:=15;
   BKCOL:=0;
   END;
   WORDS.NAME:='          ';
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   EVALUATE(WORDS.NAME,0,XR2,ERP,ER);{1e4 is valid}
   if not(erp) then begin
   WITH WORDS DO BEGIN
   NAME:='X-Max Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);
   end;
   UNTIL ((XR2>XR1) AND NOT(ERP) AND (XR2>-999999999));
         {set y-scale is not ok for func may give in range values for small X}
         {until xr2>xr1+500*xscale}
4: REPEAT
(* message*)
   WITH WORDS DO BEGIN
   NAME:='Enter a Number..    ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   WITH WORDS DO
   BEGIN
   X1:=515;X2:=615;
   Y1:=165;Y2:=175;
   FORCOL:=15;
   BKCOL:=0;
   END;
   WORDS.NAME:='          ';
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   EVALUATE(WORDS.NAME,0,YR2,ERP,ER);
   if not(erp) then begin
   WITH WORDS DO BEGIN
   NAME:='Y-Max Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);
   end;
   UNTIL ((YR2>YR1) AND NOT(ERP) AND (YR2>-999999999));

5: REPEAT
   WITH WORDS DO BEGIN
   NAME:='Enter a Number..    ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   WITH WORDS DO
   BEGIN
   X1:=515;X2:=615;
   Y1:=75;Y2:=85;
   FORCOL:=15;
   BKCOL:=0;
   END;
   WORDS.NAME:='          ';
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   EVALUATE(WORDS.NAME,0,XR1,ERP,ER);
   if not(erp) then begin
   WITH WORDS DO BEGIN
   NAME:='X-Min Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);
   end;
   UNTIL (XR1<XR2) AND NOT(ERP) AND (XR1<9999999999.0);

6: REPEAT
   WITH WORDS DO BEGIN
   NAME:='Enter a Number..    ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   WITH WORDS DO
   BEGIN
   X1:=515;X2:=615;
   Y1:=105;Y2:=115;
   FORCOL:=15;
   BKCOL:=0;
   END;
   WORDS.NAME:='          ';
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   EVALUATE(WORDS.NAME,0,YR1,ERP,ER);
   if not(erp) then begin
   WITH WORDS DO BEGIN
   NAME:='Y-Min Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);
   end;
   UNTIL (YR1<YR2) AND NOT(ERP) AND (YR1<9999999999.0);

7: PLOT(FALSE);

8: PLOT(TRUE);

9: {EXIT} ;

10: WITH BUTTN DO
    BEGIN
    HIDE_MOUSE;
    CLEAN;
    IF BTN[12].TOGGLE THEN SHEET;
    SHOW_MOUSE;
    END;

11:;

12: WITH BUTTN DO
    BEGIN
    HIDE_MOUSE;
    CLEAN;
    BTN[12].TOGGLE:=NOT(BTN[12].TOGGLE);
    IF BTN[12].TOGGLE THEN SHEET;
    SHOW_MOUSE;
    END;

13: Begin
    WITH WORDS DO BEGIN
    NAME:='Enter File Name... ';{20=length}
    FORCOL:=10;
    BKCOL:=1;
    X1:=4;X2:=204;
    Y1:=460;Y2:=470;{THIS CAN BE SHARED}
    END;{WITH}
    GWRITE(WORDS,PREP,TRUE);

    SAVE ;{IF SAVE THEN BUTTN.BTN[13].TOGGLE:=TRUE;}
    End;

14: {IF NOT(BUTTN.BTN[13].TOGGLE) THEN ASK;{SURE(Y/N)}
   BEGIN
   WITH WORDS DO BEGIN
   NAME:='Enter File Name... ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

    LOAD ;
    SHOWSCALE;
    END;

15: IF BUTTN.BTN[20].TOGGLE THEN PGLFT(TRUE)
       ELSE
       SCROL(TRUE,BUTTN.BTN[19].TOGGLE);

16: IF BUTTN.BTN[20].TOGGLE THEN PGLFT(FALSE)
       ELSE
       SCROL(FALSE,BUTTN.BTN[19].TOGGLE);

17: IF BUTTN.BTN[20].TOGGLE THEN PGUP(TRUE,BUTTN.BTN[19].TOGGLE)
       ELSE
       UPSCRL(TRUE,BUTTN.BTN[19].TOGGLE);

18: IF BUTTN.BTN[20].TOGGLE THEN PGUP(FALSE,BUTTN.BTN[19].TOGGLE)
       ELSE
       UPSCRL(FALSE,BUTTN.BTN[19].TOGGLE);

19:BEGIN
   BUTTN.BTN[19].TOGGLE:=NOT(BUTTN.BTN[19].TOGGLE);
   WITH WORDS DO
   BEGIN
   IF BUTTN.BTN[19].TOGGLE THEN NAME:='HIGH' ELSE NAME:='LOW.';
   X1:=335;Y1:=465;
   X2:=375;Y2:=475;
   FORCOL:=0;
   BKCOL:=15;
   END;
   GWRITE(WORDS,PREP,TRUE);
   END;

20:BEGIN
   BUTTN.BTN[20].TOGGLE:=NOT(BUTTN.BTN[20].TOGGLE);
   WITH WORDS DO
   BEGIN
   IF BUTTN.BTN[20].TOGGLE THEN NAME:='ON.' ELSE NAME:='OFF';
   X1:=270;Y1:=465;
   X2:=300;Y2:=475;
   FORCOL:=0;
   BKCOL:=15;
   END;
   GWRITE(WORDS,PREP,TRUE);
   END;

21: ZOOM(TRUE);

22: ZOOM(FALSE);

23: BEGIN
   WITH WORDS DO BEGIN
   NAME:='  Zoom in Mode...   ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);


    GETBOX(RX1,RY1,RX2,RY2);
    PUTPIXLS;
    XR2:=XR1+(RX2-1)*XSCALE;
    YR2:=YR1+(RY2-1)*YSCALE;
    XR1:=xr1+RX1*XSCALE;
    YR1:=yr1+RY1*YSCALE;
    if yr1>yr2 then yr2:=yr1;
    if xr1>xr2 then xr2:=xr1;
    PLOT(FALSE);
    END;
END;{case}

UNTIL PRES=9;

END;(*MENU*)
(**************************************************************************)
FUNCTION LOADFONT:BOOLEAN;
Var f_ok:boolean;
BEGIN
ASSIGN(SMALF,FNTFILE);
{$I-}
RESET(SMALF);
{$I+}
F_OK:=IORESULT=0;
IF F_OK THEN BEGIN
READ(SMALF,SMAL);
CLOSE(SMALF);
END;{IF F_OK}
LOADFONT:=F_OK;
END;
(**************************************************************************)
Function Help_is_there:Boolean;
Var F_ok:boolean;
Begin
Assign(Help_Book,Hlpfile);
f_ok:=false;
{$i-}
reset(Help_book);
{$i+}
if ioresult=0 then f_ok:=true;
if f_ok then close(Help_Book);
Help_is_there:=f_ok;
End;
(**************************************************************************)
FUNCTION INITIALISED:BOOLEAN;
VAR OK,F,INI:BOOLEAN;
BEGIN
SETVIDMODE(3);
INIT_MOUSE(OK);
F:= LOADFONT and Help_is_there;
INI:=(OK AND F);{CHECK ISVGA}
IF INI THEN BEGIN
SETVIDMODE($12);
FOR I:=0 TO 501 DO PL.ERR[I]:=FALSE;
END;
{IF NOT(ISVGA) THEN WRITELN('Requires VGA 256 color...');}
IF NOT(OK) THEN WRITELN('Requires MS-Mouse or compatible mouse...');
IF NOT(F) THEN
WRITELN('Unable to load Font file or Help file from current directory...');
INITIALISED:=INI;
END;
(**************************************************************************)
PROCEDURE QUIT;
BEGIN
SETVIDMODE(3);
{CHECK FOR WORK SAVED OR NOT IN FUTURE}
END;
(**************************************************************************)
Procedure Help;
{Type
    Hlp_Page=array[1..40,1..20] of char;

    Hlp_book=record
    Page_Name:string[30];
    Topic_no,
    Page_no:word;
    end;
}
     {
     Start-Program
     "Help Topics"  (* use procedure find topic no.,page no.*)
      1. About Mathkit  //description of program
      (limitations & requirements, Permitted Functions)
      2. How to Enter functions
      3. Setting range
      4. Taking Print-outs
     }
     {
      "Buttons"
       "Previous page" <-
       "Next Page"     ->
     }
const Hx1=164; Hy1=10*7;
      Hx2=8*40+Hx1; Hy2=hy1+8*20;{helpbox, no of lines}
      H_pg_col=1;
Var lines:butn;top_no,pg_num:word;e1,e2:boolean; hlp:hlp_book_page;

Procedure ShowPage(hl:hlp_book_page);
var lin:word;
begin
hide_mouse;
for lin:=1 to 20 do
begin
with lines do begin
     name:=hl.Help_page[lin];
     {eliminate trailing spaces}
     while name[length(name)]=' ' do dec(name[0]);
     x1:=hx1;x2:=hx2;
     y1:=hy1+8*(lin-1);y2:=y1+8;

     forcol:=15;Bkcol:=h_pg_col;
     end;{with}

gwrite(lines,prep,true);
end;
show_mouse;
end;

Procedure HidePage;
Begin
hide_mouse;
fildbox(hx1,hy1,hx2,hy2,h_pg_col);
show_mouse;
end;

Procedure Get_Topic_Page(TNum,PNum:word;Var hl:Hlp_book_page;var er1,er2:boolean);
Begin {Help_book should be closed before calling this}
{use hlpfile & Help_book}
er2:=false;
er1:=not(Help_is_there); {save from crashing if no diskette}
if not(er1) then
Begin
Assign(Help_Book,hlpfile);
reset(Help_Book);
hl.topic_no:=0;hl.page_no:=0;
while
(Not((eof(Help_Book)) or ((hl.topic_no=tnum) and (hl.page_no=pnum)))) Do
Begin                   {no. topics is known- but not no. of pages}
{ if help_is_there & err then goto next topic, page no=1..x}
read(help_book,hl);
end;

er2:=(eof(Help_book) and not((hl.topic_no=tnum) and (hl.page_no=pnum)));
close(Help_Book);

if not(er2) then begin
HidePage;showpage(hl);
end;

end;{if er1}

End;{proc}

Var Bts:Butns; Bt:Butn;bb:word;
Begin
(*help box*)
     fildbox(hx1-30,hy1-30,hx2+30,hy2+200,{h_pg_col}8);{help box}
     box(hx1-23,hy1-23,hx2+23,hy2+23,15,prep);
     box(hx1-31,hy1-31,hx2+31,hy2+201,15,prep);

with lines do begin
     name:='Help Box';
     x1:=hx1+(hx2-hx1) div 2-4*8;x2:=x1+8*8;
     y1:=hy1-30;y2:=y1+8;

     forcol:=13;Bkcol:=h_pg_col;
     end;{with}

gwrite(lines,prep,true);

     box(hx1-1,hy1-1,hx2+1,hy2+1,15,prep);{help box}
     box(hx1-2,hy1-2,hx2+2,hy2+2,15,prep);{help box}
(*help box*)
(* help topics *)
with lines do begin
     name:=' Help Topics';
     x1:=hx1+(hx2-hx1) div 2-6*8;x2:=x1+12*8;
     y1:=hy2+40;y2:=y1+8;

     forcol:=13;Bkcol:=h_pg_col;
     box(x1-1,y1-1,x2+1,y2+1,15,prep);{help box}
     end;{with}

gwrite(lines,prep,true);


     With Bts do Begin
     InUse:=7;{procedure box}

     WITH BTN[1] DO BEGIN
     NAME:=' START < PROGRAM > ';
     SCROLL:=FALSE;
     X1:=50; Y1:=10;
     X2:=LENGTH(NAME)*8+x1; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;{load colors & other butn settings from a file later}
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[1]}


     WITH BTN[2] DO BEGIN
     NAME:=' ABOUT-MATHKIT ';
     SCROLL:=FALSE;
     X1:=300; Y1:=463-16-60;
     X2:=x1+length(name)*8; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[2]}

     WITH BTN[3] DO BEGIN
     NAME:=' Entering Functions ';
     SCROLL:=FALSE;
     X1:=300; Y1:=447-16-70;
     X2:=x1+length(name)*8; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[3]}

     WITH BTN[4] DO BEGIN
     NAME:=' Seting Range ';
     SCROLL:=FALSE;
     X1:=300; Y1:=431-16-80;
     X2:=x1+length(name)*8; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[4]}

     WITH BTN[5] DO BEGIN
     NAME:=' Requirements ';
     SCROLL:=FALSE;
     X1:=300; Y1:=415-16-90;
     X2:=x1+length(name)*8; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[5]}

     WITH BTN[6] DO BEGIN
     NAME:=' Prev Page ';
     SCROLL:=FALSE;
     X1:=hx1+8; Y1:=hy2+10;
     X2:=x1+length(name)*8; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[6]}

     WITH BTN[7] DO BEGIN
     NAME:=' Next Page ';
     SCROLL:=FALSE;
     X1:=hx1+30*8; Y1:=hy2+10;
     X2:=x1+(length(name))*8; Y2:=y1+7;
     FORCOL:=13;
     BKCOL:=1;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     gcol:=14;
     dcol:=7;
     END;{BTN[7]}

     end;{Bts}

     PutButns(Bts);

     show_mouse;
     pg_num:=1;
     top_no:=1;
     bb:=0;

     repeat
     if isleftdown then begin
     bb:=ButnPressed(Bts);

     if bb>1 then begin

     if (bb<6) then
     begin top_no:=bb-1; pg_num:=1; end
     else
     if bb=7 then pg_num:=pg_num+1
     else if pg_num<>0 then pg_num:=pg_num-1;

     get_topic_page(top_no,pg_num,hlp,e1,e2);

     if e2 then pg_num:=1;{if topic & page combination not found}
                          {then assuming topics=4 & atleast one
                           page for each we set this}
                                                  {done}

     end;{if bb>1}
     end{isleftdown}
     else
     begin       (*left means exit on left mouse button press
                 so that left button press can be checked by something else
                 in loop say 'if isleftdown then bb:=butnspressed' etc.*)
     bb:=0;
     active_btns_left(bts);
     end;

{ERROR}
     until bb=1;
     Hide_mouse;
{make this procedure as main menu and call menu from here}
End;
(**************************************************************************)

BEGIN
IF INITIALISED THEN
   BEGIN
   Help;
   WITH GRFBTN DO BEGIN
   X1:=1;X2:=501;
   Y1:=1;Y2:=401;
   END;
   Fildbox(0,0,639,479,0);{clear screen}
   CLEAN;

   MENU;

   QUIT;

   WRITELN('SHEET RESOLUTION:- [ X-AXIS = 501 || Y-AXIS =401 ]');
   WRITELN;

   WRITELN('AUTO-RANGE SETS Y-SCALE FOR GIVEN X-RANGE FOR BEST RESULTS');
   WRITELN;

   WRITELN('AVAILIBLE FUNCTIONS ARE:-');
   WRITELN('ABS , ARCTAN, SIN, COS, LN, EXP');
   WRITELN;

   WRITELN('^(RAISED TO SYMBOL) DOES NOT GIVE VALUES FOR -VE NUMBERS RAISED TO POWER');
   WRITELN;

   WRITELN('FOR OBTAINING RESULTS FOR NEGETIVE VALUES TO BE RAISED ');
   WRITELN('FOR EG:-USE X*X FOR X^2....');
   WRITELN;

   WRITELN('Software Written By:-');
   WRITELN('Mandeep Singh Bhatia.');
   WRITELN('ALL RIGHTS RESERVED BY THE AUTHOR');
   WRITELN;

   WRITELN('THIS IS A SHAREWARE VERSION RELEASE');
   WRITELN('WITH LIMITED NO. OF FUNCTIONS & A SINGLE GRAPH TYPE');
   WRITELN('REGISTERED VERSION COVERS MANY OTHER MATHEMATICAL ANALYSIS TOOLS');
   WRITELN('AND MOST OF 2-D GRAPH TYPES ALONG WITH 3-D GRAPHING TOOLS.......');
   {
   WRITELN('AND ALONG WITH PROGRAMABLE FUNCTIONS & PROCEDURES CAPABILITY');
   WRITELN('SUPPORTING COMPLEX TYPE, POLAR FUNCS , VECTOR FUNCS ETC
   FOURIER + LAPLACE, TAYLOR SERIES, + OTHER HI-FI MATH & CALCULUS');
   +SIGNAL ANALYSIS ETC
   }
   WRITELN;
   {REGISTERED VERSION SHOULD HAVE MANUAL GRAPH SHEET DESIGN AS SPECIFIED
   BY USER & MANUAL PLOTS AT USER SPECIFIED POINTS FOR SCIENTIFIC
   DATA COLLECTION GRAPHS WHICH THEN COULD BE TRASFERED TO FUNCTION
   ANALYSIS SYSTEM USING PROBABILITY, CORELATION & OTHER LOGICS
   & SHOULD BE PROGRAMABLE}
   END
   ELSE WRITELN('PROGRAM TERMINATED DUE TO HARDWARE PROBLEM');

END.