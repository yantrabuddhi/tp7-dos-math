{$M 65520,64000,100000} {IN 7NTH VERSION REMOVE ALL SCROLLS AS SLOW}
                       {ALSO DISABLE & REMOVE BUTTONS NOT REQD.}
(* add polar(r,theta), f(x,y)=g(x,y) funcs*)
{all correct program}
{$R-,S-,L-,O-}  {<- TURN first 3 -'S TO +'s to program check}
{$N+,E-}
{all 2d fnc by f(x,y)=0 fnc all in 1 string OF JUST F(X,Y)
hence no auto range...}
{lesser code size with $ n not off}
(**************************************************************************)
PROGRAM MATHEMATICS;
(**************************************************************************)
USES CRT,GRAF16,{EVAL2D}posteval,MOUSE;
(**************************************************************************)
CONST MAXBUTNS=23;
      FNTFILE='DEFAULT.FNT';
      Hlpfile='Math2d.hl';
      AXIS=5;
      LIN=1;
(**************************************************************************)
TYPE BUTN=RECORD
     {graphic:boolean;if grafic then icon:icn(bitmap)}
     X1,Y1,X2,Y2:INTEGER;
     FORCOL,BKCOL,PMARGIN,RMARGIN,GCOL,DCOL:BYTE;{DCOL=RMARGIN}
     TOGGLE,SCROLL:BOOLEAN;{DISABLED:BOOLEAN}

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

    SCR_BITS= ARRAY[1..25113] OF BYTE;{501*401 DIV 8+1}

     PUTMODE=word;{=(PAND,POR,PXOR,PREP)}

     charset=set of char;

     BUTNCOUNT=1..MAXBUTNS;

     BUTNS=RECORD
     BTN  :ARRAY[BUTNCOUNT] OF BUTN;
     INUSE:0..maxbutns;
     END;

     XLINE=ARRAY[1..501] OF symbol_id;{PROB MAY BE DUE TO THIS}
     {DIRECT REC DECLARATION}
     {INF:ARRAY[1..501] OF BOOLEAN;}{CAN USE BIT ARRAY FOR THIS BUT WILL BE SLOW}

     FONT=ARRAY[0..255,0..7] OF byte;

{CHARS ARE 8*8, SO ROWS=Y/8 & COLS=X/8}
(**************************************************************************)
VAR BUTCONT: BUTNCOUNT;
    SMAL: FONT;
    Help_Book:File of Hlp_book_page;
    SMALF: FILE OF FONT;
    FUNC{,FN1,FN2}:string;
    func_post:exp_table;
    STORE:FUNCFILE;
    SAVFNC:FILE OF FUNCFILE;
    XR1,YR1,XR2,YR2:REAL;{SET A DEFAULT RANGE}
    RX1,RY1,RX2,RY2:INTEGER;{ZOOM}
    Vref:var_table;
    XSCALE,YSCALE:REAL;
    I : INTEGER;
    p{,OLD_SCR}:SCR_BITS;
    {SINCE XORPUT IS USED IN PLOT GIVIN SHOW_BITS
    REMOVES ALL BITS IF CALLED TWICE, THUS BEFORE CHANGING
    VALUES IN P_SCR REFRESH SCREEN BY CALLING WITH OLD VALUES}
    GRFBTN,
    WORDS:BUTN;
    errpos,errcode:word;
    ONBTN:BYTE;
    ZS,INF,FLAG,{ER,ERP,}EXPERR:BOOLEAN;{USE Experr INSTEAD OF EXPERR}
    {SET AUTO SCALING ,CALCULATE BY RANGE}
    EQU:BYTE;
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
{FUNCTION GETARRAY( P:SCR_BITS; X,Y:INTEGER):BOOLEAN;}
{NOT NEEDED AS ONLY BITS ARE STORED, ALL NEED TO BE DISPLAYED ONCE}
{TO DISPLAY WHOLE ARRAY RATHER THAN CALLING FUNC FOR FASTER
WORK DO ALL BY LOOP, BUT FUNCTION INCREASES SPACE USAGE EFFICIENCY}
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
    C,CUR:CHAR; {MAX LENGTH=10 FOR NUMS INCLUDING DECIMAL & NUM}
