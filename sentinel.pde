/*

    Copyright (C) 2020  Javier Marco Rubio
    email: jmarco2000@gmail.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import processing.vr.*;
import android.media.MediaPlayer;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.content.res.AssetFileDescriptor;
import android.content.Context;
import android.app.Activity;


VRCamera cam;

  

  

Sonido sonido;

//windows
//import queasycam.*;
//QueasyCam cam;



int cols;
int rows;
int tamcelda;

int tam;

float[][] alturas;
boolean[][] elevables;
boolean[][] baldosas;
int[][] absorbibles;  // 0: nada      1: arbol      2: bloque    3: bloque-arbol    4: bloque-bloque ...
int[][] robots;       // 0: nada       1:tus clones para trasladarte   2: malo pequeño     3: pedestal malo grande  4: pedestal y malo grande 

PShape mayaTerreno;
PShape mayaBaldosas;
PShape arbol;
PShape bloque;
PShape robot;
PShape piedraMalo;
PShape mayaRobotSuperMalo;
PShape mayaRobotMinion;

PImage iconoRobot;
PImage iconoCaja;
PImage iconoArbol;
PImage pantallaLevelUp;
PImage pantallaMenu;


Robot robotSuperMalo;
ArrayList<Robot> minions;



PVector apuntaBaldosa;

ArrayList<PVector> apuntaBaldosas;

//celda posicion camara
int celdaCamaraX;
int celdaCamaraY;
float camaraX;
float camaraY;
float camaraZ;


//paleta de colores
color colorFondo;
color colorBaldosa1;
color colorBaldosa2;
color colorSlope;
color colorWireSlope;
color colorApunta;
color colorPuntero;

//matriz del ojo
PMatrix3D eyeMat;


//apunta a algo????
boolean aBaldosa;
boolean aCaja;
boolean aRobot;

//energia
int energia;
boolean comienzoJuego;
boolean configuracion=true;

int tiempoNextLevel;

float fadeOver;

int dificultad=0;


/********************  SETUP ***************************/
void setup() {
  //inicializacion variables
  cols=49;
  rows=49;
  tamcelda=200;

  tam=tamcelda*cols;
  
  minions = new ArrayList<Robot>();
  apuntaBaldosa=new PVector(-1,-1);
  apuntaBaldosas=new ArrayList<PVector>();
  //paleta de colores
  colorFondo=color(0,18,103);
  colorBaldosa1=color(140,7,132);
  colorBaldosa2=color(200,223,140);
  colorSlope=color(153,247,222);
  colorWireSlope=color(57,130,140);
  colorApunta=color(0,255,0);
  colorPuntero=color(5,0,0);
  
  //matriz del ojo
  eyeMat = new PMatrix3D();
  //apunta a algo????
  aBaldosa=false;
  aCaja=false;
  aRobot=false;
  
  //energia
  energia=8;
  comienzoJuego=false;
  
  
  //para el fundido a negro
  fadeOver=0;
  
  //para pasar al siguiente nivel
  tiempoNextLevel=-1;
  
  //VR
  
  fullScreen(VR);
  cameraUp();
  rectMode(CENTER);
  cam = new VRCamera(this);
  cam.setNear(10);
  cam.setFar(10000);
  hint(ENABLE_STROKE_PERSPECTIVE);
  emissive(0,0,0);
 
  
  
  //Windows
  /*
  size(800,600,P3D);
   cam = new QueasyCam(this);
  cam.speed = 2;              // default is 3
  cam.sensitivity = 2;      // default is 2
 
 */
   
  arbol= loadShape("arboldepapa.obj");
  bloque= loadShape("piedradepapa.obj");
  robot=loadShape("robot.obj");
  piedraMalo=loadShape("piedramalodepapa.obj");
  mayaRobotSuperMalo=loadShape("supermalodepapa.obj");
  mayaRobotMinion=loadShape("miniondepapa.obj");
  
  iconoRobot = loadImage("icono_robot.png");
  iconoCaja = loadImage("icono_bloque.png");
  iconoArbol = loadImage("icono_arbol.png");
  pantallaLevelUp=loadImage("nextlevel.png");
  pantallaMenu=loadImage("menu.png");
  
  
  //sonido
  //sonido
  sonido=new Sonido(this);

  
  
 
 alturas = new float[cols+1][rows+1];
 baldosas = new boolean[cols+1][rows+1];
 elevables = new boolean[cols+1][rows+1];
 absorbibles = new int[cols+1][rows+1];
 robots = new int[cols+1][rows+1];
 //inicializa
   for (int y=0;y<rows+1; y++) {
     for (int x=0; x<cols+1; x++) {
       alturas[x][y]=0;
       elevables[x][y]=true;
       baldosas[x][y]=false;
       absorbibles[x][y]=0;
       robots[x][y]=0;
     }
   }
   
   creaNivel(1);
   creaNivel(2);
   creaNivel(3);
   creaNivel(4);
   creaNivel(5);
   creaNivel(6);
   creaNivel(7);
   creaNivel(8);
   creaBaldosas();
   inicializaCamara();  
   robotSuperMalo=new Robot(mayaRobotSuperMalo,0);   
   for(int i=0; i<dificultad; i++)  minions.add(new Robot(mayaRobotMinion,1));
   
   convierteAlturas();   
   plantaArboles();
   
   
   creaMayaTerreno();
   //convierteAlturaPedestalRobotMalo();
   creaMayaBaldosas();
   
   
   
  
   
}

