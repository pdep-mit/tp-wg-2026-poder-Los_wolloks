import configGenerales.*
import wollok.game.*
import personajes.*
import disparos.*



object movimiento {
    method mover(objetoMovil,direccion){
    const nuevaPosicion= direccion.posicionSig(objetoMovil)
    const objetosEnDestino = game.getObjectsIn(nuevaPosicion)

    const hayObstaculoSolido = objetosEnDestino.any({ obj => obj.esSolido() })

    if (not hayObstaculoSolido) {
      objetoMovil.position(nuevaPosicion)
    }
  }
}

class Direccion{
const property y
const property x
method esMovimiento()=x!=0 or y!=0
method posicionSig(objetoMovil) {
  const posicion = objetoMovil.position()
  const velocidad= objetoMovil.velocidad()

const nuevaX = (posicion.x()+x).limitBetween(0,config.anchoMax()-2)
const nuevaY =(posicion.y()+y).limitBetween(0,config.alturaMax()-2)

return game.at(nuevaX, nuevaY)

}
}
class EstadoTeclas {
  var property x = 0
  var property y = 0
  var procesandoBuffer = false
  method modificarX(cantidad) {
    x=(x+cantidad).limitBetween(-1,1)
  }
  
  method modificarY(cantidad) {
    y=(y+cantidad).limitBetween(-1,1)
  }
  
  method estaActivo() = (x != 0) or (y != 0)
  
  method direccionActual() = new Direccion(x = x, y = y)
  method ejecutarConBuffer(bloqueAccion) {
    if (!procesandoBuffer) {
      procesandoBuffer = true
      game.schedule(25, {
        procesandoBuffer = false
        if (self.estaActivo()) {
          bloqueAccion.apply()
         }
       })
     }
   }
}

object estadoTeclasMovimiento inherits EstadoTeclas {
  method procesar() {
    self.ejecutarConBuffer({ estudiante.mover(self.direccionActual())})
  }
}

object estadoTeclasDisparo inherits EstadoTeclas {
  method procesar() {
 self.ejecutarConBuffer({ estudiante.disparar(arma, self.direccionActual()) })
  }
}


object haciaArriba inherits Direccion(y=1,x=0){}
object haciaAbajo inherits Direccion(y=-1,x=0){}
object haciaLaDerecha inherits Direccion(y=0,x=1){}
object haciaLaIzquierda inherits Direccion(y=0,x=-1){}
object quieto inherits Direccion(y=0,x=0){}