import wollok.game.*

class Hitbox {
  const duenio
  const desplazamientoX
  const desplazamientoY
  

  method image() = "vacio.png"

  method position() = duenio.position().right(desplazamientoX).up(desplazamientoY)


  // delegan al original como explico el poderosisimo rasta con el bounding box o algo asi
  method chocarProyectil(proyectil) { duenio.chocarProyectil(proyectil) }
  method chocarEnemigo(enemigo) { duenio.chocarEnemigo(enemigo) }
  method chocarItem(item) { duenio.chocarItem(item) }
}