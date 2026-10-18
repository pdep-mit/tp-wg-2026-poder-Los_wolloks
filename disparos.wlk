import wollok.game.*
import configGenerales.*
import personajes.*

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
    self.detectarChoques()
  }

  method detectarChoques() {
    game.onCollideDo(
      self,
      { objetoChoque => objetoChoque.chocarProyectil(self) }
    )
  }

  method chocarProyectil(proyectil) {}
  method chocarItem(item) {}

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

class ProyectilEnemigo inherits Proyectil {
  override method image() = "balaEnemiga.png"

  override method detectarChoques() { }

  override method avanzar() {
    super()
    if (game.hasVisual(self) and position == estudiante.position()) {
      estudiante.chocarEnemigo(self)
      self.destruir()
    }
  }
}
class DireccionLibre {
  const property x
  const property y
}