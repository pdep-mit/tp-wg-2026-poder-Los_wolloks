import wollok.game.*
import personajes.*
import configGenerales.*
class Corazon{
var property indice
var property position
method image() {
const vidaActual = estudiante.vida()

    if (vidaActual >= indice) {
      return "corazonlleno.png"
    } else if (vidaActual >= indice - 0.5) {
      return "corazonmedio.png"
    } else {
      return "corazonvacio.png"}
}
method chocarProyectil(proyectil){}
}     

object hud {
  var property  corazones=[]
  method cantidadDeCorazones(){
    return corazones.size()
  }
  method crearCorazones(){
   corazones=(1..estudiante.vidaMaxima()).map({indice=>
   new Corazon(
indice=indice,
position=game.at(indice-1,config.alturaMax()-2)
       )
   
     })
    }
    method mostrarCorazones(){
     self.corazones().forEach({corazon=>game.addVisual(corazon)})
    }
    method cargarCorazones() {
    self.crearCorazones()
    self.mostrarCorazones()
   }
   method actualizarCorazanes() {
     self.corazones().forEach({corazon=>game.removeVisual(corazon)})
     self.cargarCorazones()
   }
  }