void inicializaCamara() {
  int cx=-1; int cy=-1;
  int alto=0;
  while (cx==-1) {
        for (int y=1;y<rows; y++) {
             for (int x=1; x<cols; x++) {
               if ((baldosas[x][y]) && (alturas[x][y]==alto) && (vecinos(x,y,alto))) {cx=x; cy=y;}
             }
        }
        if (cx==-1) alto++;
  }
  
  celdaCamaraX=cx; celdaCamaraY=cy;
  robots[cx][cy]=1;
  camaraX=int(celdaCamaraX*(tamcelda)+(tamcelda/2));
  camaraY=int(alturas[celdaCamaraX][celdaCamaraY]*tamcelda+(tamcelda)*1.2)+1800;
  camaraZ=int(celdaCamaraY*(tamcelda)+(tamcelda/2));
}





boolean vecinos(int x, int y, int alto) {
 boolean v=false;
 if ((alturas[x+1][y]==alto) && (baldosas[x+1][y])) v=true;
 if ((alturas[x+1][y+1]==alto) && (baldosas[x+1][y+1])) v=true;
 if ((alturas[x+1][y-1]==alto) && (baldosas[x+1][y-1])) v=true;
 if ((alturas[x-1][y]==alto) && (baldosas[x-1][y])) v=true;
 if ((alturas[x-1][y+1]==alto) && (baldosas[x-1][y+1])) v=true;
 if ((alturas[x-1][y-1]==alto) && (baldosas[x-1][y-1])) v=true;
 if ((alturas[x][y+1]==alto) && (baldosas[x][y+1])) v=true;
 if ((alturas[x][y-1]==alto) && (baldosas[x][y-1])) v=true;
 
 return v;
}

void creaNivel(int nivel) {
    noiseSeed((long)random(1,10000));
       
     for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
         if ((elevables[x][y]==true) && (noise(x/3.0,y/3.0)<(0.2+1.0/float(nivel+1)))) {
           if (alturas[x][y]==(nivel-1)) alturas[x][y]=nivel; 
           if (alturas[x+1][y]==(nivel-1)) alturas[x+1][y]=nivel; 
           if (alturas[x][y+1]==(nivel-1)) alturas[x][y+1]=nivel; 
           if (alturas[x+1][y+1]==(nivel-1)) alturas[x+1][y+1]=nivel;
         } else {
           elevables[x][y]=false; 
         }
       }
     }
}

void convierteAlturas() {
  for (int y=0;y<rows+1; y++) {
       for (int x=0; x<cols+1; x++) {
         alturas[x][y]=alturas[x][y] * (tamcelda*0.9);           
       }
  }
}



void creaBaldosas() {
  for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
         if ((alturas[x][y]==alturas[x+1][y]) && (alturas[x][y]==alturas[x][y+1]) && (alturas[x][y]==alturas[x+1][y+1]))
           baldosas[x][y]=true;
       }
  }
}

void plantaArboles() {
  noiseSeed((long)random(1,10000));
  for (int y=1;y<rows; y++) {
       for (int x=1; x<cols; x++) {
         if (baldosas[x][y]) {
           if ((noise(x/2.0,y/2.0)>0.75) && (robots[x][y]==0)) absorbibles[x][y]=1;
         }
       }
  }
  
}

void plantaArbol() {
 boolean colocado=false;
 
   while (!colocado) {
      int ax=floor(random(0,cols));
      int ay=floor(random(0,rows));
      
      if ((baldosas[ax][ay]) && (absorbibles[ax][ay]==0) && (robots[ax][ay]==0) && (ax!=celdaCamaraX) && (ax!=celdaCamaraY)) {
         colocado=true;
         absorbibles[ax][ay]=1;
      }
      
   }
}


void creaMayaTerreno() {
  PShape tira;
  
  mayaTerreno = createShape(GROUP);
  mayaTerreno.beginShape();
  mayaTerreno.fill(colorSlope);
  mayaTerreno.stroke(colorWireSlope);
 
  for (int y=0;y<rows; y++) {   
   tira = createShape(); 
   tira.beginShape(TRIANGLES);
   tira.fill(160,160,255);
   tira.stroke(70,70,115);
   tira.strokeWeight(10);
   for (int x=0; x<cols; x++) {    
       
       tira.vertex(x*(tamcelda),alturas[x][y], y*(tamcelda));
       tira.vertex( x*(tamcelda),alturas[x][y+1], (y+1)*(tamcelda));
       tira.vertex( (x+1)*(tamcelda),alturas[x+1][y+1], (y+1)*tamcelda);
       
       tira.vertex(x*(tamcelda),alturas[x][y], y*(tamcelda));       
       tira.vertex( (x+1)*(tamcelda),alturas[x+1][y+1], (y+1)*(tamcelda));
       tira.vertex( (x+1)*(tamcelda),alturas[x+1][y], (y)*(tamcelda));
       
      
   }   
   tira.endShape();
   mayaTerreno.addChild(tira);
  } 

}


