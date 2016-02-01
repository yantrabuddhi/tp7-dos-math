program makefont;
uses crt,graph;
const filename='small.fnt';
type font=array[0..255,0..10] of word;
     var f1:file of font;
         v,vg,f:integer;
         c,cc:char; fa:font;
         g:word;

begin
v:=vga;vg:=vgahi;
initgraph(v,vg,'\tp7');

settextstyle(smallfont,horizdir,4);
setcolor(4);
for c:=#0 to #255 do
begin
outtextxy(0,-1,c);
for vg:=0 to 10 do begin
G:=0;
for v:=0 to 15 do begin
f:=getpixel(v,vg);
if f=4 then g:=g or 1;
if v<15 then g:=g shl 1;
end;
fa[ord(c),vg]:=g;
end;
for vg:=0 to 10 do
for v:=0 to 15 do putpixel(v,vg,0);
end;

{make file}
assign(f1,filename);
rewrite(f1);
write(f1,fa);
close(f1);
cc:=readkey;
closegraph;
end.