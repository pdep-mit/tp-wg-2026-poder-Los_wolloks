object atacando {
  method aplicaA(enemigo) = enemigo.estaAlLadoDelEstudiante()
  method actuar(enemigo) { enemigo.atacar() }
}

object persiguiendo {
  method aplicaA(enemigo) = true
  method actuar(enemigo) { enemigo.perseguir() }
}