void creaMayaBaldosas() {
  color c1=colorBaldosa1;
  color c2=colorBaldosa2;
  
  mayaBaldosas = createShape();
  mayaBaldosas.beginShape(QUADS);
  
  mayaBaldosas.stroke(colorWireSlope);
  boolean c=false;
  for (int y=0;y<rows; y++) {      
   for (int x=0; x<cols; x++) {
     c=!c;
     if (baldosas[x][y]) {
       c1=color(red(colorBaldosa1)+x,green(colorBaldosa1), blue(colorBaldosa1)+y);
       c2=color(red(colorBaldosa2)+x,green(colorBaldosa2), blue(colorBaldosa2)+y);
       //if (c) mayaBaldosas.fill(c1); else mayaBaldosas.fill(c1);
       mayaBaldosas.fill(0,0,0);
       if (c) mayaBaldosas.emissive(c1); else mayaBaldosas.emissive(c2);
       int extra=0;
       if ((robotSuperMalo.baldosaX==x) && (robotSuperMalo.baldosaY==y)) extra=190; //aqui esta el malo pedestal
       mayaBaldosas.vertex(x*(tamcelda),alturas[x][y]+3+extra, y*(tamcelda));
       mayaBaldosas.vertex( x*(tamcelda),alturas[x][y+1]+3+extra, (y+1)*(tamcelda));     
       mayaBaldosas.vertex( (x+1)*(tamcelda),alturas[x+1][y+1]+3+extra, (y+1)*(tamcelda));
       mayaBaldosas.vertex( (x+1)*(tamcelda),alturas[x+1][y]+3+extra, (y)*(tamcelda));
     }
   }   
  } 
  mayaBaldosas.endShape();

}



void dibujaAbsorbibles() {
 for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
         int numBloque=floor(absorbibles[x][y]/2);
         for(int i=0; i<numBloque; i++) {
             pushMatrix(); 
             int extra=0;
             if ((robotSuperMalo.baldosaX==x) && (robotSuperMalo.baldosaY==y)) extra=190;
             translate(x*(tamcelda)+(tamcelda/2), alturas[x][y]+80*i+extra, y*(tamcelda)+(tamcelda/2));
             scale(100);
             shape(bloque, 0, 0);             
             popMatrix();
            
         }
         //hay arbol?
         if (absorbibles[x][y]%2==1) {
             pushMatrix(); 
             translate(x*(tamcelda)+(tamcelda/2), alturas[x][y]+80*numBloque, y*(tamcelda)+(tamcelda/2));
             scale(70);
             shape(arbol, 0, 0);
             popMatrix();                                                                                                         
         }
         //hay robot?
         if (robots[x][y]==1) {
            pushMatrix(); 
            int extra=0;
            if ((robotSuperMalo.baldosaX==x) && (robotSuperMalo.baldosaY==y)) extra=190;
             translate(x*(tamcelda)+(tamcelda/2), alturas[x][y]+80*numBloque+extra, y*(tamcelda)+(tamcelda/2));
             scale(135);
             shape(robot, 0, 0);
             popMatrix();
         }
         if (robots[x][y]==3) {
             pushMatrix(); 
             translate(x*(tamcelda)+(tamcelda/2), alturas[x][y]-190, y*(tamcelda)+(tamcelda/2));
             scale(100);
             shape(piedraMalo, 0, 0);
             popMatrix();
             
         }
         
         
        
       }
   }
}





void XCamara() {
  
  int destino=int(celdaCamaraX*(tamcelda)+(tamcelda/2));
  camaraX=lerp(camaraX, destino, 0.05);  
  
}

void YCamara() {
  int extra=0;
  if (robotSuperMalo!=null) {
  if ((celdaCamaraX==robotSuperMalo.baldosaX) && (celdaCamaraY==robotSuperMalo.baldosaY)) extra=190;
  }
  int destino=int(alturas[celdaCamaraX][celdaCamaraY]+(tamcelda)*1.35)+extra; //alturabase
  int numbloques=floor(absorbibles[celdaCamaraX][celdaCamaraY]/2);
  destino=destino+numbloques*80;
  
  camaraY=lerp(camaraY, destino, 0.05);
  
  
}
void ZCamara() {
  int destino=int( celdaCamaraY*(tamcelda)+(tamcelda/2));
  camaraZ=lerp(camaraZ, destino, 0.05);
  
}







boolean ciclo=false;
float orientacion;

//VR

void stereo() { 
 ciclo=!ciclo;
  if (ciclo) {
   XCamara(); YCamara(); ZCamara(); 
   getEyeMatrix(eyeMat);
   
   orientacion= acos(eyeMat.m00);
   if (eyeMat.m02<0) orientacion=-orientacion; 
   //println(degrees(orientacion));
  
  }
 if (!ciclo) 
   cam.setPosition(camaraX-25*cos(orientacion), camaraY, camaraZ-25*sin(orientacion));
   else
   cam.setPosition(camaraX+25*cos(orientacion), camaraY, camaraZ+25*sin(orientacion));
   
  
}



void pintaBaldosaApunta() {
       //println(" pinta baldosa ciclo=", ciclo, "      abaldosa=", aBaldosa);
       if (aBaldosa) {         
              fill(0,255,0);
              noStroke();
              pushMatrix();
              int extra=0;
              if ((robotSuperMalo.baldosaX==apuntaBaldosa.x) && (robotSuperMalo.baldosaY==apuntaBaldosa.y)) extra=190; //aqui esta el malo pedestal
              
              translate(apuntaBaldosa.x*(tamcelda), alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]+4+extra, apuntaBaldosa.y*(tamcelda));
              emissive(0,0,0);
              beginShape();
              vertex(0,0,0);
              vertex(0,0,tamcelda);
              vertex(tamcelda,0,tamcelda);
              vertex(tamcelda,0,0);
              endShape(CLOSE);
              
               popMatrix();
       }
}

