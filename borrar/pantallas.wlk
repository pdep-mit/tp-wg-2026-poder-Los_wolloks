import configGenerales.*
import mapa.*
import personajes.*

object gestorPantallas {
  var enJuego = false

  method estaJugando() = enJuego

  // --- INTRO ---
  method mostrarIntro() {
    enJuego = false
    game.clear()
    game.boardGround("intro.png") //deberia tener "presiona enter para comenzar"
    
   
    keyboard.enter().onPressDo({ //Tecla para iniciar el juego
      if (!enJuego) {
        self.comenzarPartida()
      }
    })
  }

  method comenzarPartida() {
    enJuego = true
    game.clear() // Limpia la tecla enter y cualquier visual de la intro
    config.iniciarPartida()
  }

  // --- OUTRO ---
  method mostrarVictoria() {
    self.finalizarPartida("outro_victoria.png")
  }

  method mostrarDerrota() {
    self.finalizarPartida("outro_derrota.png")
  }

  method finalizarPartida(imagenOutro) {
    enJuego = false
    game.removeTickEvent("dispararEstudiante") // Detiene el tick de disparo
    
    mapa.salaActual().descargar()
    game.clear() 
    game.boardGround(imagenOutro)

    keyboard.r().onPressDo({
      if (!enJuego) {
        self.reiniciar()
      }
    })
  }

  method reiniciar() {
    
    estudiante.reiniciar() 
    mapa.reiniciar()
    self.comenzarPartida()
  }
}