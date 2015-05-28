#include<iostream>

#include <stdio.h>
#include <gl/glut.h>
#include <math.h>
#include<vector>
#include <cuda_runtime_api.h>
#include<windows.h>
#include<time.h>

class Complex1 
{
public:
    float   r;
    float   i;
    __device__ Complex1( float a, float b ) : r(a), i(b)  {}
    __device__ Complex1(const Complex1& x) : r(x.r), i(x.i) {}
    __device__ float magnitude2( void ) {
        return r * r + i * i;
    }
    __device__ Complex1 operator*(const Complex1& a) {
        return Complex1(r*a.r - i*a.i, i*a.r + r*a.i);
    }
    __device__ Complex1 operator+(const Complex1& a) {
        return Complex1(r+a.r, i+a.i);
    }
};
using namespace std;
int StartX = -1;
int StartY = -1;
int EndX = -1;
int EndY = -1;
clock_t t,t1;
int nx, ny,c=0,r,g=256,b=256,noofani=0,updateRate=200;
double *arrx,*arry,*arrop;
//GLdouble realMax=0.75f,realMin=-2.25f,imagMax=1.25f,imagMin=-1.25f,realInc,imagInc;
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

__global__ void kernal(double *dev_arrx,double *dev_arry, double *dev_arrop)
{

			int tid = threadIdx.x + blockIdx.x * blockDim.x; 
			
			int i = tid / 512;
			int j = tid % 512;

			Complex1 c(dev_arrx[j],dev_arry[i]),op(0,0),temp(0,0);
		    int cnt=0;
			
			 while(((op.r)*(op.r))+((op.i)*(op.i))<=4 && cnt<=2000)
			 {
				 op=(temp*temp)+c;
				 temp=op;
				 cnt++;
			 }
			 dev_arrop[tid]=cnt;
	
}


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
	}
	for(int j=0;j<nx;j++)
	{
			arrx[j]=realMin + (j*realInc);
			
	}


	double *dev_a, *dev_b, *dev_c;
	cudaMalloc( (void**)&dev_a, 512*sizeof(double) );
	cudaMalloc( (void**)&dev_b, 512*sizeof(double) );
	cudaMalloc( (void**)&dev_c, 512*512*sizeof(double) );

	cudaMemcpy( dev_a, arrx, 512 * sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy( dev_b, arry, 512 * sizeof(double), cudaMemcpyHostToDevice);

	kernal<<<8192,32>>>(dev_a, dev_b, dev_c);

	cudaMemcpy (arrop, dev_c, 512 * 512 * sizeof(double), cudaMemcpyDeviceToHost );


	
	arropcnt=0;
	glBegin(GL_POINTS);
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

				
				
				
			}
			else
				glColor3f(0,0,0);

			 glVertex2d( j, i );
		}
	}

   
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
}



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
	{
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
    nx = 512;
    ny = 512;
  
	if(arrx!=0)
	{delete[] arrx;}
	if(arry!=0)
		delete[] arry;
	if(arrop!=0)
		delete[] arrop;
	
    arrx=new double [512];
	arry=new double [512];
	arrop=new double [512*512];
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
    
	t=clock();
	glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(512, 512);
	glutCreateWindow("CUDA LAB");
    glutReshapeFunc(ChangeSize);
	glutKeyboardFunc(Key);
	glutMouseFunc( mouse );
    glutMotionFunc( motion );
    glutDisplayFunc(RenderScene);
	glutTimerFunc(1000.0 / updateRate, timer, 0);
    glutMainLoop();

    return 0;
}
