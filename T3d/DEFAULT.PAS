program makefont;
uses crt,graph;
const filename='default.fnt';
type font=array[0..255,0..7] of byte;
     var f1:file of font;
         v,vg,f:integer;
         c,cc:char; fa:font;
         g:byte;

begin
v:=vga;
vg:=vgahi;
initgraph(v,vg,'\tp');

settextstyle(defaultfont,horizdir,0);
setcolor(4);
for c:=#0 to #255 do
begin
outtextxy(0,0,c);
for vg:=0 to 7 do begin
G:=0;
for v:=0 to 7 do begin
f:=getpixel(v,vg);
if f=4 then g:=g or 1;
if v<7 then g:=g shl 1;
end;
fa[ord(c),vg]:=g;
end;
for vg:=0 to 7 do
for v:=0 to 7 do putpixel(v,vg,0);
end;

{make file}
assign(f1,filename);
rewrite(f1);
write(f1,fa);
close(f1);
cc:=readkey;
closegraph;
end.
