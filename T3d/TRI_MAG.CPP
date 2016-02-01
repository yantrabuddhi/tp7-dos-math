//magnify triangle around a fixed point
#include <iostream.h>
#include <conio.h>
#include <graphics.h>

struct point2d{int x,y;};
int t[8];

void fill_tri_buf(point2d *p)
{
int o,i=0;

for(o=0;o<6;)
{
t[o]=p[i].x;//[o/2]
t[o+1]=p[i].y;//[o/2+1]
o+=2;
i++;
}
t[6]=p[0].x;
t[7]=p[0].y;
}

void main()
{
//variables
int gd,gm,x,y,c=13;
float sc;

point2d p[3],r[3];

//init graph
gd=0;
initgraph(&gd,&gm,"c:\\tc\\bgi");//640*480*16 always
while(c==13)
{
gotoxy(1,1);
cleardevice();
//tell
cout<<"\nTriangle drawing & magnification program.\n";
cout<<"Info: screen co-ordinates x=-320..319, y=-240..239\n";

//ask
cout<<"\nEnter points for triangle vertex:\n";

for(gd=0;gd<3;gd++)
{
cout<<"\nVertex:"<<(gd+1)<<endl;
cout<<"X=? ";cin>>p[gd].x;
p[gd].x+=320;
cout<<"Y=? ";cin>>p[gd].y;
p[gd].y=240-p[gd].y;}
cout<<"\n\nMagnify around point?\nX=? ";cin>>x;x+=320;
cout<<"Y=? ";cin>>y;y=240-y;
cout<<"\nScale Factor? ";cin>>sc;

//scale
for(gd=0;gd<3;gd++)
{
r[gd].x=(p[gd].x-x)*sc+x;
r[gd].y=(p[gd].y-y)*sc+y;
}

//draw
cleardevice();
gotoxy(1,1);
cout<<"press enter to repeat";
setcolor(7);
line(320,0,320,479);
line(0,240,639,240);
rectangle(0,0,639,479);

setcolor(3);
fill_tri_buf(p);
drawpoly(4,t);

setcolor(4);
fill_tri_buf(r);
drawpoly(4,t);

c=getch();
}//while
closegraph();
}