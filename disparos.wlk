import wollok.game.*

object arma {
  method disparar(tirador, direccionDisparo) {
    const recarga = tirador.velocidadAtaque()
    const nuevaLagrima = new Proyectil(
      position = tirador.position(),
      direccion = direccionDisparo,
      danio = tirador.danio()
    )
    game.addVisual(nuevaLagrima)
    nuevaLagrima.iniciarMov()
    game.schedule(recarga, { tirador.finalizarRecarga() })
  }
}

class Proyectil {
  var property position
  var property direccion
  var property velocidad = 1
   var property danio
  
  method image() = "lagrima.png"
  
  method iniciarMov() {
    game.onTick(
      200,
      "lagrima_nro_" + self.identity().toString(),
      { self.avanzar() }
    )
    game.onCollideDo(
      self,
      { objetoChoque => 
          objetoChoque.chocarProyectil(self)
          }
    )
  }
  method chocarProyectil(){}
  method chocarItem(item){}
  
  method avanzar() {
    const nuevaPos = direccion.posicionSig(self)
    if (nuevaPos == self.position()) self.destruir()
    else self.position(nuevaPos)
  }
  
  method destruir() {
    game.removeVisual(self)
    game.removeTickEvent("lagrima_nro_" + self.identity().toString())
  }
}