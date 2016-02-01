//normalise
#include <iostream.h>
#include <conio.h>
#include <graphics.h>

struct win{ int x1,y1,x2,y2;};

void askwin(win& l)
{
cout<<"\nx1=? ";cin>>l.x1;l.x1+=320;
cout<<"y1=? ";cin>>l.y1;l.y1=240-l.y1;
cout<<"x2=? ";cin>>l.x2;l.x2+=320;
cout<<"y2=? ";cin>>l.y2;l.y2=240-l.y2;//origin->screen i.e graph->screen
}

void swap(int&t1,int&t2)
{
int t;//EXCHANGE
t=t1;
t1=t2;
t2=t;
}

inline int inwin(int x,int y,win w)
{
if ((x>=w.x1)&&(x<=w.x2)&&(y<=w.y2)&&(y>=w.y1)) return 1;else return 0;
}

void main()
{
win w1,w2,l,lw;
float sx,sy;
int c=13;
w1.x1=0;
initgraph(&w1.x1,&w1.x2,"c:\\tc\\bgi");
while(c==13)
{
gotoxy(1,1);
cleardevice();
//tell
cout<<"\nWindow to Viewport normalisation\n";
cout<<"Info: screen co-ordinates x=-320..319, y=-240..239\n";
//ask
cout<<"\nEnter window1 co-ordinates\n";
askwin(w1);
if((w1.x1==w1.x2)||(w1.y1==w1.y2))
{cout<<"\nx1<>x2 & y1<>y2 needed\npress any key";c=getch();continue;};
if(w1.x1>w1.x2)swap(w1.x1,w1.x2);
if(w1.y1>w1.y2)swap(w1.y1,w1.y2);

cout<<"\nEnter line in window co-ordinates\n";
askwin(lw);
if((lw.x1==lw.x2)||(lw.y1==lw.y2))
{cout<<"\nx1<>x2 & y1<>y2 needed\npress any key";c=getch();continue;};
if (!( (inwin(lw.x1,lw.y1,w1) && ( inwin(lw.x2,lw.y2,w1) ) ) ))
{cout<<"\nx1,x2,y1,y2 should be in window\npress any key";c=getch();continue;};

cout<<"\nEnter viewport co-ordinates\n";
askwin(w2);
if((w2.x1==w2.x2)||(w2.y1==w2.y2))
{cout<<"\nx1<>x2 & y1<>y2 needed\npress any key";c=getch();continue;};
/*
if(w1.x1>w1.x2)swap(w1.x1,w1.x2);
if(w1.y1>w1.y2)swap(w1.y1,w1.y2);
*/
if(w2.x1>w2.x2)swap(w2.x1,w2.x2);
if(w2.y1>w2.y2)swap(w2.y1,w2.y2);
//draw
cleardevice();gotoxy(1,1);cout<<"press enter to repeat";
//axis
setcolor(7);
rectangle(0,0,639,479);
line(0,240,639,240);
line(320,0,320,479);

setcolor(4);
rectangle(w1.x1,w1.y1,w1.x2,w1.y2);
rectangle(w2.x1,w2.y1,w2.x2,w2.y2);
setcolor(5);
line(lw.x1,lw.y1,lw.x2,lw.y2);
sx=(float)(w2.x2-w2.x1)/(w1.x2-w1.x1);
sy=(float)(w2.y2-w2.y1)/(w1.y2-w1.y1);

//
l.x1=w2.x1+(lw.x1-w1.x1)*sx;
l.y1=w2.y1+(lw.y1-w1.y1)*sy;

l.x2=w2.x1+(lw.x2-w1.x1)*sx;
l.y2=w2.y1+(lw.y2-w1.y1)*sy;
//

line(l.x1,l.y1,l.x2,l.y2);
c=getch();
}
closegraph();
}