//rotate pyramid
#include <iostream.h>
#include <conio.h>
#include <graphics.h>
#include <math.h>

struct point3d{int x,y,z;};

inline void set_p3d(point3d& p,int x,int y,int z)
{
p.x=x;p.y=y;p.z=z;
}

inline point3d neg3d(point3d p)
{
p.x=-p.x;p.y=-p.y;p.z=-p.z;
return p;
}

inline void trans_3d(point3d& p,int x,int y,int z)
{
p.x+=x;p.y+=y;p.z+=z;
}
inline void trans_3d(point3d& p,point3d t)
{
p.x+=t.x;p.y+=t.y;p.z+=t.z;
}

void rot(int x,int y,/*int*/float deg,int &xnew,int& ynew)
{
//float dr=(22.0*deg)/(7.0*180.0);
//int xx=x,yy=y;//maybe self assign is prob
float dr=deg;
float c=cos(dr),s=sin(dr);
xnew=x*c-y*s;//(int)
ynew=x*s+y*c;
}

void rot3d(point3d p,point3d l1,point3d l2,int deg,point3d& pnew)
{
point3d tp,pt;
float rad=(22.0*(float)deg)/(7.0*180.0);
p.x=p.x-320;p.y=240-p.y;
tp=l2;pt=p;//screen->graph
l1.x=l1.x-320;l1.y=240-l1.y;
tp.x=tp.x-320;tp.y=240-tp.y;

trans_3d(tp,neg3d(l1));
trans_3d(pt,neg3d(l1));//pt.y=240-pt.y;
//trans_3d(pt,-320,0,0);pt.y=240-pt.y;
/*
rot(pt.y,pt.z,atan(tp.z/tp.y),pt.x,pt.y);//use atan2 instead later
rot(pt.z,pt.x,atan(-tp.x/sqrt(tp.z*tp.z+tp.y*tp.y)) ,pt.z,pt.x);
rot(pt.x,pt.y,rad,pt.x,pt.y);
rot(pt.z,pt.x,-atan(-tp.x/sqrt(tp.z*tp.z+tp.y*tp.y)) ,pt.z,pt.x);
rot(pt.y,pt.z,-atan(tp.z/tp.y),pt.x,pt.y);
*/
//rot(pt.y,pt.z,atan2(tp.z,tp.y),pt.y,pt.z);//use atan2 instead later
rot(pt.y,pt.z,atan2(tp.y,tp.z),pt.y,pt.z);//use atan2 instead later
rot(pt.z,pt.x,atan2(-tp.x,sqrt(tp.z*tp.z+tp.y*tp.y)) ,pt.z,pt.x);
rot(pt.x,pt.y,rad,pt.x,pt.y);
rot(pt.z,pt.x,-atan2(-tp.x,sqrt(tp.z*tp.z+tp.y*tp.y)) ,pt.z,pt.x);
rot(pt.y,pt.z,-atan2(tp.y,tp.z),pt.y,pt.z);
//rot(pt.y,pt.z,-atan2(tp.z,tp.y),pt.y,pt.z);//use atan2 instead later
trans_3d(pt,l1);
//trans_3d(pt,320,0,0);pt.y=240-pt.y;
pt.x=pt.x+320;pt.y=240-pt.y;
//graph->scrn
//l1.x=l1.x+320;l1.y=240-l1.y;
//tp.x=tp.x+320;tp.y=240-tp.y;
pnew=pt;
}

void drawtri(point3d p1,point3d p2,point3d p3)
{
int poly[8];
poly[0]=p1.x;
poly[2]=p2.x;
poly[4]=p3.x;
poly[6]=poly[0];
poly[1]=p1.y;
poly[3]=p2.y;
poly[5]=p3.y;
poly[7]=poly[1];
drawpoly(4,poly);
}

void drawpyramid(point3d p[4])
{
setcolor(3);
drawtri(p[0],p[1],p[2]);
setcolor(4);
drawtri(p[0],p[2],p[3]);
setcolor(7);
drawtri(p[0],p[1],p[3]);//123
}

void askpt3d(point3d& p)
{
cout<<"\nX=? ";cin>>p.x;p.x+=320;
cout<<"Y=? ";cin>>p.y;p.y=240-p.y;
cout<<"Z=? ";cin>>p.z;
}

void main()
{
point3d p[4],l[2],p2[4];
int x=0, y,z=50,c=13,angle;
initgraph(&x,&y,"c:\\tc\\bgi");
x=y=z;
set_p3d(p2[0],320+x,240-0,0);
set_p3d(p2[1],320+0,240-y,0);
set_p3d(p2[2],320+(-30),240-0,z);
set_p3d(p2[3],320+0,240-(-y),0);
while (c==13)
{
gotoxy(1,1);
cleardevice();
drawpyramid(p2);c=getch();c=13;
//tell
cout<<"\nPyramid rotation around a line, View on xy plane\n";
cout<<"Info: screen co-ordinates x=-320..319, y=-240..239\n";
//ask
cout<<"\nEnter 1st point of 3d line";
askpt3d(l[0]);
cout<<"\nEnter 2nd point of 3d line";
askpt3d(l[1]);
cout<<"\nEnter angle of rotation around line(degrees)?";cin>>angle;

//simple plane intersection to x,y,z axis type pyramid
set_p3d(p[0],320+x,240-0,0);
set_p3d(p[1],320+0,240-y,0);
set_p3d(p[2],320+0,240-0,z);
set_p3d(p[3],320+0,240-0,0);
//set_p3d(p[3],320+x,240+y,z);
cleardevice();
setcolor(7);
/*
line(320,0,320,479);
line(0,240,639,240);
setcolor(4);
*/
//
p[0]=p2[0];p[1]=p2[1];p[2]=p2[2];p[3]=p2[3];
//drawpyramid(p);
for (int i=0;i<4;i++)
rot3d(p[i],l[0],l[1],angle/*45*/,p[i]);

setcolor(7);
line(320,0,320,479);
line(0,240,639,240);

drawpyramid(p);
setcolor(6);line(l[0].x,l[0].y,l[1].x,l[1].y);
c=getch();
//c=getch();
}//while
closegraph();
}