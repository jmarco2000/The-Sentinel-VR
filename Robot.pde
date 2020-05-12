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

class Robot {
 //angulos robots
float angulo=0;
 //movimiento malo
float velAngular=0.17;
int intervalo=2000;

PShape maya;


int baldosaX, baldosaY;  //baldosa en la que esta
int estado=0;  //0 no me ve ; 1: me ve poco : 2: me ve mogollon 
boolean chupando=false;
int oldEstado=0; //para detectar cambio
boolean vivo=true;
int tipo;  //0 supermalo , 1 nimion

int celdaDisparoX=0; 
int celdaDisparoY=0;

float tiempoTurno;

  Robot(PShape m, int t) {
      
  int cx=-1; int cy=-1;
  int alto=8;
  maya=m;
  tipo=t;
  
  if (tipo==1) alto=round(random(2,8));
  
  while (cx==-1) {
        for (int y=1;y<rows; y++) {
             for (int x=1; x<cols; x++) {
               if ((baldosas[x][y]) && (alturas[x][y]==alto) && (vecinos(x,y,alto)) && (robots[x][y]==0)) {cx=x; cy=y;}
             }
        }
        if (cx==-1) alto--;
  }
  
  if (tipo==0)  robots[cx][cy]=4;
  if (tipo==1)  robots[cx][cy]=2;
  baldosaX=cx; baldosaY=cy;
  
  angulo=random(0,PI*2);
  intervalo=round(random(2000,2700));
  
  tiempoTurno=millis()+10000;
 }
 
 boolean turno() {  //devuelve verdadero si le toca al robot mirar o chupar energia)
   if (tiempoTurno<millis()) {
     tiempoTurno=millis()+intervalo;  
     return true;
   }
   return false;
 }
 
