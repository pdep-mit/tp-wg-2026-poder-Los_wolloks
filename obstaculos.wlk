import wollok.game.*
import movimientos.*
import personajes.*
import hitbox.*


 
class Obstaculo {
  var property position
  var property vida = 10
  var estaDestruido = false

  method esSolido() = not estaDestruido // Si no esta destruido no te deja pasar
  
  method image()

  method desaparecer() {
    game.schedule(500, {
      if (game.hasVisual(self)) {
        game.removeVisual(self)
      }
    })
  }

  method recibirDanio(cantidad) {
    if (not estaDestruido) {
      vida = 0.max(vida - cantidad) 
      if (vida == 0) {
        estaDestruido = true
        self.desaparecer()
      }
    }
  }   

  method chocarProyectil(proyectil) {
    self.recibirDanio(proyectil.danio())
    proyectil.destruir()
  }

  method chocarEnemigo(enemigo) {}

  method chocarPersonaje(personaje) {
    if (not estaDestruido) {
      self.efecto(personaje)
    }
  }

  method efecto(personaje) {}
}
//bancos -cajas de resumenes/archivos, pizzaron, dispenser de agua(explota)-estacion de carga sube
// que efectos podrian causar?
class Banco inherits Obstaculo{
  const img_obstaculo = "banco.png"
  const img_obstaculo_roto = "banco_roto.png"

  override method image() {
    return if (vida == 0) img_obstaculo_roto else img_obstaculo 
  }
}
class CajaResumenes inherits Obstaculo(vida = 15) {
  override method image() = if (vida > 0) "cajas_papeles.png" else "papeles_desparramados.png"
}

class Pizarron inherits Obstaculo(vida = 12) {
  override method image() = if (vida > 20) "pizarron.png" else "pizarron_agrietado.png"
}