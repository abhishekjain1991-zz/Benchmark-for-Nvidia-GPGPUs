#include<iostream>
#include"Complex.h"
#include <stdio.h>
#include <GL/glut.h>
#include <math.h>
#include<vector>
//#include <time.h>
//#include<Winbase.h> 
#include<windows.h>
#include<time.h>
using namespace std;
int StartX = -1;
int StartY = -1;
int EndX = -1;
int EndY = -1;
int nx, ny,c=0,updateRate=200,noofani=0;
double *arrx,*arry,*arrop;
clock_t t,t1;
//struct timeval tp;
typedef unsigned long DWORD;
//GLdouble realMax=-1.49436,realMin=-1.4944f,imagMax=0.347133696469,imagMin=0.347130303531,realInc,imagInc;
GLdouble realMax=1.0f,realMin=-2.0f,imagMax=1.8f,imagMin=-1.2f,realInc,imagInc;
void timer(int)
{noofani++;
if(noofani<5)
{
  // Adjust rotation angles as needed here
  // Then tell glut to redisplay
  glutPostRedisplay();
  // And reset tht timer
  glutTimerFunc(1000.0 / updateRate, timer, 0);
}
else if(noofani==5)
	{//cout << "done benchmarking " << (tp.tv_sec+tp.tv_usec/1000000.0) - startSec << " seconds" << endl;
DWORD points=GetTickCount();
t1=clock();
cout << "done benchmarking and points afer "<<noofani <<" iterations are "<< t1-t<< endl;
}
else
	return;
}
class memory
{public:
double minx,miny,maxx,maxy;
memory(double a, double b, double c, double d):minx(a),miny(b),maxx(c),maxy(d)
{}

};
vector<memory> m1;



// Called to draw scene

void RenderScene(void) {
    

  
    // Clear the window with current clearing color
    glClear(GL_COLOR_BUFFER_BIT);
    
	int arropcnt=0,cnt=0;


    realInc = (realMax - realMin) / (GLdouble)nx;
    imagInc = (imagMax - imagMin) / (GLdouble)ny;
    // Call only once for all remaining points
    
    for(int i=0;i<ny;i++)
	{
	arry[i]=imagMin+(i*imagInc);
	
		for(int j=0;j<nx;j++)
		{
			arrx[j]=realMin + (j*realInc);
			
		}
	}
	// cuda------------
	
	
	for(int i=0;i<ny;i++)
	{
		for( int j=0;j<nx;j++,arropcnt++)
		{
			 Complex c(arrx[j],arry[i]),op(0,0),temp(0,0);
		
			 cnt=0;
			
			 while(((op.real)*(op.real))+((op.imag)*(op.imag))<=4 && cnt<2000)
			 {
				 op=(temp*temp)+c;
				 temp=op;
				 cnt++;
			 }
			 arrop[arropcnt]=cnt;
			 

		}
	}

	//cuda ends------------
	arropcnt=0;
	glBegin(GL_POINTS);
	int r=0,g=0,b=0;
	for(int i=0;i<ny;i++)
	{
		for( int j=0;j<nx;j++,arropcnt++)
		{

			if(arrop[arropcnt]<2000 && arrop[arropcnt]>0)
			{r=arrop[arropcnt];
			r=r%16;
			switch (r)
				{case 1: glColor3f(25, 0, 26);
						break;
				case 2: glColor3f(9, 0, 47);
						break;

				case 3: glColor3f(4, 0, 73);
						break;
				case 4: glColor3f(0, 7, 100);
						break;
				case 5: glColor3f(0, 44, 138);
						break;
				case 6: glColor3f(0, 82, 177);
						break;

				case 7: glColor3f(0, 125, 209);
						break;
				case 8: glColor3f(0, 181, 229);
						break;
				case 9: glColor3f(0, 236, 248);
						break;
				case 10: glColor3f(241, 233, 0);
						break;

				case 11: glColor3f(248, 201, 0);
						break;
				case 12: glColor3f(255, 170, 0);
						break;
				case 13: glColor3f(204, 128, 0);
						break;
				case 14: glColor3f(153, 87, 0);
						break;

				case 15: glColor3f(106, 52, 0);
						break;
				case 0: glColor3f(66, 30, 0);
						break;
				default: glColor3f(66, 30, 0);break;
			}

				
				
				//glColor3f(r%256,r%128,r%32);
			}
			else
				glColor3f(0,0,0);

			 glVertex2d( j, i );
		}
	}
   /* for (x = 0, z.x = realMin; x < nx; x++, z.x += realInc) {
        for (y = 0, z.y = imagMin; y < ny; y++, z.y += imagInc) {


            //cnt=iterate(z,maxIter);

         
            t2=z;
            cnt = 0;

            while ((t2.x * t2.x + t2.y * t2.y <=4) && (cnt < maxIter)) {
                t.x=t2.x*t2.x-t2.y*t2.y;
                t.y=2*t2.x*t2.y;
                t2 = t;
                t2.x +=z.x;
                t2.y +=z.y;
                cnt++;
            }*/		
		
             
                 /* if(cnt<=255)
				glColor3f(256,256,256);
						   else
				glColor3f(0,0,0);                       
		*/
          

			
			   
                    
                  
                   
             //   glVertex2d(x , y );
           // }
           
        



    //}
   
    // Done drawing points
    glEnd();

    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    glOrtho( 0, nx, ny, 0, -nx, nx );

    glMatrixMode( GL_MODELVIEW );
   glLoadIdentity();
	//----selection
    if( StartX > 0 && StartY > 0 && EndX > 0 && EndY > 0 )
    {
        glLogicOp(GL_XOR);
        glEnable(GL_COLOR_LOGIC_OP);
        glColor3f(1.0, 1.0, 1.0);
        glLineWidth(1.0);
        glBegin(GL_LINE_LOOP);
		
        glVertex2i(StartX, StartY);
        glVertex2i(EndX, StartY);
        glVertex2i(EndX, EndY);
        glVertex2i(StartX, EndY);
		
        glEnd();
        glDisable(GL_COLOR_LOGIC_OP);
    }

    // Flush drawing commands
    glutSwapBuffers();
	
	realMax=realMax/1.8+0.25;
	imagMax=imagMax/1.8+0.25;
	realMin=realMin/1.8-0.25;
	imagMin=imagMin/1.8-0.25;
	//cout<<"i"<<endl;
}