 void dibuja() {
       switch (tipo) {
         case 0:
             pushMatrix(); 
             translate(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY], baldosaY*(tamcelda)+(tamcelda/2));
             scale(100);
             rotateY(PI/2);
             shape(piedraMalo, 0, 0);
             popMatrix();
             if (vivo) {
                   pushMatrix(); 
                   translate(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY]+190, baldosaY*(tamcelda)+(tamcelda/2));
                   scale(200);
                   rotateY(-PI/2+angulo);
                   shape(maya, 0, 0);
                   popMatrix();
                   //dibuja disparo
                   if (estado==2) {
                          strokeWeight(20);
                          stroke(255,55,55,100);
                          line(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY]+490, baldosaY*(tamcelda)+(tamcelda/2),
                            celdaDisparoX*(tamcelda)+(tamcelda/2), alturas[celdaDisparoX][celdaDisparoY]+20, celdaDisparoY*(tamcelda)+(tamcelda/2));        
                     
                   }
                   if (estado==1) {
                          strokeWeight(20);
                          stroke(255,255,55,100);
                          line(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY]+490, baldosaY*(tamcelda)+(tamcelda/2),
                            celdaDisparoX*(tamcelda)+(tamcelda/2), alturas[celdaDisparoX][celdaDisparoY]+20, celdaDisparoY*(tamcelda)+(tamcelda/2));        
                     
                   }
             }
         break;
         
         case 1:
             
             if (vivo) {
                   
                   pushMatrix(); 
                   translate(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY], baldosaY*(tamcelda)+(tamcelda/2));
                   scale(200);
                   rotateY(-PI/2+angulo);
                   shape(maya, 0, 0);
                   popMatrix();
                   //dibuja disparo
                   if (estado==2) {
                          strokeWeight(20);
                          stroke(255,55,55,100);
                          line(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY]+190, baldosaY*(tamcelda)+(tamcelda/2),
                            celdaDisparoX*(tamcelda)+(tamcelda/2), alturas[celdaDisparoX][celdaDisparoY]+20, celdaDisparoY*(tamcelda)+(tamcelda/2));        
                     
                   }
                   if (estado==1) {
                          strokeWeight(20);
                          stroke(255,255,55,100);
                          line(baldosaX*(tamcelda)+(tamcelda/2), alturas[baldosaX][baldosaY]+190, baldosaY*(tamcelda)+(tamcelda/2),
                            celdaDisparoX*(tamcelda)+(tamcelda/2), alturas[celdaDisparoX][celdaDisparoY]+20, celdaDisparoY*(tamcelda)+(tamcelda/2));        
                     
                   }
             }
         break;
             
       }
         
 }
 
 void absorve() {
  chupando=false;
  for (int y=0;y<rows; y++) {
       for (int x=0; x<cols; x++) {
           if ((celdaCamaraX!=x) && (celdaCamaraY!=y)) { 
              if (robots[x][y]==1) { //hay un robot abandonado. chupalo
                  
                 if  (baldosaVisible(x,y)) { //lo ve, a chupar!
                    chupando=true; //esta chupando
                   
                    robots[x][y]=0;
                    absorbibles[x][y]+=2;
                    
                    plantaArbol();
                 } 
              } else if (absorbibles[x][y]>1)  {
                                    
                  if  (baldosaVisible(x,y)) { //lo ve, a chupar!
                    chupando=true; //esta chupando
                    
                    absorbibles[x][y]--;
                    
                    plantaArbol();
                  }  
              }
           }
       }
  }

}

 
 
 
 void vista() {
    boolean veBaldosa=false;
  boolean veCabeza=false;
  oldEstado=estado;
 
  if (maloMeMira() && vivo) { //comprueba si esta escondido 
        //sobre cuantas cajas se ha subido
        
        int numBloque=floor(absorbibles[celdaCamaraX][celdaCamaraY]/2);
        
        
      //visibilidad baldosa
        if (interseccionLaderas(baldosaX*tamcelda+tamcelda/2, alturas[baldosaX][baldosaY]+200, baldosaY*tamcelda+tamcelda/2,
                celdaCamaraX*tamcelda+tamcelda/2, alturas[celdaCamaraX][celdaCamaraY]+80*numBloque, celdaCamaraY*tamcelda+tamcelda/2)) {            
                   veBaldosa=false;
                } else {
                  veBaldosa=true;
                }
                
                //ve cabeza
                  if (interseccionLaderas(baldosaX*tamcelda+tamcelda/2, alturas[baldosaX][baldosaY]+200, baldosaY*tamcelda+tamcelda/2,
                celdaCamaraX*tamcelda+tamcelda/2, alturas[celdaCamaraX][celdaCamaraY]+200+80*numBloque, celdaCamaraY*tamcelda+tamcelda/2)) {            
                   veCabeza=false;
                } else {
                  veCabeza=true;
                }
        if ((veCabeza) && (!veBaldosa)) {
            estado=1;   
            sonido.mediove();
            if (oldEstado!=estado) {celdaDisparoX=celdaCamaraX; celdaDisparoY=celdaCamaraY;}
        }
            else if ((!veCabeza) && (!veBaldosa)) {                
                estado=0;
            }
                else {
                    estado=2;
                    sonido.malove();
                    if (oldEstado!=estado) {celdaDisparoX=celdaCamaraX; celdaDisparoY=celdaCamaraY;}
                    if (oldEstado==estado) {energia--; tiempoTurno+=1000; sonido.quitaenergia();}
                }
                    
  } else estado=0; 
  
  
 }
 
 void mover() {
   sonido.malomueve();
   if ((estado==0) && (!chupando)) angulo=angulo+velAngular;
   if (angulo>PI*2) angulo=0;
  
 }
 
 boolean baldosaVisible(int bx, int by) { //el robot puede ver esta baldosa?
 
 float ab=anguloBaldosa(bx,by);
 
  float diferencia=abs(angulo-ab);
  if ((diferencia<0.1) || (diferencia>6.18)) { //sabemos que le mira, pero? ve la baldosa?
     
     int numBloque=floor(absorbibles[bx][by]/2);
     if (!interseccionLaderas(baldosaX*tamcelda+tamcelda/2, alturas[baldosaX][baldosaY]+200, baldosaY*tamcelda+tamcelda/2,
                bx*tamcelda+tamcelda/2, alturas[bx][by]+80*numBloque, by*tamcelda+tamcelda/2)) {  
         //ve la baldosa con lo cual puede absorver una unidad de energía
                 
         return true;         
     }
    
  }
  return false;  
   
 }
 
 float anguloBaldosa(int bx, int by) {
  
  PVector origen=new PVector(baldosaX*tamcelda+tamcelda/2, baldosaY*tamcelda+tamcelda/2);
  PVector destino=new PVector(bx*tamcelda+tamcelda/2, by*tamcelda+tamcelda/2);
  
  float ang = atan2(destino.y-origen.y,destino.x -origen.x);
  if (ang<0) ang=2*PI + ang;
  ang=PI*2-ang;
 
  return ang;
}
 
 boolean interseccionLaderas(float xo, float yo, float zo, float xd, float yd, float zd) {  //o coordenada origen del rayo  d coordenada destino rayo
  
  PVector p1,p2,p3;
  PVector q1=new PVector(xo,yo,zo);
  PVector q2=new PVector(xd,yd,zd);
  /*
  strokeWeight(10);
  stroke(255,255,255);
  line(xo,yo,zo,xd,yd,zd);
  */
  
  for (int y=0;y<rows; y++) { 
   
   for (int x=0; x<cols; x++) {    
    p1 = new PVector(x*(tamcelda),alturas[x][y], y*(tamcelda));
    p2 = new PVector(x*(tamcelda),alturas[x][y+1], (y+1)*(tamcelda));
    p3 = new PVector((x+1)*(tamcelda),alturas[x+1][y+1], (y+1)*tamcelda);
    if (interseccionTriangulo(q1,q2,p1,p2,p3)) return true;;
    
    p1 = new PVector(x*(tamcelda),alturas[x][y], y*(tamcelda));
    p2 = new PVector((x+1)*(tamcelda),alturas[x+1][y+1], (y+1)*(tamcelda));
    p3 = new PVector((x+1)*(tamcelda),alturas[x+1][y], (y)*(tamcelda));
    if (interseccionTriangulo(q1,q2,p1,p2,p3)) return true;
    
    
   }
  }

  return false;
}

