//cube-perspective projected on xy plane i.e screen
#include <iostream.h>
#include <conio.h>
#include <graphics.h>
const h=230;
int size=10/*cube*/,dist=10,eye=10;//, cube[8];
float hh;
struct point3d{int x,y,z;};

int persp(int x,int z)
{
	 hh=(float) x*eye/(eye+dist+z);
	 return(hh);//x-hh*x
}

void pquad(point3d p1,point3d p2,point3d p3,point3d p4)
{
int poly[10];
poly[0]=320+persp(p1.x,p1.z);
poly[2]=320+persp(p2.x,p2.z);
poly[4]=320+persp(p3.x,p3.z);
poly[6]=320+persp(p4.x,p4.z);
poly[8]=poly[0];
poly[1]=240-persp(p1.y,p1.z);
poly[3]=240-persp(p2.y,p2.z);
poly[5]=240-persp(p3.y,p3.z);
poly[7]=240-persp(p4.y,p4.z);
poly[9]=poly[1];
drawpoly(5,poly);
}

inline void set_p3d(point3d& p,int x,int y,int z)
{
p.x=x;p.y=y;p.z=z;
}

inline void trans_3d(point3d& p,int x,int y,int z)
{
p.x+=x;p.y+=y;p.z+=z;
}

void makecuboid(point3d cube[8],point3d p1,point3d p2)
{
for (int i=0;i<7;i++) cube[i]=p1;
cube[7]=p2;
cube[1].x=p2.x;
cube[2].x=p2.x;
cube[2].y=p2.y;
cube[3].y=p2.y;
cube[4].y=p2.y;
cube[4].z=p2.z;
cube[5].z=p2.z;
cube[6].z=p2.z;
cube[6].x=p2.x;
}

void drawcube()
{
point3d cube[8],po,pi;
set_p3d(po,-size,-size,0);
set_p3d(pi,size,size,size);

makecuboid(cube,po,pi);

pquad(cube[0],cube[1],cube[2],cube[3]);
pquad(cube[0],cube[3],cube[4],cube[5]);
pquad(cube[6],cube[7],cube[2],cube[1]);
pquad(cube[4],cube[5],cube[6],cube[7]);
}

void main()
{
int gm=0,gd,c=0;

initgraph(&gm,&gd,"c:\\tc\\bgi");
cleardevice();
while(c!=27)
{
gotoxy(1,1);//resets cout
//tell
cout<<"\nCube Perspective view.\n";
cout<<"press.. a=size+,z=size-,d=dist+,s=dist-,+/-=eye to plane+/-,esc=exit";
c=getch();//else c=0;
	 setcolor(0);
	 drawcube();//delete old cube
switch (c){
case 'a': size+=10;break;
case 'z': size-=10;break;
case 'd': dist+=10;break;
case 's': dist-=10;break;
case '+': eye+=10;break;
case '-': eye-=10;break;
default:;
}//switch  {try, catch, throw in tvision help}

if((c!=27))
	{
	if (size<10)size=10;
	if (dist<10)dist=10;
	if (eye<10)eye=10;
	if (size>h)size=h;
	if (dist>h)dist=h;
	if (eye>h)eye=h;
	 gotoxy(1,22);cout<<"                             ";
	 gotoxy(1,22);cout<<"s: "<<size<<" "<<"d:"<<" "<<dist<<" "<<"e:"<<eye;
	 setcolor(4);
	 drawcube();
	}
}
closegraph();
}