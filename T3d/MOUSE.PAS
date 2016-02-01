unit mouse;
interface
uses dos;
var r:registers;
procedure init_mouse(var b:boolean);
procedure show_mouse;
procedure hide_mouse;
procedure curr_info(var row,col:integer;var button:byte);
procedure getmousexy(var x,y:integer);
function isLeftDown:boolean;
function isRightDown:boolean;
function BothDown:boolean;
procedure MoveMouse(ro,co:integer);
procedure LeftTimesPressed(var ltimes,lrows,lcols:integer);
procedure RightTimesPressed(var rtimes,rows,cols:integer);
procedure LeftTimesReleased(var lnum,lrowsn,lcolsn:integer);
procedure RightTimesReleased(var rnum,rowsn,colsn:integer);
procedure HorizRest(right,left:integer);
procedure VertRest(up,down:integer);
implementation
procedure init_mouse(var b:boolean);
var f:boolean;g:byte;
begin
{$i-}
r.ax:=0;
intr(51,r);
{i+}
if r.bx=0 then b:=false else b:=true;
end;
procedure show_mouse;
begin
r.ax:=1;
intr(51,r);
end;
procedure hide_mouse;
begin
r.ax:=2;
intr(51,r);
end;
procedure curr_info(var row,col:integer;var button:byte);
begin
r.ax:=3;intr(51,r);
row:=r.dx;col:=r.cx;button:=r.bx;
end;
procedure getmousexy(var x,y:integer);
var bt:byte;
begin
curr_info(y,x,bt);
end;
function isLeftDown;
var a,b:integer;btn:byte;
begin
curr_info(a,b,btn);
if btn=1 then isleftdown:=true
else isleftdown:=false;
end;
function isRightDown;
var a,b:integer;btn:byte;
begin
curr_info(a,b,btn);
if btn=2 then isrightdown:=true
else isrightdown:=false;
end;
function BothDown;
var a,b:integer;btn:byte;
begin
curr_info(a,b,btn);if btn=3 then bothdown:=true else bothdown:=false;
end;
procedure MoveMouse(ro,co:integer);
begin
r.dx:=ro;r.cx:=co;r.ax:=4;intr(51,r);
end;
procedure LeftTimesPressed(var ltimes,lrows,lcols:integer);
begin
r.bx:=0;r.ax:=5;intr(51,r);ltimes:=r.bx;lrows:=r.dx;lcols:=r.cx;
end;
procedure RightTimesPressed(var rtimes,rows,cols:integer);
begin
r.bx:=1;r.ax:=5;intr(51,r);rtimes:=r.bx;rows:=r.dx;cols:=r.cx;
end;
procedure LeftTimesReleased(var lnum,lrowsn,lcolsn:integer);
{lnum: No. of times key was released
lrowsn:row where last time button was released
lcolsn:col ""             ""            ""    }
begin
r.bx:=1;r.ax:=6;intr(51,r);lnum:=r.bx;lrowsn:=r.dx;lcolsn:=r.cx;
end;
procedure RightTimesReleased(var rnum,rowsn,colsn:integer);
begin
r.bx:=0;r.ax:=6;intr(51,r);rnum:=r.bx;rowsn:=r.dx;colsn:=r.cx;
end;
procedure HorizRest(right,left:integer);
begin
r.cx:=right;r.dx:=left;r.ax:=7;intr(51,r);
end;
procedure VertRest(up,down:integer);
begin
r.cx:=up;r.dx:=down;r.ax:=8;intr(51,r);
end;
end.