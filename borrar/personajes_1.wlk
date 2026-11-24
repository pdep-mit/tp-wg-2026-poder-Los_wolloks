import pantallas.*
import wollok.game.*
import movimientos.*
import estados.*
import hitbox.*
import cuerpo_personajes.*
import hud.*
import disparos.*
import mapa.*
import items.*
import sonidos.*
import configGenerales.*


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
    const property sonidoRecibirDanio = "daño_estudiante.ogg"
    const property sonidoMuerte = "muerte_estudiantee.wav"
    const property sonidoDisparo = "disparosPapel.wav" 


    var position = game.at(8, 8)

    method position() = position

    const cuerpo = new Cuerpo(duenio = self)

    method position(nueva) {
        position = nueva
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
            sonidos.muerte(self)
        }
        sonidos.recibirDanio(self)
        }
    
    method restarVida(cantidad) { //Cuando no tiene escudo
        vida = 0.max(vida - cantidad)
    }

    method morir() {
        puedeMoverse = false
        velocidad = 0
        puedeDisparar = false
        game.say(self, "Nos vemos en el recu")
        game.schedule(1000, { game.removeVisual(self) })
        game.schedule(1000,{gestorPantallas.mostrarDerrota()}); //ya mostrar derrota limpia y permite volver a jugar 
       
    }

    method ganarVida(cantidad) {
        vidaMaxima += cantidad
        vida += cantidad
        hud.actualizarCorazanes()
    }

    method chocarItem(item) {
        item.chocarEstudiante(self)
    }

    method reiniciar() {
        puedeMoverse = true
        puedeDisparar = true
        vida = vidaMaxima
        defensa = sinEscudo
        position = game.at(config.anchoMax().div(2) - 1, 2) // posición inicial
        // y resetear cualquier stat que hayan subido los ítems (danio, velocidadAtaque)
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
    
    
    var position   // La posición debe pasarse al crear cada enemigo.
    const positionInicial = position
    const property sonidoRecibirDanio = "recibir_danio_enemigo.wav"
    const property sonidoMuerte = "muerte_enemigo.wav"
    const property sonidoDisparo = "disparosEnemigo.wav"  

    method position() = position

    const cuerpo = new Cuerpo(duenio = self)

    method position(nueva) {
        position = nueva
    }

    var enEscena = false

    method nombreTick() = "enemigo_persigue_" + self.identity().toString()

    method iniciarMov() {
        game.onTick(500, self.nombreTick(), { self.acercarseAenemigo() })
    }

    // Frena todo lo que el enemigo hace con el tiempo (las subclases agregan lo suyo)
    method detenerMov() {
        game.removeTickEvent(self.nombreTick())
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
            sonidos.recibirDanio(self)
            if (self.estaMuerto()) {
                self.morir()
            }
        }

    }
    
    method morir() {
        self.detenerMov()
        sonidos.muerte(self)
        game.schedule(800, { self.retirar() })
    }

    // Saca al enemigo del juego (al morir o al cambiar de sala)
    method retirar() {
        if (enEscena) {
            if (!self.estaMuerto()) {
                self.detenerMov()
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
    
    method reiniciar(){
        vida = vidaMaxima
        position = positionInicial
    
    }

    method estados() = [atacando, persiguiendo]

    method acercarseAenemigo() {
        self.estados().find({ estado => estado.aplicaA(self) }).actuar(self)
    }

    method atacar() {
        estudiante.chocarEnemigo(self)
    }
method distanciaMinimaCompanieros()=3
method companierosVivos() =mapa.salaActual().enemigosVivos().filter({enemigo => enemigo != self})
method estaCercaDePosicion(posicion,distancia)=
(position.x()-posicion.x()).abs()<distancia and (position.y()-posicion.y()).abs()<distancia

method companieroCercaDe(posicion)=self.companierosVivos().any({otro=>otro.estaCercaDePosicion(posicion, self.distanciaMinimaCompanieros())})
method intentarMoverse(direccion) {
  if (direccion.esMovimiento()) {
    const destino = direccion.posicionSig(self)
    if (destino != position and !self.companieroCercaDe(destino)) {
      movimiento.mover(self, direccion)
      return true
    } else {
      return false
    }
  } else {
    return false
  }
}
method intentarRodear() {
        const direcciones = [haciaArriba, haciaAbajo, haciaLaDerecha, haciaLaIzquierda]
        const libres = direcciones.filter({ dir =>
            const destino = dir.posicionSig(self)
            destino != position and !self.companieroCercaDe(destino)
        })
        if (!libres.isEmpty()) {
            movimiento.mover(self, libres.anyOne())
        }
    }
   method perseguir() {
        const avanzoHorizontal = self.intentarMoverse(self.direccionHorizontal())
        const avanzoVertical = self.intentarMoverse(self.direccionVertical())

      if (!avanzoHorizontal and !avanzoVertical) {
            self.intentarRodear()
        }
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
    method nombreTickDisparo() = "enemigo_dispara_" + self.identity().toString()

    override method iniciarMov() {
        game.onTick(1000, self.nombreTick(), { self.acercarseAenemigo() })
        game.onTick(2500, self.nombreTickDisparo(), { self.disparar() })
    }

    // además de dejar de moverse, deja de disparar (al morir o al irse de la sala)
    override method detenerMov() {
        game.removeTickEvent(self.nombreTickDisparo())
        super()
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

    // el escudo queda en la sala donde cae (no viaja a la siguiente)
    method tirarEscudo() {
        const escudoDrop = new ItemEscudo(position = self.position().right(2),sonido_pick = "pick_escudo.mp3")
        mapa.salaActual().soltarItem(escudoDrop)
    }

    // los hijos pasan a ser enemigos de la sala: hay que derrotarlos para abrir las puertas
    method dividirse() {
        mapa.salaActual().agregarEnemigo(self.hijoEn(self.position().left(separacion)))
        mapa.salaActual().agregarEnemigo(self.hijoEn(self.position().right(separacion)))
        self.tirarEscudo()
    }

    override method reiniciar() {
        super()
        yaSeDividio = false
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

class Parcial inherits Enemigo(vida = 5,
    vidaMaxima = 3,
    danio = 0.5,
    imagenDaniado = "parcialDaniado.png",
    imagenEnemigo = "parcial.png",
    imagenMuerto = "parcialMuerto.png"){
    
} 
// Con estas clases cada sala crea sus propios enemigos: new ParcialTirador(position = ...)
class ParcialTirador inherits EnemigoTirador(
    vida = 6,
    vidaMaxima = 4,
    danio = 0.5,
    imagenDaniado = "parcialTiradorDaniado.png",
    imagenEnemigo = "parcialTirador.png",
    imagenMuerto = "parcialTiradorMuerto.png"
) { }

class ParcialDivisible inherits EnemigoDivisible(
    nivel = 2,
    vida = 6,
    vidaMaxima = 6,
    danio = 0.5,
    imagenDaniado = "parcialDivisibleDaniado.png",
    imagenEnemigo = "parcialDivisible.png",
    imagenMuerto = "parcialDivisibleMuerto.png"
) { }

// Se dejan por si los tests los usan; las salas ya no los comparten
const parcialTirador = new ParcialTirador(position = game.at(20, 12))

const parcialDivisible = new ParcialDivisible(position = game.at(20, 8))
