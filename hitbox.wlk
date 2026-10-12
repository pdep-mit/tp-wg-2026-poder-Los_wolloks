import wollok.game.*

class Hitbox {
  const duenio
  const desplazamientoX
  const desplazamientoY
  var property position = game.origin()

  method image() = "vacio.png"
  method esSolido() = false
  method actualizar() {
    position = duenio.position().right(desplazamientoX).up(desplazamientoY)
  }

  // delegan al original como explico el poderosisimo rasta con el bounding box o algo asi
  method chocarProyectil(proyectil) { duenio.chocarProyectil(proyectil) }
  method chocarEnemigo(enemigo) { duenio.chocarEnemigo(enemigo) }
  method chocarItem(item) { duenio.chocarItem(item) }
}