import wollok.game.*
import personajes.*
import movimientos.*
import disparos.*


object config {

   method anchoMax() = 15
  method alturaMax() = 11
  method tamanioCelda() = 50

  method configurarJuego() {
    self.configurarVentana()
    salaDelTesoro.cargar()
    self.agregarComponentesVisuales()
    self.configurarAcciones()
  }

  method configurarVentana() {
    game.title("Los Wolloks | Isaac UTN")
    game.width(self.anchoMax())
    game.height(self.alturaMax())
    game.cellSize(self.tamanioCelda())
  }

  method agregarComponentesVisuales() {
    game.addVisual(estudiante)
    
  }
 
  method configurarAcciones() {
   
    keyboard.w().onPressDo({ movimiento.mover(estudiante, haciaArriba) })
    keyboard.s().onPressDo({ movimiento.mover(estudiante, haciaAbajo) })
    keyboard.d().onPressDo({ movimiento.mover(estudiante, haciaLaDerecha) })
    keyboard.a().onPressDo({ movimiento.mover(estudiante, haciaLaIzquierda) })

    keyboard.up().onPressDo({estudiante.disparar(arma, haciaArriba)})
    keyboard.down().onPressDo({estudiante.disparar(arma, haciaAbajo)})
    keyboard.right().onPressDo({estudiante.disparar(arma, haciaLaDerecha)})
    keyboard.left().onPressDo({estudiante.disparar(arma, haciaLaIzquierda)})


  }
}


object salaDelTesoro {
  method fondo() = "sala-del-tesoro.png"

  
  method posicionDelItem() = pedestal.position()

  method cargar() {
    game.boardGround(self.fondo())
    game.addVisual(pedestal)
  }
}

object pedestal {
  
  method position() = game.center()
  method image() = "pedestal.png"
}
