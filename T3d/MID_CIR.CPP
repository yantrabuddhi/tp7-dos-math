//midpoint circle

#include <iostream.h>
#include <conio.h>
#include <graphics.h>

void ppix(int x,int y,int col)
{
putpixel(x+320,240-y,col);//origin of plot is screen center
}

void pix8(int xc,int yc,int x,int y,int col)
{
ppix(xc+x,yc+y,col);
ppix(xc-x,yc+y,col);
ppix(xc+x,yc-y,col);
ppix(xc-x,yc-y,col);
ppix(xc+y,yc+x,col);
ppix(xc-y,yc+x,col);
ppix(xc+y,yc-x,col);
ppix(xc-y,yc-x,col);
}

void main()
{
int gm=0,gd,c=13,x=0,y=0,r;

initgraph(&gm,&gd,"c:\\tc\\bgi");
while(c==13)
{
gotoxy(1,1);//resets cout
cleardevice();
//tell
cout<<"\nMidpoint algo to Plot circle.\n";
cout<<"Info: screen co-ordinates x=-320..319, y=-240..239\n";
//ask
cout<<"\nEnter Center of circle:\nX:";cin>>x;
cout<<"Y:";cin>>y;
cout<<"Radius:";cin>>r;if(r<1)continue;
//circ
gotoxy(1,1);//resets cout
cleardevice();
cout<<"press enter to repeat";
//x   y   p
gd=0;gm=r;c=1-r;
pix8(x,y,gd,gm,3);//center x,y to be passed too
while(gd<gm)
{
gd++;//gd=gd+1=>gd++ or +=gd
if (c>=0) gm--;
if (c<0) c+=2*gd+1;else c+=2*(gd-gm)+1;
pix8(x,y,gd,gm,3);
}
c=getch();
}//while
closegraph();
}