import wollok.game.*
import movimientos.*
import estados.*
import hitbox.*
import cuerpo_personajes.*
import hud.*
import disparos.*
import mapa.*
import items.*


object estudiante {

    var property vidaMaxima = 3 
    var property vida = 3
    var property danio = 1
    var property velocidad  = 1
    var property puedeDisparar = true
    var property puedeMoverse = true
    var property velocidadAtaque = 800
    var property estaDisparando = false
    var property direccionDisparo = null
    var property defensa = sinEscudo
    var  orientacion = 1//1 mira a la derecha , 0 a la izquierda

    var position = game.at(8, 8)

    method position() = position

    const cuerpo = new Cuerpo(duenio = self)

    method position(nueva) {
        position = nueva
        cuerpo.seguirA()
    }

    method agregarHitboxes() { cuerpo.agregar() }

    method tiempoEntrePasos() = (200 - (velocidad * 20)).max(50)
    method actualizarOrientacion(direccion) { 
       orientacion=(orientacion+direccion.x()).limitBetween(0, 1)
    }
    method mover(direccion) {
        self.actualizarOrientacion(direccion)
        if (!self.estaMuerto() and puedeMoverse and direccion.esMovimiento()) {
            movimiento.mover(self, direccion)
            mapa.revisarPuertas()
            puedeMoverse = false
      
            game.schedule(self.tiempoEntrePasos(), {
                if(!self.estaMuerto()){
                puedeMoverse = true
                self.intentarSeguirMoviendose()
                }
            })
        }
    }

    method intentarSeguirMoviendose() {
        if (estadoTeclasMovimiento.estaActivo()) {
            self.mover(estadoTeclasMovimiento.direccionActual())
        }
    }

    method image() {
        if (vida == 0) return "estudiante_muerto.png"

        return "estudiante" + self.sufijoSalud() + self.sufijoDireccion() + defensa.sufijoVisual()+".png"
    }

    method sufijoSalud() = if (vida <= vidaMaxima / 3) "_daniado" else ""

    method sufijoDireccion() = if (orientacion==1) "_der" else "_izq"


    method disparar(arma, direccion) {
        if (puedeDisparar and direccion.esMovimiento()) {
            self.puedeDisparar(false)
            arma.disparar(self, direccion)
        }
    }

    method finalizarRecarga() {
        if(!self.estaMuerto()){
        self.puedeDisparar(true)}
    }

    method chocarEnemigo(enemigo) {
        self.recibirDanio(enemigo.danio())
    }

    method disparaContraEstudiante() = false

    // Solo lo lastiman los proyectiles de los enemigos
    method chocarProyectil(proyectil) {
        if (proyectil.contraEstudiante()) {
            self.recibirDanio(proyectil.danio())
            proyectil.destruir()
        }
    }
    method estaMuerto()= vida==0

    method recibirDanio(cantidad) {
        defensa.absorberDanio(cantidad, self)
        
        if (self.estaMuerto()) {
            self.morir()
        }}
    
    method restarVida(cantidad) { //Cuando no tiene escudo
        vida = 0.max(vida - cantidad)
    }

    method morir() {
        puedeMoverse=0
        velocidad = 0
        puedeDisparar = false
        game.say(self, "Nos vemos en el recu")
        game.schedule(1000, { game.removeVisual(self) })
        game.schedule(300, { game.stop() })
    }

    method ganarVida(cantidad) {
        vidaMaxima += cantidad
        vida += cantidad
        hud.actualizarCorazanes()
    }

    method chocarItem(item) {
        item.chocarEstudiante(self)
    }
}


class Enemigo {
    var property vida
    var property vidaMaxima
    var property danio
    var property velocidad = 1
    
    var property imagenDaniado
    var property imagenEnemigo
    var property imagenMuerto
    
    var position // La posición debe pasarse al crear cada enemigo.

    method position() = position

    const cuerpo = new Cuerpo(duenio = self)

    method position(nueva) {
        position = nueva
        cuerpo.seguirA()
    }

    var enEscena = false

    method nombreTick() = "enemigo_persigue_" + self.identity().toString()

    method iniciarMov() {
        game.onTick(500, self.nombreTick(), { self.acercarseAenemigo() })
    }

    method disparaContraEstudiante() = true

    // Solo lo lastiman los proyectiles del estudiante
    method chocarProyectil(proyectil) {
        if (!proyectil.contraEstudiante()) {
            self.recibirDanio(proyectil.danio())
            proyectil.destruir()
        }
    }

    method estaMuerto() = vida == 0

    method recibirDanio(cantidad) {
        if (!self.estaMuerto()) {
            vida = 0.max(vida - cantidad)
            if (self.estaMuerto()) {
                self.morir()
            }
        }
    }
    
    method morir() {
        game.removeTickEvent(self.nombreTick())
        game.schedule(800, { self.retirar() })
    }

    // Saca al enemigo del juego (al morir o al cambiar de sala)
    method retirar() {
        if (enEscena) {
            if (!self.estaMuerto()) {
                game.removeTickEvent(self.nombreTick())
            }
            cuerpo.sacar()
            game.removeVisual(self)
            enEscena = false
        }
    }
    
    method image() {
        if (vida == 0) {
            return imagenMuerto
        } else if (vida <= vidaMaxima / 3) {
            return imagenDaniado
        } else {
            return imagenEnemigo
        }
    }
    
    method estados() = [atacando, persiguiendo]