boolean interseccionTriangulo(PVector q1, PVector q2, PVector p1, PVector p2, PVector p3) {
  //https://stackoverflow.com/questions/42740765/intersection-between-line-and-triangle-in-3d
  boolean resultado=false;
  
  // ecuacion SignedVolume(a,b,c,d) = (1.0/6.0)*dot(cross(b-a,c-a),d-a)
  
  float a=signedVolume(q1,p1,p2,p3);
  float b=signedVolume(q2,p1,p2,p3);
  float c=signedVolume(q1,q2,p1,p2);
  float d=signedVolume(q1,q2,p2,p3);
  float e=signedVolume(q1,q2,p3,p1);
  
  if ((signum(a)!=signum(b) && (signum(c)==signum(d)) && (signum(d)==signum(e)))) resultado=true;
  return resultado;
  
}

float signedVolume(PVector a, PVector b, PVector c, PVector d) {
 PVector b_a=PVector.sub(b,a);
 PVector c_a=PVector.sub(c,a);
 PVector d_a=PVector.sub(d,a);
 PVector pvec=b_a.cross(c_a);
 float res=pvec.dot(d_a);
 return res;
  
}

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
}

float anguloMalo() {
  
  PVector origen=new PVector(baldosaX*tamcelda+tamcelda/2, baldosaY*tamcelda+tamcelda/2);
  PVector destino=new PVector(celdaCamaraX*tamcelda+tamcelda/2, celdaCamaraY*tamcelda+tamcelda/2);
  
  float ang = atan2(destino.y-origen.y,destino.x -origen.x);
  if (ang<0) ang=2*PI + ang;
  ang=PI*2-ang;
  
  return ang;
}

boolean maloMeMira() {
  
  float a=anguloMalo();
  
  float diferencia=abs(angulo-a);
  if ((diferencia<0.1) || (diferencia>6.18)) return true; else return false; 
}
  
}
