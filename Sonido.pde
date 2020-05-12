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

class Sonido {

  AudioPlayer s_malove;
  AudioPlayer s_absorve;
  AudioPlayer s_caja;
  AudioPlayer s_mal;
  AudioPlayer s_mediove;
  AudioPlayer s_malomueve;
  AudioPlayer s_quitaenergia;
  AudioPlayer s_viaje;
  AudioPlayer s_gameover;
  
 Sonido(PApplet app) {
   
  s_malove=new AudioPlayer();
  s_malove.loadFile(app,"malove.wav"); 
  
  s_absorve=new AudioPlayer();
  s_absorve.loadFile(app,"absorve.wav");
  
  s_caja=new AudioPlayer();
  s_caja.loadFile(app,"caja.wav");
   
  s_mal=new AudioPlayer();
  s_mal.loadFile(app,"mal.wav");
  
  s_mediove=new AudioPlayer();
  s_mediove.loadFile(app,"malomediove.wav");
  
  s_malomueve=new AudioPlayer();
  s_malomueve.loadFile(app,"malomueve.wav");
  
  s_quitaenergia=new AudioPlayer();
  s_quitaenergia.loadFile(app,"quitaenergia.wav");
  
  s_viaje=new AudioPlayer();
  s_viaje.loadFile(app,"viaje.wav");
  
  s_gameover=new AudioPlayer();
  s_gameover.loadFile(app,"gameover.wav");
   
   println("cargado");
   
   
 }
 

 void mal() {      
       s_mal.play();      
 }
 
  void malove() {      
       s_malove.play();      
 }
 
 void absorve() {
   s_absorve.play();
 }
 
 void caja() {
   s_caja.play();
 }
 
 void mediove() {
  s_mediove.play(); 
 }
 
 void malomueve() {
  s_malomueve.play(); 
 }
 
 void quitaenergia() {
   s_quitaenergia.play();
 }
 
 void viaje() {
   s_viaje.play();
 }
 
  void gameover() {
   s_gameover.play();
 }
  
}