    method acercarseAenemigo() {
        self.estados().find({ estado => estado.aplicaA(self) }).actuar(self)
    }

    method atacar() {
        estudiante.chocarEnemigo(self)
    }

    method perseguir() {
        movimiento.mover(self, self.direccionHorizontal())
        movimiento.mover(self, self.direccionVertical())
    }

    method estaAlLadoDelEstudiante() {
        return position.distance(estudiante.position()) <= 2
    }

    method direccionHorizontal() {
        if (position.x() < estudiante.position().x()) { return haciaLaDerecha }
        if (position.x() > estudiante.position().x()) { return haciaLaIzquierda }
        return quieto
    }

    method direccionVertical() {
        if (position.y() < estudiante.position().y()) { return haciaArriba }
        if (position.y() > estudiante.position().y()) { return haciaAbajo }
        return quieto
    }

    method direccionAlEstudiante() { // CAMBIO: método común para calcular hacia dónde apuntar.
        const dx = estudiante.position().x() - self.position().x()
        const dy = estudiante.position().y() - self.position().y()
        const pasoX = if (dx.abs() * 2 >= dy.abs()) self.signo(dx) else 0
        const pasoY = if (dy.abs() * 2 >= dx.abs()) self.signo(dy) else 0
        return new DireccionLibre(x = pasoX, y = pasoY)
    }

    method signo(numero) = if (numero > 0) 1 else if (numero < 0) -1 else 0 // CAMBIO: helper compartido por los enemigos.

    method chocarItem(item) { }

    // Pone al enemigo en el juego
    method aparecer() {
        game.addVisual(self)
        cuerpo.agregar()
        enEscena = true
        self.iniciarMov()
    }
}


class EnemigoTirador inherits Enemigo {
    override method iniciarMov() {
        game.onTick(1000, "enemigo_persigue_" + self.identity().toString(), { self.acercarseAenemigo() })
        game.onTick(2500, "enemigo_dispara_" + self.identity().toString(), { self.disparar() })
    }
      
    method disparar() {
        const bala = new ProyectilEnemigo(
            position = self.position(),
            direccion = self.direccionDeDisparo(),
            danio = self.danio()
        )
        game.addVisual(bala)
        bala.iniciarMov()
    }

    method direccionDeDisparo() = self.direccionAlEstudiante() // CAMBIO: reutiliza el método común de Enemigo.

    override method morir() {
        game.removeTickEvent("enemigo_dispara_" + self.identity().toString())
        super()
    }
}


class EnemigoDivisible inherits Enemigo {
    const nivel
    var yaSeDividio = false

    override method morir() {
        if (not yaSeDividio) {
            yaSeDividio = true
            if (nivel > 1) { self.dividirse() }
        }
        super()
    }

    const separacion = 3
    method tirarEscudo() {
        const escudoDrop = new ItemEscudo(position = self.position().right(2))
        game.addVisual(escudoDrop)
    
        game.whenCollideDo(escudoDrop, { otro => otro.chocarItem(escudoDrop) })
   }
    method dividirse() {
        self.hijoEn(self.position().left(separacion)).aparecer()
        self.hijoEn(self.position().right(separacion)).aparecer()
        self.tirarEscudo()
    }

    method hijoEn(posicion) = new EnemigoDivisible(
        nivel = nivel - 1,
        vida = self.vidaMaxima() / 2,
        vidaMaxima = self.vidaMaxima() / 2,
        danio = self.danio() / 2,
        position = posicion,
        imagenEnemigo = "parcialChico.png",
        imagenDaniado = "parcialChicoDaniado.png",
        imagenMuerto = "parcialChicoMuerto.png"
    )
}


const parcial = new Enemigo(
    vida = 5,
    vidaMaxima = 5,
    danio = 0.5,
    position = game.at(5, 10), // CAMBIO: Enemigo requiere una posición al instanciarse.
    imagenDaniado = "parcialDaniado.png",
    imagenEnemigo = "parcial.png",
    imagenMuerto = "parcialMuerto.png"
)

class ParcialProlog inherits Enemigo(
    vida = 3,
    vidaMaxima = 3,
    danio = 0.5,
    imagenDaniado = "parcialDaniado.png",
    imagenEnemigo = "parcial.png",
    imagenMuerto = "parcialMuerto.png"
) {
    var property velocidadAtaque = 1500
    var puedeDisparar = true

    override method estados() = [disparando]

    method finalizarRecarga() {
        puedeDisparar = true
    }

    method disparar() {
        if (puedeDisparar) {
            puedeDisparar = false
            arma.disparar(self, self.direccionAlEstudiante()) // CAMBIO: ahora existe en la clase base Enemigo.
        }
    }
} // CAMBIO: cierra ParcialProlog antes de declarar los siguientes enemigos.


const parcialTirador = new EnemigoTirador(
    vida = 4,
    vidaMaxima = 4,
    danio = 0.5,
    position = game.at(20, 12),
    imagenDaniado = "parcialTiradorDaniado.png",
    imagenEnemigo = "parcialTirador.png",
    imagenMuerto = "parcialTiradorMuerto.png"
)

const parcialDivisible = new EnemigoDivisible(
    nivel = 2,
    vida = 6,
    vidaMaxima = 6,
    danio = 0.5,
    position = game.at(20, 8),
    imagenDaniado = "parcialDivisibleDaniado.png",
    imagenEnemigo = "parcialDivisible.png",
    imagenMuerto = "parcialDivisibleMuerto.png"
)
