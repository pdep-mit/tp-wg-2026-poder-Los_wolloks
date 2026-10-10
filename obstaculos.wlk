import wollok.game.*
import movimientos.*
import personajes.*
import hitbox.*
import cuerpo_personajes.*


 
class Obstaculo {
  var property position
  var property vida = 10
  var estaDestruido = false

  method esSolido() = not estaDestruido // Si no esta destruido no te deja pasar
  const cuerpo = new Cuerpo(duenio = self)
  
  method inicializar(){
    cuerpo.agregar() //agrega la hitbox 
  }
  method image()

  method desaparecer() {
    game.schedule(500, {
      if (game.hasVisual(self)) {
        cuerpo.sacar() 
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

  method chocarEstudiante(estudiante) {
    if (not estaDestruido) {
      self.efecto(estudiante)
    }
  }

  method efecto(estudiante) {}
}
//bancos -cajas de resumenes/archivos, pizzaron, dispenser de agua(explota)-estacion de carga sube
// que efectos podrian causar?
class Banco inherits Obstaculo(vida = 10){
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