//clip
#include<iostream.h>
#include<conio.h>
#include<graphics.h>

struct line2d{int x1,y1,x2,y2;};

void ppix(int x,int y,int col)
{ //screen y-> origin y putpixel, not needed if conversion already done
putpixel(x+320,240-y,col);//origin of plot is screen center
}

void askwin(line2d& l)
{
cout<<"\nx1=? ";cin>>l.x1;l.x1+=320;
cout<<"y1=? ";cin>>l.y1;l.y1=240-l.y1;
cout<<"x2=? ";cin>>l.x2;l.x2+=320;
cout<<"y2=? ";cin>>l.y2;l.y2=240-l.y2;//origin->screen i.e graph->screen
}
void swap(int&t1,int&t2)
{
int t;
t=t1;
t1=t2;
t2=t;
}

void main()
{
line2d win,l;
int c=13,y;
float slope;
l.x1=0;
initgraph(&l.x1,&l.x2,"c:\\tc\\bgi");
while(c==13)
{
gotoxy(1,1);
cleardevice();
//tell;
cout<<"\nLine Clipping in Window\n";
cout<<"Info: screen co-ordinates x=-320..319, y=-240..239\n";
//ask
cout<<"\nEnter window co-ordinates\n";
askwin(win);
if((win.x1==win.x2)||(win.y1==win.y2))
{cout<<"\nx1<>x2 & y1<>y2 needed\npress any key";c=getch();continue;};

cout<<"\nEnter line co-ordinates\n";
askwin(l);
if((win.x1==win.x2)||(win.y1==win.y2))
{cout<<"\nx1<>x2 & y1<>y2 needed\npress any key";c=getch();continue;};

//draw
gotoxy(1,1);
cleardevice();
cout<<"press enter to repeat";
setcolor(7);
rectangle(0,0,639,479);
line(0,240,639,240);
line(320,0,320,479);
setcolor(4);
if(win.x1>win.x2)swap(win.x1,win.x2);
if(win.y1>win.y2)swap(win.y1,win.y2);
rectangle(win.x1,win.y1,win.x2,win.y2);
slope=(float)(l.y2-l.y1)/(l.x2-l.x1);
//loop works only if l.x2>l.x1
for (c=l.x1;c<=l.x2;c++)//for win only do win.x1 to win.x2
{
y=slope*(c-l.x1)+l.y1;
if ((c>=win.x1)&&(c<=win.x2)&&(y<=win.y2)&&(y>=win.y1))
putpixel(c,y,3);else putpixel(c,y,2);
}
c=getch();
}
closegraph();
}