void pintaCajaApunta() {
   if (aCaja) {
        color pink = color(55, 172, 104);
        pushMatrix();   
        int extra=0;
        if ((robotSuperMalo.baldosaX==cajaApuntada.x) && (robotSuperMalo.baldosaY==cajaApuntada.y)) extra=190;
        translate(cajaApuntada.x*(tamcelda)+(tamcelda/2), alturas[int(cajaApuntada.x)][int(cajaApuntada.y)]+4+extra, cajaApuntada.y*(tamcelda)+(tamcelda/2));
        fill (pink, 155);
        noStroke();
        box(200,200,200);
        popMatrix();
   }
}

void pintaRobotApunta() {
   if (aRobot) {
        color pink = color(55, 172, 104);
        int numBloque=floor(absorbibles[int(robotApuntado.x)][int(robotApuntado.y)]/2);
        pushMatrix();  
        int extra=0;
        if ((robotSuperMalo.baldosaX==robotApuntado.x) && (robotSuperMalo.baldosaY==robotApuntado.y)) extra=190;
        translate(robotApuntado.x*(tamcelda)+(tamcelda/2), alturas[int(robotApuntado.x)][int(robotApuntado.y)]+numBloque*80+extra, robotApuntado.y*(tamcelda)+(tamcelda/2));
        fill (pink, 155);
        noStroke();
        box(100,400,100);
        popMatrix();
   }
}



// POR COLORES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
color colorPuntoMira;
/*
void colorPuntoMira() {
 loadPixels();
 int x=width/2+int(width*0.12);
 int y=height/2-int(height*0.05);
 colorPuntoMira=pixels[y*width+x];
 println(" color =", red(colorPuntoMira), green(colorPuntoMira), blue(colorPuntoMira));
  
}
*/





void checkBaldosas() {
  //println(" entro check Baldosa ciclo", ciclo);
  colorPuntoMira();
  apuntaBaldosa.x=-1; apuntaBaldosa.y=-1; aBaldosa=false;
  float idColor=green(colorPuntoMira);
  float basex; float basey;
  if ((idColor==green(colorBaldosa1)) || (idColor==green(colorBaldosa2))) {  //esta apuntando a unabaldosa
  //println("SI APUNTA A BALDOSA");
        if (idColor==green(colorBaldosa1)) {
          basex=red(colorBaldosa1);
          basey=blue(colorBaldosa1);
        } else {
          basex=red(colorBaldosa2);
          basey=blue(colorBaldosa2);
        }
        
        
        float apuntaX=red(colorPuntoMira)-basex;
        float apuntaY=blue(colorPuntoMira)-basey;
        //println("apunta x=", apuntaX, "    y=",apuntaY);
       
        if ((apuntaX>=0) && (apuntaX<cols) && (apuntaY>=0) && (apuntaY<rows)) {
          apuntaBaldosa.x=apuntaX; 
          apuntaBaldosa.y=apuntaY;
          aBaldosa=true;
          };
  }
  if ((apuntaBaldosa.x==celdaCamaraX) && (apuntaBaldosa.y==celdaCamaraY)) {
    apuntaBaldosa.x=-1;
    apuntaBaldosa.y=-1;
    aBaldosa=false;
  }
  
}
/*
PVector cajaApuntada=new PVector(-1,-1);
void tocaCaja() {
  cajaApuntada.x=-1; cajaApuntada.y=-1;
  aCaja=false;
  println("entra caja apuntada");
  float mindist=9999;
  for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
         int numBloque=floor(absorbibles[x][y]/2);
         
         for(int i=0; i<numBloque; i++) {
             
             float bx=x*tamcelda + (tamcelda/2);
             float bz=y*tamcelda + (tamcelda/2);
             float by=alturas[x][y]+80*i+(tamcelda/2);
             //punto al lado
             float bx2=x*tamcelda ;
             float bz2=y*tamcelda ;
             float by2=alturas[x][y]+80*i+(tamcelda/2);
             
             float sx=screenX(bx,by,bz);
             float sy=screenY(bx,by,bz);
             //punto al lado en pantalla
             float sx2=screenX(bx2,by2,bz2);
             float sy2=screenY(bx2,by2,bz2);
             println(" pantalla w=", width, "   h=", height);
             println("sx=", sx, "    sy=", sy);
             //estan dentro de pantalla?
             if ((sx>0) && (sx<width) && (sy>0) && (sy<height)) {
                 float radio=dist(sx,sy,sx2,sy2)*6;
                 
                 
                 float d=dist(0.5*width+int(width*0.12), 0.5*height-int(height*0.05), sx, sy);
                 
                  
                 if ((d<(width/3)) && (d<mindist)) {
                   
                   mindist=d;
                   cajaApuntada.x=x; cajaApuntada.y=y;
                   aCaja=true;
                 }
             }
          
         }
       }
  }
  
  
}
*/

