import wollok.game.*
import personajes.*
import movimientos.*

object config{
    
    
    method configurarAcciones() {
        keyboard.w().onPressDo({movimiento.mover(estudiante,haciaArriba)})
         keyboard.s().onPressDo({movimiento.mover(estudiante,haciaAbajo)})
          keyboard.d().onPressDo({movimiento.mover(estudiante,haciaLaDerecha)})
           keyboard.a().onPressDo({movimiento.mover(estudiante,haciaLaIzquierda)})
}