object atacando {
  method aplicaA(enemigo) = enemigo.estaAlLadoDelEstudiante()
  method actuar(enemigo) { enemigo.atacar() }
}

object persiguiendo {
  method aplicaA(enemigo) = true
  method actuar(enemigo) { enemigo.perseguir() }
}

// Se elimina el estado disparando porque los enemigos tiradores disparan de manera independiente a sus estados de movimiento (perseguir y atacar).