// This function does any needed initialization on the rendering
// context.

void mouse( int button, int state, int x, int y )
{
    if( button == GLUT_LEFT && state == GLUT_DOWN )
    {
        StartX = x;
        StartY = y;
		
	
    }
    if( button == GLUT_LEFT && state == GLUT_UP )
    {
	if(StartX<EndX)
	{realMin=arrx[StartX];
	realMax=arrx[EndX];
	}
	else
	{realMin=arrx[EndX];
	realMax=arrx[StartX];
	}
	if(StartY<EndY)
	{
	imagMin=arry[StartY];
	imagMax=arry[EndY];
	}
	else
	{imagMin=arry[EndY];
	imagMax=arry[StartY];
	}

	m1.push_back(memory(realMin,imagMin,realMax,imagMax));
        StartX = -1;
        StartY = -1;
        EndX = -1;
        EndY = -1;
		glutPostRedisplay();
    }
}

void motion( int x, int y )
{
    EndX = x;
	cout<<StartX<<" "<<StartY<<" ";
	if(StartY-y>0 && StartX-EndX>0)
    EndY = StartY-(StartX-EndX);
	else if(StartY-y>0 && StartX-EndX<0)
    EndY = StartY+(StartX-EndX);
	else if(StartY-y<0 && StartX-EndX>0)
	EndY = StartY+(StartX-EndX);
	else
	EndY = StartY-(StartX-EndX);

	
	glutPostRedisplay();
	cout<<EndX<<" "<<EndY<<endl;
}



void Key(unsigned char key, int x, int y) {
	

	if(key=='b'|| key== 'B')
	{cout<<"pakda"<<endl;
	if(m1.size()>1)
		{imagMin=m1[m1.size()-2].miny;
		realMin=m1[m1.size()-2].minx;
		imagMax=m1[m1.size()-2].maxy;
		realMax=m1[m1.size()-2].maxx;
	}
		if(m1.size()!=1)
		m1.erase(m1.begin()+(m1.size()-1));
		
	}
	if(key=='q'|| key== 'Q')
		exit(0);


	 glutPostRedisplay();
    
}


void ChangeSize(int w, int h) {
    nx = w;
    ny = h;
    nx = w;
    ny = h;
	if(arrx!=0)
	{delete[] arrx;}
	if(arry!=0)
		delete[] arry;
	if(arrop!=0)
		delete[] arrop;
	
    arrx=new double [w];
	arry=new double [h];
	arrop=new double [w*h];
	if(m1.size()>0)
		m1.clear();
	
	m1.push_back(memory(realMin,imagMin,realMax,imagMax));
 
    // Set Viewport to window dimensions
    glViewport(0, 0, w, h);

    // Reset projection matrix stack
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    // Establish clipping volume (left, right, bottom, top, near, far)
    
        glOrtho(0,w,0,h,0,w);
    
    
        
    // Reset Model view matrix stack
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

int main(int argc, char* argv[]) {
	//GetSystemTime(&tp, 0);
	//double startSec = tp.tv_sec + tp.tv_usec/1000000.0;
	t=clock();
	glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(512, 512);
	glutCreateWindow("NON CUDA LAB");
    glutReshapeFunc(ChangeSize);
	glutKeyboardFunc(Key);
	glutMouseFunc( mouse );
    glutMotionFunc( motion );
    glutDisplayFunc(RenderScene);
	glutTimerFunc(1000.0 / updateRate, timer, 0);
    glutMainLoop();
	
	
	
    return 0;
}
