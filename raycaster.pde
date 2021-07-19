float DR = radians(1); // 1 degree in radians

float px, py, pdx, pdy, pa; //player position

int mapX=8,mapY=8,mapS=64;

int map[]=
{
  1,1,1,1,1,1,1,1,
  1,0,1,0,0,0,0,1,
  1,0,1,0,0,0,0,1,
  1,0,1,0,0,0,0,1,
  1,0,0,0,0,0,0,1,
  1,0,0,0,0,1,0,1,
  1,0,0,0,0,0,0,1,
  1,1,1,1,1,1,1,1
};

float dist(float ax, float ay, float bx, float by, float ang) {
  return(sqrt((bx-ax)*(bx-ax) + (by-ay)*(by-ay)));
}

void setup() {
  size(1024, 512);
  px=300; py=300; pdx=cos(pa)*5; pdy=sin(pa)*5;
}

void drawMap2D() {
  int x, y, xo, yo;
  for (y=0; y<mapY; y++)
  {
    for (x=0; x<mapX; x++)
    {
      if (map[y*mapX+x]==1)
      {
        fill(255);
      } else {
        fill(0);
      }
      xo=x*mapS;
      yo=y*mapS;
      quad(xo+1,yo+1,
      xo+1,yo+mapS-1,
      xo+mapS-1,yo+mapS-1,
      xo+mapS-1,yo+1);
    }
  }
}

void raycast() {
  int r,mx,my,mp,dof;
  float rx,ry,ra,xo,yo,disT;
  ra=pa-DR*30; if(ra<0){ra+=TAU;} if(ra>TAU){ra-=TAU;}
  rx=0; //just testing this bc compiler error
  ry=0;
  xo=0;
  yo=0;
  disT=0;
  
  for(r=0;r<60;r++) {
    
    //check horizontal lines
    dof=0;
    float disH = 1000000, hx=px, hy=py;
    float aTan=-1/tan(ra);
    if(ra>PI){ry=(((int)py>>6)<<6)-0.0001; rx=(py-ry)*aTan+px; yo=-64; xo=-yo*aTan;} //looking up
    if(ra<PI){ry=(((int)py>>6)<<6)+64; rx=(py-ry)*aTan+px; yo=64; xo=-yo*aTan;} //looking down
    if(ra==0 || ra==PI){rx=px; ry=py; dof=8;} //looking straight left or right
    while(dof<8) //depth of field
    {
      mx=(int)(rx)>>6; my=(int)(ry)>>6; mp=my*mapX+mx;
      if(mp>0 && mp<mapX*mapY && map[mp]==1){hx=rx; hy=ry; disH=dist(px,py,hx,hy,ra); dof=8;} //hit wall
      else{rx+=xo; ry+=yo; dof+=1;} //next line
    }
    
    //check vertical lines
    dof=0;
    float disV = 1000000, vx=px, vy=py;
    float nTan=-tan(ra);
    if(ra>HALF_PI && ra<3*HALF_PI){rx=(((int)px>>6)<<6)-0.0001; ry=(px-rx)*nTan+py; xo=-64; yo=-xo*nTan;} //looking left
    if(ra<HALF_PI || ra>3*HALF_PI){rx=(((int)px>>6)<<6)+64; ry=(px-rx)*nTan+py; xo=64; yo=-xo*nTan;} //looking right
    if(ra==0 || ra==PI){rx=px; ry=py; dof=8;} //looking straight up or down
    while(dof<8) //depth of field
    {
      mx=(int)(rx)>>6; my=(int)(ry)>>6; mp=my*mapX+mx;
      if(mp>0 && mp<mapX*mapY && map[mp]==1){vx=rx; vy=ry; disV=dist(px,py,vx,vy,ra); dof=8;} //hit wall
      else{rx+=xo; ry+=yo; dof+=1;} //next line
    }
    if(disV<disH){rx=vx; ry=vy; disT=disV; stroke(255,0,0);}
    if(disH<disV){rx=hx; ry=hy; disT=disH; stroke(150,0,0);}
    strokeWeight(3); line(px, py, rx, ry);
    // 3D TIME BABEY
    float ca=pa-ra; if(ca<0){ca+=TAU;} if(ca>TAU){ca-=TAU;} disT=disT*cos(ca); //fisheye correction
    float lineH = (mapS*320)/disT; if(lineH>320){lineH=320;} //cap on line height
    float lineO = 160-lineH/2; //screen offset
    strokeWeight(9); strokeCap(SQUARE); line(r*8+530, lineO, r*8+530, lineH+lineO); noStroke();
    
    ra+=DR; if(ra<0){ra+=TAU;} if(ra>TAU){ra-=TAU;}
  }
}

void keyPressed() {
  if (key=='a') {pa-=0.1; if (pa<0) {pa+=2*PI;} pdx=cos(pa)*5; pdy=sin(pa)*5;}
  if (key=='d') {pa+=0.1; if (pa>2*PI) {pa-=2*PI;} pdx=cos(pa)*5; pdy=sin(pa)*5;}
  if (key=='s') {px-=pdx; py-=pdy;}
  if (key=='w') {px+=pdx; py+=pdy;}
}

void drawPlayer() {
  fill(255,255,0);
  noStroke();
  square(px,py,8);
  //drawing line of sight
  stroke(255,255,0);
  strokeWeight(3);
  line(px, py, px+pdx*5, py+pdy*5);
  noStroke();
}

void draw() {
  background(100);
  drawMap2D();
  drawPlayer();
  raycast();
}