BEGIN   {MODE IS ALWAYS PXOR}
if ch<>[] then begin
CUR:=#15;{219 ,15,16,17}
{HIDE_MOUSE;}
S[0]:=#0; {MASK SHOULD BE TRUE}
X:=BUTS.X1; {A BOX SHOULD BE DEFINED TO SHOW READ AREA}
Y:=BUTS.Y1;{NOTE Y DOESN'T CHANGE WHICH MEANS THIS CAN'T APPEND DOWNLINE}
c:=#27;
{c:=#0;
while not(c in ch) do inc(c);}
REPEAT      {WE CAN CHANGE THIS IN TRUE EDITING}
(*COUT(CUR,X,Y,BUTS,PXOR,MASK);(**)
hide_mouse;
if ((s[0]=#0) and (c<>#8)) and ((c in ch) or (c=#13) or (c=#27))
then cout(cur,x,y,buts,pxor,mask);{initial cur-s[0]=#0 or 0 length}
if (((C=#13) or (C=#27) or (C=#8) or (c in ch)) and (s[0]<>#0))
then COUT(CUR,X,Y,BUTS,PXOR,MASK);(*s[0]<>#0*)
show_mouse;
IF UP THEN C:=UPCASE(READKEY) ELSE C:=READKEY;
IF ((C<>#13) AND (C<>#27) AND (C<>#8) and (c in ch)) THEN
BEGIN {PUT A CURSOUR TOO}
S:=S+C;
hide_mouse;
COUT(CUR,X,Y,BUTS,PXOR,MASK);{CURSOR HIDE}
COUT(C,X,Y,BUTS,PXOR,MASK);{mask=true or use prep rather pxor}
X:=X+8;
END;
IF ((C=#8) AND (LENGTH(S)>0)) THEN
BEGIN
hide_mouse;
COUT(CUR,X,Y,BUTS,PXOR,MASK);{CURSOR REMOVE}
X:=X-8;
COUT(S[LENGTH(S)],X,Y,BUTS,PXOR,MASK);
DEC(S[0]);
if length(s)=0 then cout(cur,x,y,buts,pxor,mask);
END;
show_mouse;
UNTIL ( (C=#13) OR (X>BUTS.X2-10) OR (C=#27) );
hide_mouse;
if ((c=#13) or (c=#27)) then COUT(CUR,X,Y,BUTS,PXOR,MASK);
{^CURSOR REMOVE if proper end}
{cursor works only because non append here, modify if append added
also max length of string has to be 1 less than displayable button size
for cursor to move, hence condition x>buts.x2-10 is given(change 10 to 20
if some problem arises}
buts.name:=S;
GWRITE(BUTS,PXOR,MASK);{???} {if to delete written text remove this}
{experimental step might be deleted}
if c=#27 then s[0]:=#0;
buts.name:=s;
{exp ends}
SHOW_MOUSE;
end;{if ch<>[]}
END;{PROC}
(**************************************************************************)
PROCEDURE PUTBUTNS(BUTS:BUTNS);
var b:byte;
BEGIN
if buts.inuse=0 then exit;
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
PROCEDURE GLOW_BTN(BUTS:BUTNS;BT,GLOW_COL:BYTE);
VAR CTDN:BYTE;
BEGIN
{HIDE MOUSE}
if buts.inuse=0 then exit;
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
if buts.inuse=0 then exit;
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
VAR BTP,btp2:BYTE;

BEGIN
BTP:=MOUSE_ON_BTN(BUTS);
WITH BUTS DO  BEGIN

IF (BTP>0) { NOT(BTN[BTP].SCROLL)}
THEN
IF NOT(BTN[BTP].SCROLL) THEN
BEGIN

HIDE_MOUSE;
GLOW_BTN(BUTS,BTP,BTN[BTP].PMARGIN);
SHOW_MOUSE;
REPEAT
btp2:=mouse_on_btn(buts);
UNTIL (NOT(ISLEFTDOWN) or (btp2=0));
HIDE_MOUSE;
GLOW_BTN(BUTS,BTP,BTN[BTP].RMARGIN);
btp:=btp2;
SHOW_MOUSE;

END;{IF BTP}
END;{WITH BUTS}
(**)
butnpressed:=btp;
end;
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
fillchar(P[1],SIZEOF(P),#0);
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
(*
PROCEDURE POINT(X,Y:INTEGER;CLR:BYTE);{PIXEL ON GRAPH}
BEGIN
IF INBTN(GRFBTN,X,401-Y) THEN
PUTPIXEL16(X,401-Y,CLR,PXOR);
END; inbtn not reqd
*)
(**************************************************************************)
FUNCTION GETARRAYBIT( X,Y:INTEGER):BOOLEAN;
var l:longint; w,n,bitnum:integer{in range for 25113};
BEGIN
l:=(y-1)*501+(x+7);
w:=l div 8 ;{operator over-loading used}{bit num= l mod 8}
bitnum:=l mod 8;
n:=1 shl bitnum;{bitnum=0..7}
GETARRAYBIT:=((p[w] AND N)<>0);{value is set}

END;
(**************************************************************************)
PROCEDURE SETARRAYBIT(X,Y:LONGINT);{ALWAYS SETS 0 TO 1, USE FILL CHAR TO CLEAR}
var l:longint; w,bitnum:integer{in range for 25112};
begin
{assumes x& y are in range of assumed 501 & 401 by array size assumption}
L:=(y-1)*501+(x+7);
w:=l div 8 ;{operator over-loading used}{bit num= l mod 8}
bitnum:=l mod 8;
{bitnum=0..7}
p[w]:=p[w] or (1 SHL BITNUM);{value is set}

end;
(**************************************************************************)
PROCEDURE SHOW_BITS;{ASK..PUTMODE? its always xor here}
var w,b,n:integer; l,X,Y:longint; {only for mode $12}
begin
{puts true bits only to increase speed, hence requires to wipe old ones by xor
assuming that no. of bits to put is<< no. of bits in graph sheet/2}
IF ( NOT(EXPERR) AND (YSCALE<>0) AND (XSCALE<>0)) THEN BEGIN
HIDE_MOUSE;
for x:=1 to 501 do
    for y:=1 to 401 do begin
    l:=(y-1)*501+x+7;
    w:=l div 8;
    b:=l mod 8;{which bit no. out of 0..7 is pixel stored in}
    n:=1 shl b;{bth bit only=1 byte no.}
       {if bit at bth location=1 or true}
    if ((p[w] and n)<>0) then putpixel16(x,402{401}-y,15,pxor);{uses pxor}
    {DELETE OLD SCR BEFORE PUTTING NEW} {NO PLOT AT SHO BITS???}
    end; {SHOW_BITS BEING CALLED REPEATEDLY ???}
    {MAY BE VALUES IN ARRAY ARE NOT BEING SET RIGHT}
SHOW_MOUSE;
END;{if no scale & expr problems}
end;{proc}
(**************************************************************************)
{NEW SHOW SCALE NEEDED AFTER MODIFICATIONS}
{AUTO-SCALE CAN'T BE DONE WITH THIS METHOD, THUS ELIMINATE THAT}
(**************************************************************************)
PROCEDURE PLOT;
VAR {INF}INF1,INF2,INF3,INF4,INF_REC:BOOLEAN;
{VREF:VAR_TABLE;}
{INF_REC= INFINITY EVALUATED SOMEWHERE}
    {RESULT}R1,R2:XLINE;
            E1,E2,E3,E4,ABS_E1,ABS_E2:REAL;
    XC,XCOUNT,YCOUNT:WORD{INTEGER};{TURN TO WORD FOR FASTER CALCS}
    po,LEN:byte;{SET FN1 & FN2 AT TIME OF FUNC ASKING}
BEGIN
{VREF.NUM_VARS_USED:=4;
VREF.VARS[1].NAME:='X';
VREF.VARS[2].NAME:='Y';
VREF.VARS[3].NAME:='PI';
VREF.VARS[4].NAME:='DR';
VREF.VARS[3].VALUE:=PI;
VREF.VARS[4].VALUE:=180/PI;}
{IF ONLY PROCEDURE PLOT USED TO CALL SHOWBITS THEN DEL & DRAW IN THIS PROC ONLY}
XSCALE:=(XR2-XR1)/500;{501-1}
YSCALE:=(YR2-YR1)/400;{BEFORE BECAUSE NEDDED FOR CALCS IN LOOP}
XCOUNT:=1;{GrFBTN.X1}
YCOUNT:=1;{INITIAL}
INF_REC:=FALSE; ZS:=FALSE;
IF YSCALE<0.00000001 THEN YSCALE:=0;
IF XSCALE<0.00000001 THEN XSCALE:=0;
{SHOW_BITS;}{DELETE PREVIOS SCREEN- DONE BEFORE CALLING PLOT}
{ALL PLOTTING DONE BY PROC PLOT ONLY}
SHOW_BITS;
FILLCHAR(P[1],SIZEOF(P),#0);{put in clean proc}
if (yscale<>0) and (xscale<>0) then begin
(*WHILE ( {(YCOUNT<402) AND} (XCOUNT<502{GRFBTN.X2}) AND NOT(EXPERR) ) DO*)
vref.vars[2].value:=YR1;
FOR XCOUNT:=1 TO 501 DO
{EVALUATEXY}
begin
vref.vars[1].value:=XR1+(XCOUNT-1)*XSCALE;
eval_postfix(FUNC_post,Vref,r1[xcount]);
{R1.INF[XCOUNT]:=;}
end;

FOR YCOUNT:=2 TO 401 DO
BEGIN
FOR XCOUNT:=1 TO 501 DO
begin
vref.vars[1].value:=XR1+(XCOUNT-1)*XSCALE;
vref.vars[2].value:=YR1+(YCOUNT-1)*YSCALE;
eval_postfix(FUNC_post,Vref,r2[xcount]);
end;{XCOUNT LOOP ENDS}

FOR XC:=1 TO 500 DO   {.INF'S NEED NO INITIALISE AS DONE IN EVALXY}
BEGIN
 E2:=R2[XC].value; E3:=R2[XC+1].value;
 E1:=R1[XC].value; E4:=R1[XC+1].value;
 with r2[xc] do
 INF2:=inf or unreal or indeter;
 with r2[xc+1] do
 INF3:=inf or unreal or indeter;
 with r1[xc] do
 INF1:=inf or unreal or indeter;
 with r1[xc+1] do {THIS LINE WAS WRONGLY PUT}
 INF4:=inf or unreal or indeter;
 {2 PARALLEL Y LINES ARE MOVING FOR VALUES OF XC}
IF (INF1 OR INF2 OR INF3 OR INF4) THEN INF_REC:=TRUE;
{DIRECT TOUCH TO ZERO CHECK}
(*************************************************************************)
IF EQU=0 THEN
BEGIN
(* PLANE-SIDE INTERSECTION CHECK WITH Z=0, FOR FUNC F(X,Y)=0 *)
IF   ( {E1,E2}
     NOT(INF1 OR INF2) AND ( ((E1>0) AND (E2<0)) OR ((E1<0) AND (E2>0)) )
     )
     THEN BEGIN {CAN REMOVE BEGIN END}
     ABS_E1:=ABS(E1);
     ABS_E2:=ABS(E2);
          IF ABS_E1<=ABS_E2 THEN SETARRAYBIT(XC,YCOUNT-1);
                 {SUBSTITUTE VARIABLES RATHER CALLING ABS}
          IF ABS_E1>=ABS_E2 THEN SETARRAYBIT(XC,YCOUNT);
     END;

IF   ( {E2,E3}
     NOT(INF3 OR INF2) AND ( ((E3>0) AND (E2<0)) OR ((E3<0) AND (E2>0)) )
     )
     THEN BEGIN {CAN REMOVE BEGIN END}
     ABS_E1:=ABS(E3);
     ABS_E2:=ABS(E2);
          IF ABS_E1<=ABS_E2 THEN SETARRAYBIT(XC+1,YCOUNT);
                 {SUBSTITUTE VARIABLES RATHER CALLING ABS}
          IF ABS_E1>=ABS_E2 THEN SETARRAYBIT(XC,YCOUNT);
     END;

IF   ({E3,E4}
     NOT(INF3 OR INF4) AND ( ((E3>0) AND (E4<0)) OR ((E3<0) AND (E4>0)) )
     )
     THEN BEGIN {CAN REMOVE BEGIN END}
     ABS_E1:=ABS(E3);
     ABS_E2:=ABS(E4);
          IF ABS_E1<=ABS_E2 THEN SETARRAYBIT(XC+1,YCOUNT);
                 {SUBSTITUTE VARIABLES RATHER CALLING ABS}
          IF ABS_E1>=ABS_E2 THEN SETARRAYBIT(XC+1,YCOUNT-1);
     END;

IF   ({E1,E4} {ADJACENT SIDES TO BE CHECKED ONLY IN POLYGON}

      {(E1<>0) OR (E4<>0)) AND} NOT(INF1 OR INF4) AND
      {SET A FAST PROC FOR BELOW COMPARISONS}
      ( ((E1>0) AND (E4<0)) OR ((E1<0) AND (E4>0)) )
     )
     THEN BEGIN {CAN REMOVE BEGIN END}
     ABS_E1:=ABS(E1);
     ABS_E2:=ABS(E4);
          IF ABS_E1<=ABS_E2 THEN SETARRAYBIT(XC,YCOUNT-1);
                 {SUBSTITUTE VARIABLES RATHER CALLING ABS}
          IF ABS_E1>=ABS_E2 THEN SETARRAYBIT(XC+1,YCOUNT-1);
     END;
 END;{EQU=0}
(*************************************************************************)
  CASE EQU OF
  0:
  BEGIN {REMOVE NOT INF(REC IN EQU=0 IF WRONG GRAPH DUE TO INDETER}
  IF ((E1=0) AND NOT(INF1)) THEN SETARRAYBIT(XC,YCOUNT-1);{PUT OR INDETER HERE}
  IF ((E2=0) AND NOT(INF2)) THEN SETARRAYBIT(XC,YCOUNT);
  IF ((E3=0) AND NOT(INF3)) THEN SETARRAYBIT(XC+1,YCOUNT);
  IF ((E4=0) AND NOT(INF4)) THEN SETARRAYBIT(XC+1,YCOUNT-1);
  END;
  1:
  BEGIN     {set a undet, unr chk in needed in future}
  IF ((E1>0)) THEN SETARRAYBIT(XC,YCOUNT-1);{PUT OR INDETER HERE}
  IF ((E2>0)) THEN SETARRAYBIT(XC,YCOUNT);
  IF ((E3>0)) THEN SETARRAYBIT(XC+1,YCOUNT);
  IF ((E4>0)) THEN SETARRAYBIT(XC+1,YCOUNT-1);
  END;
  2:
  BEGIN
  IF ((E1<0)) THEN SETARRAYBIT(XC,YCOUNT-1);{PUT OR INDETER HERE}
  IF ((E2<0)) THEN SETARRAYBIT(XC,YCOUNT);
  IF ((E3<0)) THEN SETARRAYBIT(XC+1,YCOUNT);
  IF ((E4<0)) THEN SETARRAYBIT(XC+1,YCOUNT-1);
  END;
  3:
  BEGIN
  IF ((E1>=0)) THEN SETARRAYBIT(XC,YCOUNT-1);{PUT OR INDETER HERE}
  IF ((E2>=0)) THEN SETARRAYBIT(XC,YCOUNT);
  IF ((E3>=0)) THEN SETARRAYBIT(XC+1,YCOUNT);
  IF ((E4>=0)) THEN SETARRAYBIT(XC+1,YCOUNT-1);
  END;
  4:
  BEGIN
  IF ((E1<=0)) THEN SETARRAYBIT(XC,YCOUNT-1);{PUT OR INDETER HERE}
  IF ((E2<=0)) THEN SETARRAYBIT(XC,YCOUNT);
  IF ((E3<=0)) THEN SETARRAYBIT(XC+1,YCOUNT);
  IF ((E4<=0)) THEN SETARRAYBIT(XC+1,YCOUNT-1);
  {plot not equal???}
  END;

  END;{CASE}
  END;{FOR XC}
(* PLANE INTERSECTION CHECK*)
MOVE(R2,R1,SIZEOF(R2));{<-stays compatible always}
{MOVE R2->R1 SO R1 GETS NEW VALUES, WHICH ACT AS PREV VALUES FOR NEXT R2}
END;{FOR YCOUNT}

{YSCALE:=(YR2-YR1)/400;}{401-1}{if yr1>yr2 then swap values..similar for x}
SHOW_BITS;{DISPLAY NEW PIXELS}
          {XORPUT OLD BEFORE NEW ONE}
          end else  ZS:=TRUE{IF SCALES=0 OR LESS THAN MIN VALUE};
SHOWSCALE; {DISPLAY CALCULATED INFO}
WITH WORDS DO BEGIN
IF ZS THEN NAME:=' ZERO SCALE VALUE...'{SIZE=20 CHARS}
ELSE
IF INF_REC THEN
               NAME:='INFINITY EVALUATED..'
               {i.e infinity(out of range evaluation) discarded..}
               {out of range eval. means Big-Number or Uncalculatable value}
         else  NAME:=' Done....           ';
FORCOL:=10;
BKCOL:=1;
X1:=4;X2:=204;
Y1:=460;Y2:=470;{THIS CAN BE SHARED}
END;{WITH}
GWRITE(WORDS,PREP,TRUE);{PUT A MESSAGE AFTER JOB DONE}
END; {ALL DONE IN THIS PROC PLOT}


(**************************************************************************)
procedure getbox(var x1,y1,x2,y2:INTEGER);{COMPATIBLE}
{turn to word if probs}
{purpose to get x1,y1,x2,y2 co-ordinates using mouse xor to restore before leaving}
{for saving screen for mrk undo,or ellipse,or rectangle ect.}
{setpixl converts the co-ordinates nothing else required}
var X,Y,xnew,ynew:INTEGER;{IS WORD BETTER THAN INTEGER}
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
getmousexy(X2,Y2);                  {change if getbox error}
until ( (((x2<>XNEW) AND (y2<>YNEW)) OR (NOT(ISLEFTDOWN)))
      AND INBTN(GRFBTN,X2,Y2) );
box(x1,y1,XNEW,YNEW,4,pxor);
box(x1,y1,x2,y2,4,pxor);
UNTIL ( ((X2<>X1) AND (Y2<>Y1)) AND (NOT(ISLEFTDOWN)) );
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

PROCEDURE ZOOM({p:scr_ptr;}PLUS:BOOLEAN);{ KEEP ONLY BOX ZOOM, OR THIS =100X}
               {p_scr is only array passed to pointer}
               {but shouldn't pass p_scr as para.. might cause stk overflow}
               {as its a value parameter.. compiler may make copies}
var xr,yr:real;
BEGIN
if (not(experr) and (xscale<>0) and (yscale<>0)) then begin
XR:=50*XSCALE; {SET X ZOOM RATE & Y ZOOM RATE BY BUTTONS}
YR:=40*YSCALE;
   IF PLUS THEN
      IF ((YR2-YR)>(YR1+YR)) AND ((XR2-XR)>(XR1+XR)) THEN
      {IN ABOVE CORRECT CHECK XR2-XR1, YR2-YR1 FOR BEING>=500*1.E-8
                                       OR >=400*1.E-8 FOR XR,YR RESPECTIVELY
      BUT NOT REALLY NEEDED}
      BEGIN
      YR2:=YR2-YR;
      YR1:=YR1+YR;
      XR1:=XR1+XR;
      XR2:=XR2-XR;
      END ELSE
         ELSE   {IF NOT PLUS THEN}
      IF (YR2+YR<9999999999.0) AND (XR2+XR<9999999999.0)
      AND (YR1-YR>-999999999.0) AND (XR1-XR>-999999999.0)
      THEN BEGIN
      YR2:=YR2+YR;
      YR1:=YR1-YR;
      XR1:=XR1-XR;
      XR2:=XR2+XR;
      END; {compatible to new plot}
      {PLOT HERE TURNS YSCALE & XSCALE=0 FIRST SO NO PLOT ON LOW VALS}
PLOT;{(FALSE)- check if = exists in eqn, if doesn't & no y's then do lenear plot}
     {with autoscaling enabled else work for 2-d plot}
     end;{if experr}
END;
(**************************************************************************)
PROCEDURE PGUP(UP:BOOLEAN);{PARAM FAST TO BE THERE}
VAR Y:REAL;{ONLY TO MODIFY THIS & SCRL PROCS}

BEGIN {WORK ONLY IF EXPRESSION ERROR IS NOT THERE i.e experr=false}
Y:=YR2-YR1;
IF Y>=400.0E-8{400 * 1.0E-8- SMALLEST DIFF FOR Y'S FOR YSCALE}
THEN
{VALUE AT NEW Y'S IS NOW TO BE CALCULATED AS NOT STORED IN 2D , FROM PREV PROJ}
   IF UP THEN
      IF ((YR2+Y)<9999999999.0) THEN
      BEGIN
      YR1:=YR1+Y; YR2:=YR2+Y;
      END
    ELSE else

      IF (YR1>(-999999999.0+Y)) THEN
      BEGIN
      YR1:=YR1-Y; YR2:=YR2-Y;
      END;
PLOT;{ALMOST DONE REMOVE SLOW, FAST MODES & PUT THE FAST METHOD ONLY}
END;
(**************************************************************************)
PROCEDURE PGLFT(LFT:BOOLEAN);{OK , COMPATIBLE MAYBE}
VAR X:REAL;
BEGIN
X:=XR2-XR1;
IF X>=500.0E-8 THEN {BEGIN}
{Show_bits;} {REPLACE PUTPIXLS BY SHOW_BITS & CALC NEW VALUES OF SCROLL}
          {BY MATCHING FN1 WITH FN2,, MAKE FN1 & FN2 GLOBAL}
   IF LFT THEN
      IF ((XR1-X)>-999999999.0) THEN
      BEGIN
      XR1:=XR1-X; XR2:=XR2-X;
      END
      else else

      IF (XR2<(9999999999.0-X)) THEN
      BEGIN
      XR1:=XR1+X; XR2:=XR2+X;
      END;
PLOT;
{END;}{IF}
END; {PROC}
(**************************************************************************)
(**************************************************************************)
{SCROLLING REMOVED}
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
    exits:boolean;

BEGIN
(**********************************************)
exits:=false;
WITH BUTTN DO
     BEGIN

     INUSE:=0;{init}
     {1}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:=' FUNCTION ';
     SCROLL:=FALSE;
     X1:=4; Y1:=415;
     X2:=84; Y2:=423;
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

     {2}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     {3}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     {4}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     {5}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     {6}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     {7}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:='            *   PLOT   *';
     {gwrite's append feature helps text to be appended in box}
     SCROLL:=FALSE;
     X1:=513; Y1:=4;
     X2:=609; Y2:=28;
     {text position in button should be specifiable}
     {which buttons are enabled & have spl properties
     should be specified}
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
     {8}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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

     {9}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     END;{BTN[9]}

     {10}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     END;{BTN[10]}

     {11}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     END;{BTN[11]}

     {12}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     END;{BTN[12]}

     {13}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:=#27;
     SCROLL:=false{TRUE};
     X1:=400; Y1:=465;
     X2:=408; Y2:=473;
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

     {14}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:=#26;
     SCROLL:=false{TRUE};
     X1:=418; Y1:=465;
     X2:=426; Y2:=473;
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

     {15}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:=#24;
     SCROLL:=false{TRUE};
     X1:=436; Y1:=465;
     X2:=444; Y2:=473;
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

     {16}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:=#25;
     SCROLL:=false{TRUE};
     X1:=454; Y1:=465;
     X2:=462; Y2:=473;
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

     {17}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
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
     END;{BTN[17]}

     {18}
     inuse:=inuse+1;
     WITH BTN[inuse] DO BEGIN
     NAME:='EQU';
     SCROLL:=false;
     X1:=510; Y1:=465;
     X2:=534; Y2:=473;
     FORCOL:=14;
     BKCOL:=3;
     TOGGLE:=FALSE;
     VERT:=FALSE;
     DOWN:=FALSE;
     PMARGIN:=12;
     RMARGIN:=7;
     GCOL:=14;
     DCOL:=7;
     END;{BTN[18]}

     END;{BUTTN}

(**********************************************)
{WRITE ALL DEFUALT VALUES}
{DEFAULT RANGE SET}
XR1:=-250;YR1:=-200;
XR2:=250;YR2:=200;{2>1 ALWAYS}
FUNC:='Y-X';
EQU:=0;{EQUALITY =, >, <, >=, <=}
infix_to_postfix(func,func_post,vref,errcode,errpos);
XSCALE:=1;
YSCALE:=1;{why??- because size ymax-ymin+1= yres of graph... hence scale=1}
{MAKE proc set_scale}
WITH WORDS DO BEGIN
   words.name:='= 0';
   X1:=540;Y1:=465;
   X2:=564;Y2:=475;
   FORCOL:=0;
   BKCOL:=15;
   GWRITE(WORDS,PREP,TRUE);
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
   REPEAT
WORDS.NAME:='                                                                               ';
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,TRUE,[#0..#255],TRUE);
   GWRITE(WORDS,PREP,TRUE);{remove these if pxor used}
   FUNC:=WORDS.NAME;
   infix_to_postfix(func,func_post,vref,errcode,errpos);
   UNTIL (errcode=0);{EXIT IF TRUE, TRUE WHEN RIGHT}
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
   NAME:='          ';{*}
   X1:=515;X2:=x1+8*length(name)+8;
   Y1:=135;Y2:=145;
   FORCOL:=15;
   BKCOL:=0;
   END;
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   xr2:=str_val(words.name,inf);
   {EVALUATEXY(WORDS.NAME,0,0,XR2,Experr,inf);}{1e4 is valid}
   {if not(experr) then begin}
   WITH WORDS DO BEGIN
   NAME:='X-Max Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   UNTIL ((XR2>XR1));
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
   NAME:='          ';{*} {NAME BUTTON SIZE IS 10, READIN OF TEN CHARS IS
                           AUTO MATICALLY SET}
   X1:=515;X2:=x1+8*(length(name)+1){<- extra space};
   Y1:=165;Y2:=175;
   FORCOL:=15;
   BKCOL:=0;
   END;
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   {EVALUATEXY(WORDS.NAME,0,0,YR2,Experr,inf);}
   YR2:=str_val(words.name,inf);

   WITH WORDS DO BEGIN
   NAME:='Y-Max Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);
                       {TEST LENGTH OF VALUE RETURNED<=10 OR NOT}
   UNTIL ((YR2>YR1) and not(inf));
                                    {&YR2<9999999999));}
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
   NAME:='          ';{*}
   X1:=515;X2:=x1+8*length(name)+8;
   Y1:=75;Y2:=85;
   FORCOL:=15;
   BKCOL:=0;
   END;
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);{if evaluate is ok only then Gwrite }
   {EVALUATEXY(WORDS.NAME,0,0,XR1,Experr,inf);}
   XR1:=str_val(words.name,inf);

   WITH WORDS DO BEGIN
   NAME:='X-Min Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

   UNTIL ((XR1<XR2) AND (NOT(inf)));

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
   NAME:='          ';{*}
   X1:=515;X2:=x1+8*length(name)+8;
   Y1:=105;Y2:=115;
   FORCOL:=15;
   BKCOL:=0;
   END;
   GWRITE(WORDS,PREP,TRUE);
   GREAD(WORDS,FALSE,['0'..'9','.','-'],TRUE);
   GWRITE(WORDS,PREP,TRUE);
   {EVALUATEXY(WORDS.NAME,0,0,YR1,Experr,inf);}
   YR1:=str_val(words.name,inf);

WITH WORDS DO BEGIN
   NAME:='Y-Min Done...       ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);
   UNTIL ((YR1<YR2) AND (NOT(inf)));

7: PLOT;
(*
8: PLOT{(TRUE)};{DISABLE AUTO RANGE FOR NOW}
*)
8: {EXIT}exits:=true;

9: WITH BUTTN DO
    BEGIN
    HIDE_MOUSE;
    CLEAN;
    IF BTN[12].TOGGLE THEN SHEET;
    SHOW_MOUSE;
    END;



10: WITH BUTTN DO
    BEGIN
    HIDE_MOUSE;
    CLEAN;
    BTN[12].TOGGLE:=NOT(BTN[12].TOGGLE);
    IF BTN[12].TOGGLE THEN SHEET;
    SHOW_MOUSE;
    END;

11: Begin
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

12: {IF NOT(BUTTN.BTN[13].TOGGLE) THEN ASK;{SURE(Y/N)}
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

13:pglft(true);
14:pglft(false);
15:pgup(true);
16:pgup(false);

17: BEGIN
   WITH WORDS DO BEGIN
   NAME:='  Zoom in Mode...   ';{20=length}
   FORCOL:=10;
   BKCOL:=1;
   X1:=4;X2:=204;
   Y1:=460;Y2:=470;{THIS CAN BE SHARED}
   END;{WITH}
   GWRITE(WORDS,PREP,TRUE);

    GETBOX(RX1,RY1,RX2,RY2);


    {XR1-X RANGE MIN
     XR2-X RANGE MAX
     YR1-Y RANGE MIN
     YR2-Y RANGE MAX}
    XR2:=XR1+(RX2-2)*XSCALE;
    YR2:=YR1+((401-(RY1-1))-1{<-BORDER CASE & INITIAL VAL})*YSCALE;
    XR1:=xr1+(RX1-2)*XSCALE;{adjust x if problems}
    YR1:=YR1+((401-(RY2-1))-1)*YSCALE;
    {assuming yr2=yr1+yscale*400}
    {ERROR IN YR1 AS GRAPH SHIFTED UP}
    if yr1>yr2 then yr2:=yr1;
    if xr1>xr2 then xr2:=xr1;
    PLOT;
    END;

 18:
 BEGIN
   EQU:=EQU+1;
   IF EQU>4 THEN EQU:=0;
   WITH WORDS DO
   BEGIN
   CASE EQU OF
   0:NAME:='= 0';
   1:NAME:='> 0';
   2:NAME:='< 0';
   3:NAME:='>=0';
   4:NAME:='<=0';
   END;{CASE}
   {IF BUTTN.BTN[20].TOGGLE THEN NAME:='ON.' ELSE NAME:='OFF';}

   X1:=540;Y1:=465;
   X2:=564;Y2:=475;
   FORCOL:=0;
   BKCOL:=15;
   END; {WITH}
   GWRITE(WORDS,PREP,TRUE);
   END;{EQUALITY}
END;{case}

UNTIL exits=true;

END;(*MENU*)  {EVERYTHING BELOW NEEDS NO COMPATIBILITY ADJUSTMENT}
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
IF INI THEN
begin
SETVIDMODE($12);
with Vref do
begin     {vref values not used by plotter or what}
num_vars_used:=4;
vars[1].name:='X';
vars[2].name:='Y';
vars[3].name:='PI';
VARS[3].VALUE:=PI;{PI IS LOADED FROM MACHINE}
Vars[4].name:='DEGRAD';{WHEN MULTIPLIED TO DEGREES GIVES RADIANS}
VARS[4].VALUE:=180/PI;
end;{Vref}
end;
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
     NAME:=' ABOUT-Graph2d ';
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
     NAME:=' Setting Range ';
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

   WRITELN('THIS VERSION IS FOR IMPLICIT FUNCTIONS F(X,Y)=0 ');
   WRITELN;

   WRITELN('AVAILIBLE FUNCTIONS ARE:-');
   WRITELN('ABS , ARCTAN, SIN, COS, LN, EXP, INT, FRAC, SGN, ROUND');
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