/*

void robotsAbsorven() {
  
  for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
           if ((celdaCamaraX!=x) && (celdaCamaraY!=y)) { 
              if (robots[x][y]==1) { //hay un robot abandonado. chupalo
                  
                 if  (robotSuperMalo.baldosaVisible(x,y)) { //lo ve, a chupar!
                    robotSuperMalo.chupando=true; //esta chupando
                   
                    robots[x][y]=0;
                    absorbibles[x][y]+=2;
                    plantaArbol();
                 } else robotSuperMalo.chupando=false;
              } else if (absorbibles[x][y]>1)  {
                                    
                  if  (robotSuperMalo.baldosaVisible(x,y)) { //lo ve, a chupar!
                    robotSuperMalo.chupando=true; //esta chupando
                    
                    absorbibles[x][y]--;
                    plantaArbol();
                  }  else robotSuperMalo.chupando=false;
              }
           }
       }
  }

}
*/

int estadoVisto() {
  int e=0;
  if (robotSuperMalo.estado==2) return 2;
  if (robotSuperMalo.estado==1) e=1;
  
  for (int i = 0; i < minions.size(); i++) {
    Robot part = minions.get(i);
    if (part.estado==2) return 2;
    if (part.estado==1) e=1;
  }

  
 return e; 
}

void dibujaInterface() {
 
 eye();
 emissive(0,0,0);
 pushMatrix();
 
 stroke(0,0,0);
 strokeWeight(1);
 if (estadoVisto()==0) fill(0,0,0,0); else if (estadoVisto()==1) fill(200,200,0,150); else if (estadoVisto()==2) fill(255,0,0,150); 

 
 translate(-40,40,100);
 
 ellipse(0,0,10,10);
 dibujaEnergia();
 popMatrix(); 
 
 //ha muerto?
         
         if (energia<0) {
           if (fadeOver==0) sonido.gameover();
           noStroke();
           fill(0,0,0,round(fadeOver));
           fadeOver=fadeOver+1;
           
           pushMatrix();
           translate(0,0,100);
           rect(0,0,width,height);
           
           popMatrix();
           if (fadeOver>254) {dificultad=0;configuracion=true; pantallaConfiguracion=0; setup();}
         }
         
         //ha ganado
         if ((celdaCamaraX==robotSuperMalo.baldosaX) && (celdaCamaraY==robotSuperMalo.baldosaY)) {
           
             pushMatrix();
             
             translate(-60,45,100);
             scale(1,-1);
             emissive(255,255,255);
             image(pantallaLevelUp,0,0,100,100);
             popMatrix();
             if (tiempoNextLevel<0) {
               sonido.mal();
               tiempoNextLevel=millis()+5000;
             } else {
              if (tiempoNextLevel<millis()) {dificultad++; setup();}
               
             }
             
           
         }
}

void dibujaEnergia() {
  translate(15,-5,0);
  emissive(255,255,255);
  int numRobots=energia/3;
 
  for (int i=0;i<numRobots; i++) {
   translate(10,0,0);
   
   image(iconoRobot, 0,0);
  }
  int numCajas=(energia-numRobots*3) / 2;
  if (numCajas==1) {
    translate(10,0,0);
    image(iconoCaja,0,0);
  }
  int numArboles=energia - numRobots*3 - numCajas*2;
  if (numArboles==1) {
    translate(10,0,0);
    image(iconoArbol,0,0);
  }
   
  emissive(0,0,0);
}








void luces() {
  ambientLight(125, 125, 125); 
  directionalLight(235, 235, 235, 0.6, 1, -1);
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);
}





void calculate() {
 
  

}

//para calcular intersecciones con objetos

PMatrix3D objMat = new PMatrix3D();
PVector vcam = new PVector();
PVector dir = new PVector(); 
PVector front = new PVector(); 
PVector objCam = new PVector(); 
PVector objFront = new PVector();
PVector objDir = new PVector();
float boxSize = 190;
PVector boxMin = new PVector(-boxSize/2, -boxSize/2, -boxSize/2);
PVector boxMax = new PVector(+boxSize/2, +boxSize/2, +boxSize/2);
PVector hit = new PVector();


void vectoresCamara() {
   getEyeMatrix(eyeMat);
   vcam.set(eyeMat.m03, eyeMat.m13, eyeMat.m23);
   dir.set(eyeMat.m02, eyeMat.m12, eyeMat.m22);
   PVector.add(vcam, dir, front); 
}

PVector cajaApuntada=new PVector(-1,-1);
void tocaCaja() {
   
  cajaApuntada.x=-1; cajaApuntada.y=-1;
  aCaja=false;
  
  
  for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
         if (!((x==celdaCamaraX) && (y==celdaCamaraY))) {
               int numBloque=floor(absorbibles[x][y]/2);
               
               for(int i=0; i<numBloque; i++) {
                   //calculamos la coordenada de la caja
                   
                   int extra=0;
                   if ((robotSuperMalo.baldosaX==x) && (robotSuperMalo.baldosaY==y)) extra=190; //aqui esta el malo pedestal
                   
                   float bx=x*tamcelda + (tamcelda/2);
                   float bz=y*tamcelda + (tamcelda/2);
                   float by=alturas[x][y]+80*i+(tamcelda/2)+extra;
                   pushMatrix();
                   translate(bx, by, bz);
                   getObjectMatrix(objMat);
                   objMat.mult(vcam, objCam);
                   objMat.mult(front, objFront);
                   PVector.sub(objFront, objCam, objDir);
                   boolean res = intersectsLine(objCam, objDir, boxMin, boxMax, 0, tam, hit);
                             
                   popMatrix();
                   if (res)  {
                         
                         cajaApuntada.x=x; cajaApuntada.y=y;
                         aCaja=true;
                   }
               }
         }
       }
  }
}
    
