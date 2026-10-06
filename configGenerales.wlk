import wollok.game.*
import personajes.*
import movimientos.*
import disparos.*
import items.*


object config {

  method anchoMax() = 15
  method alturaMax() = 11
  method tamanioCelda() = 50

  method configurarJuego() {
    self.configurarVentana()
    salaDelTesoro.cargar()
    self.agregarComponentesVisuales()
    parcial.iniciarMov()
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
    game.addVisual(parcial) 

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

  // el item flota una celda arriba del pedestal
  method posicionDelItem() = pedestal.position().up(1)

  method cargar() {
    game.boardGround(self.fondo())
    game.addVisual(pedestal)

    const item = new ConstanciaAprobado(position = self.posicionDelItem())
    game.addVisual(item)
    game.whenCollideDo(item, { otro => item.chocarCon(otro) })
  }
}

object pedestal {
  
  method position() = game.center()
  method image() = "pedestal.png"
  method chocarProyectil(proyectil){proyectil.destruir()}
}
