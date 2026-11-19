import wollok.game.*
import hitbox.*

class Cuerpo {
  const duenio
  var hitboxes = []

  method agregar() {
    hitboxes = [
      new Hitbox(duenio = duenio, desplazamientoX = 1, desplazamientoY = 0),
      new Hitbox(duenio = duenio, desplazamientoX = 0, desplazamientoY = 1),
      new Hitbox(duenio = duenio, desplazamientoX = 1, desplazamientoY = 1)
    ]
    hitboxes.forEach({ h =>
    
      game.addVisual(h)
    })
  }

  method sacar() {
    hitboxes.forEach({ h => game.removeVisual(h) })
    hitboxes = []
  }
}