import wollok.game.*
import personajes.*

object mensajeItem {
  var property text = ""
  var visible = false
  var numero = 0

  method textColor() = "FFFFFF"
  method position() = game.at(game.center().x(), game.height() - 2)

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

  method fueAgarrado() = agarrado

  method image()
  method titulo()
  method descripcion()
  method efecto(personaje)

  // los disparos pasan de largo por el item
  method chocarProyectil(proyectil) { }

  method chocarEstudiante(personaje) {
    if (!agarrado) {
      agarrado = true
      self.efecto(personaje)
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

class ApuntesWollok inherits ItemPedestal {
  override method image() = "apuntes_wollok.png"
  override method titulo() = "Ahora entiendo polimorfismo!"
  override method descripcion() = "+1 daño"
  override method efecto(personaje) {
    personaje.danio(personaje.danio() + 1)
  }
}

class CafeDelBuffet inherits ItemPedestal {
  override method image() = "cafe_del_buffet.png"
  override method titulo() = "Café del buffet!"
  override method descripcion() = " + Velocidad de ataque"
  override method efecto(personaje) {
    personaje.velocidadAtaque(150.max(personaje.velocidadAtaque() - 150))
  }
}


//No es item que aparece en pedestal
class ItemEscudo inherits ItemPedestal {
    override method image() = "escudo.png"
    override method titulo() = "Escudo!"
    override method descripcion() = "+5 vida" 
    
    override method efecto(personaje) {
        personaje.defensa(new DefensaEscudo())
    }
}

//ItemEscudo crea un escudo DefensaEscudo ya que por heredar ItemPedestal, desaparece al ser agarrado
class DefensaEscudo { 
    var property vida = 5

    method absorberDanio(cantidad, personaje) {
        vida = 0.max(vida - cantidad)
        if (vida == 0) {
            personaje.defensa(sinEscudo)
        }
    }
    method sufijoVisual() = "_escudo"
}
object sinEscudo {
    method absorberDanio(cantidad, personaje) {
        personaje.restarVida(cantidad)
    }
    method sufijoVisual() = ""
}