PVector robotApuntado=new PVector(-1,-1);
void tocaRobot() {
  robotApuntado.x=-1; robotApuntado.y=-1;
  aRobot=false;
  
  
  for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
         if (!((x==celdaCamaraX) && (y==celdaCamaraY))) {
               if (robots[x][y]==1) {
                   int numBloque=floor(absorbibles[x][y]/2);
                   int extra=0;
                   if ((robotSuperMalo.baldosaX==x) && (robotSuperMalo.baldosaY==y)) extra=190; //aqui esta el malo pedestal
                   float bx=x*tamcelda + (tamcelda/2);
                   float bz=y*tamcelda + (tamcelda/2);
                   float by=alturas[x][y]+80*numBloque+(tamcelda/2)+extra;
                   
                   pushMatrix();
                   translate(bx, by, bz);
                   getObjectMatrix(objMat);
                   objMat.mult(vcam, objCam);
                   objMat.mult(front, objFront);
                   PVector.sub(objFront, objCam, objDir);
                   boolean res = intersectsLine(objCam, objDir, boxMin, boxMax, 0, tam, hit);
                             
                   popMatrix();
                   if (res)  {                         
                         robotApuntado.x=x; robotApuntado.y=y;
                         aRobot=true;
                   }
               }
         }
       }
  }
}
  
             
void puntoMira() {
 color pink = color(55, 172, 104);
 eye();
 stroke(pink, 100);
 strokeWeight(4);
 
 point(0,0,100);
 
 strokeWeight(1);
}

float correccionX=0.12;
float correccionY=-0.05;

void colorPuntoMira() {
 
 int x=int(pixelWidth*correccionX);
 int y=int(pixelHeight*correccionY);
 colorPuntoMira=get(x,y);
 println(" color =", red(colorPuntoMira), green(colorPuntoMira), blue(colorPuntoMira));
  
}
             
void centroMasas() {
    int mediaX=0;
    int mediaY=0;
    int contador=0;
    loadPixels();
    for (int y = pixelHeight/2 - pixelHeight/4 ; y<pixelHeight/2 + pixelHeight/4; y++) {
        for (int x = pixelWidth/2 - pixelWidth/4; x < pixelWidth/2 + pixelWidth/4; x++) {
          color c=pixels[y*pixelWidth+x];
          
          if (red(c)==255) {
            mediaX=mediaX+x;
            mediaY=mediaY+y;
            contador++;
          }
          
        }
    }
    updatePixels();
    if (contador>0) {
      mediaX=mediaX/contador;
      mediaY=mediaY/contador;
      float realX=float(mediaX)/float(pixelWidth);
      float realY=float(mediaY)/float(pixelHeight);
      println("centro masas x=", realX, "    y=", realY);
      if (disparoCalibracion) {
        correccionX=realX;
        correccionY=realY;
        calibracion=false;
        disparoCalibracion=false;
        pantallaConfiguracion=0;
        
      }
    }
}
                 

boolean calibracion=false;
boolean disparoCalibracion=false;
void draw() { 
   stereo();         
   smooth();
 if (configuracion) {
   dibujaConfiguracion();
 } else { 
        
        
         
         background (colorFondo);
        
          luces();
         
        //strokeWeight(937);
         shape(mayaTerreno);
         strokeWeight(0); 
         shape(mayaBaldosas);
         dibujaAbsorbibles();
         robotSuperMalo.dibuja();
         for (int i = 0; i < minions.size(); i++) {
                  Robot part = minions.get(i);
                  part.dibuja();
         }
            
            if (!ciclo) {   
            checkBaldosas(); 
            if (comienzoJuego) {
                  if (robotSuperMalo.turno()) {
                    if (robotSuperMalo.vivo) {
                      robotSuperMalo.vista();  
                      robotSuperMalo.absorve();
                      robotSuperMalo.mover();
                    }
                  }
                  
                  for (int i = 0; i < minions.size(); i++) {
                        Robot part = minions.get(i);
                        if (part.turno()) {
                          if (part.vivo) {
                            part.vista();  
                            part.absorve();
                            part.mover();
                          }
                        }
                  }
            }
            
            
            
            
            
            
          }
          //estas mirando a una camara o un robot
          vectoresCamara();
          tocaCaja();
          tocaRobot();
          
         pintaBaldosaApunta();
         pintaCajaApunta();
         pintaRobotApunta();
        
        
           
        
        
         
          //estos siempre lo ultimo! tiene un EYE!!!!!
          puntoMira(); //recuperar la bonita o eliminarla
          //puntoMiraMalo();
        
         dibujaInterface();
         
         
 }
 


}

