import wollok.game.*
import personajes.*
import movimientos.*
import disparos.*


object config {
 
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