import wollok.game.*
import configGenerales.*


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
      100,
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
   const xSiguiente = position.x() + direccion.x()
  const ySiguiente = position.y() + direccion.y()

       if (xSiguiente < 0 or xSiguiente >= config.anchoMax() or 
        ySiguiente < 0 or ySiguiente >= config.alturaMax()) {
      self.destruir()
    } else {
      self.position(game.at(xSiguiente, ySiguiente))
    }
  }
  
  method destruir() {
    game.removeVisual(self)
    game.removeTickEvent("lagrima_nro_" + self.identity().toString())
  }
}