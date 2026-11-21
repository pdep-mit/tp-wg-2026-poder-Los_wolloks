import wollok.game.*
import personajes.*


object sonidos {
    var sonidoFondoActual = null
    var archivoFondoActual = null

    method disparo(personaje) {
        const sonidoDisparo = game.sound(personaje.sonidoDisparo())
        sonidoDisparo.volume(0.8)
        sonidoDisparo.play()
    }

    method recibirDanio(personaje) {
        const sonidoDanio = game.sound(personaje.sonidoRecibirDanio())
        sonidoDanio.volume(0.2)
        sonidoDanio.play()
    }

    method muerte(personaje) {
        game.sound(personaje.sonidoMuerte()).play()
    }

    method recogerItem(item) {
        game.sound(item.sonido_pick()).play()
    }

    method detenerSonidoFondo() {
        if (sonidoFondoActual != null) {
            sonidoFondoActual.stop()
            sonidoFondoActual = null
            archivoFondoActual = null
        }
    }

     method sonidoFondoSala(sala) {
        const nuevoArchivo = sala.sonidoFondo()

        if (archivoFondoActual != nuevoArchivo || sonidoFondoActual == null) {
            self.detenerSonidoFondo()

            archivoFondoActual = nuevoArchivo
            sonidoFondoActual = game.sound(nuevoArchivo)
            sonidoFondoActual.shouldLoop(true)
            sonidoFondoActual.volume(0.1)
            sonidoFondoActual.play()
        }
    }

    method abrirPuerta() {
        game.sound("puerta.mp3").play()
    }

    method salaCompletada() {
        const sonidoSalaCompletada = game.sound("salaCompletada.mp3")
        sonidoSalaCompletada.volume(0.5)
        sonidoSalaCompletada.play()
    }

    method victoria() {
        game.sound("victoria.mp3").play()
    }
}