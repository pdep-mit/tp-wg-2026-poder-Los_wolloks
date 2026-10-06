import wollok.game.*
import personajes.*

object mensajeItem {
  var property text = ""
  var visible = false
  var numero = 0

  method textColor() = "FFFFFF"
  method position() = game.at(game.center().x(), game.height() - 1)

  method mostrar(titulo, descripcion) {
    text = titulo + " " + descripcion
    numero += 1
    const miNumero = numero
    if (!visible) {
      game.addVisual(self)
      visible = true
    }
    // solo oculta si no apareció otro mensaje mientras tanto
    game.schedule(3000, { if (miNumero == numero) self.ocultar() })
  }

  method ocultar() {
    if (visible) {
      game.removeVisual(self)
      visible = false
    }
  }
}

class ItemPedestal {
  var property position
  var agarrado = false

  method image()
  method titulo()
  method descripcion()
  method efecto(personaje)

  // los disparos pasan de largo por el item
  method chocarProyectil(proyectil) { }

  method chocarCon(otro) {
    if (otro == estudiante && !agarrado) {
      agarrado = true
      self.efecto(estudiante)
      mensajeItem.mostrar(self.titulo(), self.descripcion())
      game.removeVisual(self)
    }
  }
}

class ConstanciaAprobado inherits ItemPedestal {
  override method image() = "constancia_aprobado.png"
  override method titulo() = "Constancia de aprobado!"
  override method descripcion() = "+1 vida"
  override method efecto(personaje) {
    personaje.ganarVida(1)
  }
}