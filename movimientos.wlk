

object movimiento {
    method mover(personajeLibre,direccion){
  const nuevaPosicion= direccion.posicionSig(personajeLibre.position())
  personajeLibre.position(nuevaPosicion)
    }
}

object haciaArriba{
    method posicionSig(posicion){
  if (posicion.y()>=config.alturaMax()-1){
    return posicion
  }
  else{
    return posicion.up(1)
  }
    }
}
object haciaAbajo{
    method posicionSig(posicion){
 if (posicion.y()<=0){
    return posicion
  }
  else{
    return posicion.down(1)
  }
    }
}
object haciaLaDerecha{
    method posicionSig(posicion){
 if (posicion.x()>=config.anchoMax()-1){
    return posicion
  }
  else{
    return posicion.right(1)
  }
    }
}
object haciaLaIzquierda{
    method posicionSig(posicion){
 if (posicion.x()<=0){
    return posicion
  }
  else{
    return posicion.left(1)
  }
    }
}