int pantallaConfiguracion=0; 
void dibujaConfiguracion() {


 switch (pantallaConfiguracion) {
   case 0:
      background (colorFondo);
  
      eye();
       pushMatrix();
             
             translate(-70,60,100);
             scale(1,-1);
             emissive(255,255,255);
             image(pantallaMenu,0,0,135,135);
       popMatrix();
       
       strokeWeight(1);
       pushMatrix();
       translate(-50,50,100);
         textSize(13);
         fill(0,0,55);
         
         textSize(4);
         text("v 1.0 ",0,-7);
         text("This program comes with ABSOLUTELY NO WARRANTY",0,-12);
         text("This is free software, and you are welcome to redistribute it",0,-17);
         text("under certain conditions",0,-22);
         text("email: jmarco2000@gmail.com",0,-27);
         
         
        popMatrix();
    break;
    
    case 1:
       background (colorFondo);
  
       eye();
       strokeWeight(1);
       pushMatrix();
       translate(-50,20,100);
       textSize(13);
       fill(255,255,255);
       text("press key for",0,0);
       text("build box",0,-20);
       popMatrix();
    break;
    case 2:
       background (colorFondo);
  
       eye();
       strokeWeight(1);
       pushMatrix();
       translate(-50,20,100);
       textSize(13);
       fill(255,255,255);
       text("press key for",0,0);
       text("build robot",0,-20);
       popMatrix();
    break;
    case 3:
       background (colorFondo);
  
       eye();
       strokeWeight(1);
       pushMatrix();
       translate(-50,20,100);
       textSize(13);
       fill(255,255,255);
       text("press key for",0,0);
       text("absorb",0,-20);
       popMatrix();
    break;
    case 4:
       background (colorFondo);
  
       eye();
       strokeWeight(1);
       pushMatrix();
       translate(-50,20,100);
       textSize(13);
       fill(255,255,255);
       text("press key for",0,0);
       text("translate",0,-20);
       popMatrix();
    break; 
    case 5:
       
       background (0);
       luces();
       emissive(255,255,255);
       fill(255,255,255);
       pushMatrix();
       translate(camaraX,camaraY,camaraZ+800);
       strokeWeight(0); 
       stroke(255,255,255);
       sphere(40);
       popMatrix();
       pushMatrix();
       translate(camaraX,camaraY,camaraZ-800);
       strokeWeight(0); 
       stroke(255,255,255);
       sphere(40);
       popMatrix();
       pushMatrix();
       translate(camaraX+800,camaraY,camaraZ);
       strokeWeight(0); 
       stroke(255,255,255);
       sphere(40);
       popMatrix();
       pushMatrix();
       translate(camaraX-800,camaraY,camaraZ);
       strokeWeight(0); 
       stroke(255,255,255);
       sphere(40);
       popMatrix();
       
       //aqui calcular centro de masas
       if (!ciclo) centroMasas();
       
       //estos siempre lo ultimo! tiene un EYE!!!!!
       puntoMira();
       
       strokeWeight(1);
       pushMatrix();
       translate(-50,50,100);
       textSize(7);
       fill(0,255,255);
       stroke(0,255,255);
       text("look for the white circle. ",0,0);
       translate(0,-7,0);
       text("center aim point on circle",0,0);
       translate(0,-7,0);
       text("and press any key",0,0);
       popMatrix();
    break;
  
 }
}

void keyPressed() {
  if (!configuracion) teclasJuego();
  if ((configuracion) && (pantallaConfiguracion>0)) teclasConfiguracion();
}

void teclasConfiguracion() {
  sonido.mal();
  if (calibracion)  disparoCalibracion=true;
  
  switch (pantallaConfiguracion) {
     
     case 1: //construye caja
         K_caja=keyCode;
         pantallaConfiguracion++;
     break;
     case 2: //construye robot
         K_robot=keyCode;
         pantallaConfiguracion++;
     break;
     case 3: //absorber
         K_absorve=keyCode;
         pantallaConfiguracion++;
     break;
     case 4: //traslado
         K_traslado=keyCode;
         pantallaConfiguracion=5;
         calibracion=true;
     break;
  }
}

int K_arbol=0;
int K_caja=102;
int K_robot=103;
int K_absorve=20;
int K_traslado=19;

