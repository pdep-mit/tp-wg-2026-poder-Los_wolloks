import wollok.game.*
import configGenerales.*
import personajes.*

object arma {
  // colección de proyectiles en pantalla (para limpiarlos al cambiar de sala)
  const proyectilesActivos = []

  method disparar(tirador, direccionDisparo) {
    const recarga = tirador.velocidadAtaque()
    const nuevaLagrima = new Proyectil(
      position = tirador.position(),
      direccion = direccionDisparo,
      danio = tirador.danio(),
      contraEstudiante = tirador.disparaContraEstudiante()
    )
    proyectilesActivos.add(nuevaLagrima)
    game.addVisual(nuevaLagrima)
    nuevaLagrima.iniciarMov()
    game.schedule(recarga, { tirador.finalizarRecarga() })
  }

  method olvidar(proyectil) {
    proyectilesActivos.remove(proyectil)
  }

  method limpiar() {
    proyectilesActivos.map({ proyectil => proyectil }).forEach({ proyectil => proyectil.destruir() })
  }
}

class Proyectil {
  var property position
  var property direccion
  var property velocidad = 1
   var property danio
  var property contraEstudiante = false
  var activo = true
  
  method image() = "lagrima.png"

  method iniciarMov() {
    game.onTick(
      60,
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
  method chocarProyectil(otroProyectil){}
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
    if (activo) {
      activo = false
      arma.olvidar(self)
      game.removeVisual(self)
      game.removeTickEvent("lagrima_nro_" + self.identity().toString())
    }
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