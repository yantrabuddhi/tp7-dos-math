program Edit_helpfile;
uses crt;

const enter=#13;
      bkspc=#8;
      esc=#27;

Type  {topic_no=1..4}
    Hlp_Page=array[1..20] of string[40];
             {20 lines of 40 length in a page}
    Hlp_book_page=record
    Page_Name:string[30];
    Topic_no,
    Page_no:word;
    Help_Page:hlp_page;
             end;

var help_book:file of hlp_book_page;
    hlpfile:string; ch:char;
    hl_pg,temp_pg:hlp_book_page;
    e1,e2:boolean;
    T_no,P_no:word;
{esc= prev line
 enter= next line, exit if pressed at last line
 bkspace= erase previous char
 }
Procedure Get_Topic_Page(TNum,PNum:word;Var hl:Hlp_book_page;var er1,er2:boolean);
Begin {Help_book should be closed before calling this}
{use hlpfile & Help_book}
Assign(Help_Book,hlpfile);
{$i-}
reset(Help_Book);
{$i+}
er1:=ioresult=0;
if er1 then begin
hl.topic_no:=0;hl.page_no:=0;
while
(Not((eof(Help_Book)) or ((hl.topic_no=tnum) and (hl.page_no=pnum)))) Do
Begin                   {no. topics is known- but not no. of pages}
{ if help_is_there & err then goto next topic, page no=1..x}
read(help_book,hl);
end;
er2:=(eof(Help_book) and not((hl.topic_no=tnum) and (hl.page_no=pnum)));
close(Help_Book);
end;
End;

procedure init_page(var hl:hlp_book_page);
var i:word;
begin
with hl do begin
topic_no:=0;
page_no:=0;
fillchar(help_page,sizeof(help_page),' ');
for i:=1 to 20 do
help_page[i][0]:=#40;
end;
end;

procedure ask;
begin
writeln;
write('Enter Topic Number-');
readln(t_no);
write('Enter Page Number-');
readln(p_no);
writeln;
end;
{four topics}

Procedure writeline(hp:hlp_page;l:word);
begin
gotoxy(1,l);
writeln(hp[l]);
end;

procedure display_page(hp:hlp_page);
var i,s:word;
begin
for i:=1 to 20 do
writeline(hp,i);
end;

Procedure edit_line(var hl:hlp_page;cl,rw:word);
var s:string[40];r,c:word;
begin
{rw=1..20 , cl:=1..40}
repeat
s:=hl[rw];
s[0]:=#40;
gotoxy(cl,rw);
{enter=next line start
esc=prev line end
bkspc= non destuctive backward move}
ch:=readkey; {Press space to move forward destructively}
if ch<>enter then
   if ch<>esc then
      if ch<>bkspc then begin
      s[cl]:=ch;{length(s)=const=40}
      Hl[rw]:=s;
      write(ch);{echo the char at current x,y}
      cl:=cl+1;
      end
       else{bkspc}
       cl:=cl-1 {if cl=0 then cl:=40}
   else{esc}
   begin
   cl:=40;
   rw:=rw-1;{if rw=0 then rw:=20}
   end
 else{enter}
 begin
 rw:=rw+1;
 if rw<21 then cl:=1;
 end;

   if rw =  0 then rw:=20;
   if rw = 21 then if cl=40 then rw:=20 else rw:=1;
   if cl=0 then cl:=40;
   if cl=41 then cl:=1;
gotoxy(1,24);
r:=rw;c:=cl;
write('                                   ');
gotoxy(1,24);
write('Y=',r,' , X=',c);
{pascal's error here-
it modifies rw without any reason in write statement
maybe because cursor at y was at maximum value=24}
until ((ch=enter) and (rw=20) and (cl=40));
end;

procedure get_input(var hl:hlp_book_page;t,p:word);

var line,x_cur:word;{1..20}c:char;
begin
line:=1;x_cur:=1;
hl.topic_no:=t;
hl.page_no:=p;

repeat
clrscr;{start editor}
gotoxy(1,22);writeln('Press esc to edit previous, Enter for next line');
writeln('Press enter at y=20, x=40 to exit');

display_page(hl.help_page);

edit_line(hl.help_page,line,x_cur);
c:='1';
                {ask if editing is over,
                if not restore screen}
                clrscr;
                writeln('Press 0 if Editing is over..');
                c:=readkey;

  until c='0';
end;

procedure create;
var tpc,pg,t:word;
begin
assign(help_book,hlpfile);
{$i-}
rewrite(help_book);
{$i+}
if ioresult=0 then begin
write('Enter no. of topics to create -');
readln(t);
for tpc:=1 to t do
begin
pg:=0;
repeat
pg:=pg+1;
init_page(hl_pg);
writeln('Enter data for topic ',tpc,' Page ',pg);
writeln('Press a key to start..');ch:=readkey;
get_input(hl_pg,tpc,pg);
write(help_book,hl_pg);
writeln('Press 0 if no more pages are to be written');
ch:=readkey;
until ch='0';
end;{for}
close(help_book);
end
else
begin writeln('could not create a file, press a key..');ch:=readkey;end;
end;{proc}




Begin

repeat
clrscr;
writeln;
writeln('Enter option-');
writeln('1. Create New file ');
writeln('2. Exit');
ch:=readkey;
if ch='1' then begin
write('Enter File Name -');
readln(hlpfile);
if length(hlpfile)<>0 then create;
end;{if}

until ch='2';

End.