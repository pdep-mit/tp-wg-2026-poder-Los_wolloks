import personajes.*
import wollok.game.*
import movimientos.*
import hitbox.*
import cuerpo_personajes.*

class Obstaculo inherits Enemigo {

    override method esSolido() = true

    override method iniciarMov() {
    }

    override method morir() {
        game.schedule(800, { 
            if (game.hasVisual(self)) {
                game.removeVisual(self) 
            }
        })
    }

    override method acercarseAenemigo() {
    }

    override method image(){
        if(vida == 0){
            return imagenMuerto
        }else{
            return imagenBase
        }
    }
    method ocupaPosicion(unaPosicion) {
        return position == unaPosicion
    }

    
}