void teclasJuego() {
  // O: 102
  //Back: 103
  // A: 105
  // B: 23
  // C: 104
  // D: 4 escape
  // esc 4
  // M: 0
  // select: 85
  // up: 19
  // down: 20
  // left: 
  //right: 
 println("tecla=",keyCode); 
 

 
    
      if (keyCode==K_arbol) { //A arbol
           comienzoJuego=true;
           if (energia>0) { 
               if (aBaldosa) {
                     if  ((absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]%2==0) && 
                           (camaraY>alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]) &&
                              (robots[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]==0)) {
                                   //condiciones para poder poner un arbol, que no haya nada, o un bloque (sin robot)
                                   absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]++;
                                   energia--;  
                                   sonido.caja();
                            }
                                   
               } else if (aCaja) {
                  //o bien que haya uno o varios bloques sin robot
                          if (robots[int(cajaApuntada.x)][int(cajaApuntada.y)]==0) {
                               absorbibles[int(cajaApuntada.x)][int(cajaApuntada.y)]++;
                               energia--;  
                               sonido.caja();
                          }
              } else sonido.mal();
           } else sonido.mal();
      }
      if (keyCode==K_robot) { //back  robot  
          comienzoJuego=true;
          if (energia>2) {  
              if (aBaldosa) {
                 if  ((absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]%2==0) && 
                       (camaraY>alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]) &&
                          ((robots[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]==0) || (robots[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]==3))) { 
                               //condiciones para poder poner un arbol, que no haya nada, o un bloque (sin robot)  
                       robots[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]=1;
                       energia-=3;
                       sonido.caja();
                 }
              } else if (aCaja) {
                  //o bien que haya uno o varios bloques sin robot
                          if (robots[int(cajaApuntada.x)][int(cajaApuntada.y)]==0) {
                               robots[int(cajaApuntada.x)][int(cajaApuntada.y)]=1;
                               energia-=3;   
                               sonido.caja();
                          }
              } else sonido.mal();
          }
      }
       if (keyCode==K_caja) { //o  bloque  
         comienzoJuego=true;
         if (energia>1) {
            if (aCaja)  { 
                          //o bien que haya uno o varios bloques sin robot
                          if (robots[int(cajaApuntada.x)][int(cajaApuntada.y)]==0) {
                            absorbibles[int(cajaApuntada.x)][int(cajaApuntada.y)]=absorbibles[int(cajaApuntada.x)][int(cajaApuntada.y)]+2;
                            energia-=2;
                            sonido.caja();
                          }
            } else if (aBaldosa) {
                   if  ((absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]==0) && 
                         (camaraY>alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]) &&
                            (robots[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]==0)) { 
                              //condiciones para poder poner un arbol, que no haya nada,                 
                            absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]=absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]+2;
                            energia-=2;
                            sonido.caja();
                            }
                    
              
                    } else sonido.mal();
         } else sonido.mal();
       
       }
      if (keyCode==K_traslado) { //UP traslado
         if (aRobot) {
             if (robots[int(robotApuntado.x)][int(robotApuntado.y)]==1) {           
                         celdaCamaraX=int(robotApuntado.x); celdaCamaraY=int(robotApuntado.y);
                         sonido.viaje();
             } else sonido.mal();
         } else sonido.mal();
      }
      if (keyCode==K_absorve) { //down absorve
        comienzoJuego=true;
        if (aRobot) {
          if ((robots[int(robotApuntado.x)][int(robotApuntado.y)]==1) ) {           
                         robots[int(robotApuntado.x)][int(robotApuntado.y)]=0; 
                         energia+=3;
                         sonido.absorve();
             }
        } else if (aCaja) {
          absorbibles[int(cajaApuntada.x)][int(cajaApuntada.y)]-=2;
          energia+=2;
          sonido.absorve();
        } 
        if (aBaldosa) {
            if ((absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]==1) && (camaraY>alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)])) {
                  absorbibles[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]=0;
                  energia+=1;
                  sonido.absorve();
            }
            if ((robotSuperMalo.vivo) && (robotSuperMalo.baldosaX==apuntaBaldosa.x) && (robotSuperMalo.baldosaY==apuntaBaldosa.y) && (camaraY>alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)]+190)) {
              //chupa al supermalo
              robotSuperMalo.vivo=false;
              robots[robotSuperMalo.baldosaX][robotSuperMalo.baldosaY]=3;
              energia+=3;
              sonido.absorve();
            }
            
            for (int i = 0; i < minions.size(); i++) {
                  Robot part = minions.get(i);
                  if ((part.vivo) && (part.baldosaX==apuntaBaldosa.x) && (part.baldosaY==apuntaBaldosa.y) && (camaraY>alturas[int(apuntaBaldosa.x)][int(apuntaBaldosa.y)])) {
                    //chupa al minion
                    part.vivo=false;
                    robots[part.baldosaX][part.baldosaY]=0;
                    energia+=3;
                    sonido.absorve();
                  }
            }
            
            
            
        } else sonido.mal();
       
          
      }
      
       
     
 }
 
 
 boolean intersectsLine(PVector orig, PVector dir, 
  PVector minPos, PVector maxPos, float minDist, float maxDist, PVector hit) {
  PVector bbox;
  PVector invDir = new PVector(1/dir.x, 1/dir.y, 1/dir.z);

  boolean signDirX = invDir.x < 0;
  boolean signDirY = invDir.y < 0;
  boolean signDirZ = invDir.z < 0;

  bbox = signDirX ? maxPos : minPos;
  float txmin = (bbox.x - orig.x) * invDir.x;
  bbox = signDirX ? minPos : maxPos;
  float txmax = (bbox.x - orig.x) * invDir.x;
  bbox = signDirY ? maxPos : minPos;
  float tymin = (bbox.y - orig.y) * invDir.y;
  bbox = signDirY ? minPos : maxPos;
  float tymax = (bbox.y - orig.y) * invDir.y;

  if ((txmin > tymax) || (tymin > txmax)) {
    return false;
  }
  if (tymin > txmin) {
    txmin = tymin;
  }
  if (tymax < txmax) {
    txmax = tymax;
  }

  bbox = signDirZ ? maxPos : minPos;
  float tzmin = (bbox.z - orig.z) * invDir.z;
  bbox = signDirZ ? minPos : maxPos;
  float tzmax = (bbox.z - orig.z) * invDir.z;

  if ((txmin > tzmax) || (tzmin > txmax)) {
    return false;
  }
  if (tzmin > txmin) {
    txmin = tzmin;
  }
  if (tzmax < txmax) {
    txmax = tzmax;
  }
  if ((txmin < maxDist) && (txmax > minDist)) {
    hit.x = orig.x + txmin * dir.x;
    hit.y = orig.y + txmin * dir.y;
    hit.z = orig.z + txmin * dir.z;
    return true;
  }
  return false;
}



void mousePressed() {
  println("toca x=", float(mouseX)/width, "    y=", float(mouseY)/height);
  float mx=float(mouseX)/width;
  float my=float(mouseY)/height;
  if (pantallaConfiguracion==0) {
    if  ((my>0.3) && (my<0.6)) pantallaConfiguracion=1;
    if (my>0.6) configuracion=false;
  }
}

void mouseReleased() {
  
 
}
