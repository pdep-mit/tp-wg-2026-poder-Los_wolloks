import wollok.game.*
import personajes.*
import configGenerales.*

class VisualHUD{
  var property indice
var property position
method image() 
method chocarProyectil(proyectil){}
method chocarItem(item){}
}
class Corazon inherits  VisualHUD{

override method image() {
const vidaActual = estudiante.vida()

    if (vidaActual >= indice) {
      return "corazonlleno.png"
    } else if (vidaActual > indice - 1) {
      return "corazonporlamitad.png"
    } else {
      return "corazonvacio.png"}
}
}
class EscudoHUD inherits VisualHUD{
override method image(){const escudoActual = estudiante.defensa().vida()

    if (escudoActual >= indice) {
      return "escudo.png"
    } else if (escudoActual > indice - 1) {
      return "escudoporlamitad.png"
    } else {
      return "escudovacio.png"}
}
}     

object hud {
  var property  corazones=[]
  var property escudos=[]
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
  method crearEscudos() {
    const totalEscudos = estudiante.defensa().vida()
    escudos = (1..totalEscudos).map({ indice =>
      new EscudoHUD(
        indice = indice,
        position = game.at(config.anchoMax() - 2 - (totalEscudos - indice), config.alturaMax() - 2)
      )
    })
  }

  method mostrarEscudos() {
    escudos.forEach({ escudo => game.addVisual(escudo) })
  }

  method cargarEscudos() {
    self.crearEscudos()
    self.mostrarEscudos()
  }

  method quitarEscudos() {
    escudos.forEach({ escudo => game.removeVisual(escudo) })
    escudos = []
  }

  method actualizarEscudos() {
    self.quitarEscudos()
    self.cargarEscudos()
  }
  }
