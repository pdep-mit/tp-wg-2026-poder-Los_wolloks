import wollok.game.*
import configGenerales.*
import mapa.*
import personajes.*
import movimientos.*
import hud.*
import sonidos.*

// Pantalla completa: una imagen del tamaño del tablero (750x550) dibujada desde la esquina inferior izquierda.
// Se usa un visual (y no game.boardGround) para que la imagen se vea siempre,
// y para no dejar la imagen de la intro como piso del juego.
class Pantalla {
  const property image

  method position() = game.origin()
}

object gestorPantallas {
  var enJuego = false

  method estaJugando() = enJuego

  // --- INTRO ---
  method mostrarIntro() {
    enJuego = false
    sonidos.detenerSonidoFondo()
    game.clear()
    game.addVisual(new Pantalla(image = "intro.png")) // dice "JUGAR - Presiona ENTER para comenzar"

    keyboard.enter().onPressDo({ // Tecla para iniciar el juego
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
    // si ya terminó (por ejemplo, murió dos veces seguidas) no se repite
    if (enJuego) {
      enJuego = false
      game.removeTickEvent("dispararEstudiante") // Detiene el tick de disparo

      mapa.salaActual().descargar()
      sonidos.detenerSonidoFondo()
      game.clear()
      game.addVisual(new Pantalla(image = imagenOutro))

      keyboard.r().onPressDo({
        if (!enJuego) {
          self.reiniciar()
        }
      })
    }
  }

  method reiniciar() {
    estudiante.reiniciar()
    mapa.reiniciar()
    self.soltarTeclas()
    hud.escudos([])
    self.comenzarPartida()
  }

  // game.clear() borra las teclas: si se murió con una tecla apretada, nunca se avisa que se soltó.
  // Se vuelve todo a "ninguna tecla apretada" para que el estudiante no arranque caminando solo.
  method soltarTeclas() {
    estadoTeclasMovimiento.x(0)
    estadoTeclasMovimiento.y(0)
    estadoTeclasDisparo.x(0)
    estadoTeclasDisparo.y(0)
  }
}
