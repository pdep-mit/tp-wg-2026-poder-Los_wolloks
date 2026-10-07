import configGenerales.*
import wollok.game.*


object movimiento {
    method mover(personaje,direccion){
  const nuevaPosicion= direccion.posicionSig(personaje)
  personaje.position(nuevaPosicion)
    }
}

object haciaArriba{
    method posicionSig(personaje){
        const velocidad=personaje.velocidad()
        const posicion=personaje.position()
        const techo=config.alturaMax()-1

  if (posicion.y()+ velocidad >=techo){
    return game.at(posicion.x(),techo)
  }
  else{
    return posicion.up(velocidad)
  }
    }
}
object haciaAbajo{
    method posicionSig(personaje){
        const velocidad=personaje.velocidad()
        const posicion=personaje.position()
        const piso=0

  if (posicion.y() - velocidad <=piso){
    return game.at(posicion.x(),piso)
  }
  else{
    return posicion.down(velocidad)
  }
    }
}
object haciaLaDerecha{
    method posicionSig(personaje){
        const velocidad=personaje.velocidad()
        const posicion=personaje.position()
        const limDer=config.anchoMax()-1

  if (posicion.x()+ velocidad >=limDer){
    return game.at(limDer,posicion.y())
  }
  else{
    return posicion.right(velocidad)
  }
    }
}
object haciaLaIzquierda{
    method posicionSig(personaje){
        const velocidad=personaje.velocidad()
        const posicion=personaje.position()
        const limIzq=0

  if (posicion.x() - velocidad <=limIzq){
    return game.at(limIzq,posicion.y())
  }
  else{
    return posicion.left(velocidad)
  }
    }
}

object quieto {
    method posicionSig(personaje) {
        return personaje.position()
    }
}