import wollok.game.*
import personajes.*

object sonidos {

//se podria hacer que los disparos del estudiante sean diferentes a los de enemigo disparo(personaje)....
    method disparo() {
        game.sound("disparo.wav").play()
        
    }

    method recibirDanio(personaje) {

        game.sound(personaje.sonidoRecibirDanio()).play()
    }

    method muerte(personaje) {
        game.sound(personaje.sonidoMuerte()).play()
    }

    method recogerItem(item) {
        game.sound(item.sonido_pick()).play()
    }
}