import configGenerales.*
import wollok.game.*


object movimiento {
    method mover(objetoMovil,direccion){
  const nuevaPosicion= direccion.posicionSig(objetoMovil)
  objetoMovil.position(nuevaPosicion)
    }
}

class Direccion{
const y
const x
method posicionSig(objetoMovil) {
  const posicion = objetoMovil.position()
  const velocidad= objetoMovil.velocidad()

const nuevaX = (posicion.x()+x*velocidad).limitBetween(0,config.anchoMax()-1)
const nuevaY =(posicion.y()+y*velocidad).limitBetween(0,config.alturaMax()-1)

return game.at(nuevaX, nuevaY)

}
}

object haciaArriba inherits Direccion(y=1,x=0){}
object haciaAbajo inherits Direccion(y=-1,x=0){}
object haciaLaDerecha inherits Direccion(y=0,x=1){}
object haciaLaIzquierda inherits Direccion(y=0,x=-1){}
object quieto inherits Direccion(y=0,x=0){}