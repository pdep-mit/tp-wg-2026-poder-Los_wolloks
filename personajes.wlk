import wollok.game.*
import movimientos.*
import estados.*
import hitbox.*
import cuerpo_personajes.*
import hud.*
import mapa.*
import disparos.*
object estudiante {

    var property vidaMaxima = 3 
    var property vida = 3
    var property danio = 1
    var property velocidad  = 1
    var property puedeDisparar = true
    var property puedeMoverse = true
    var property velocidadAtaque = 800

    var position = game.at(8, 8)

    method position() = position

    const cuerpo = new Cuerpo(duenio = self)

    method position(nueva) {
    position = nueva
    cuerpo.seguirA()
    }

    method agregarHitboxes() { cuerpo.agregar() }

    method tiempoEntrePasos()=(200 - (velocidad * 20)).max(50)
    method seMueveParaLaderecha()=estadoTeclasMovimiento.x()==1
    
    method mover(direccion) {
 
    if (puedeMoverse and direccion.esMovimiento()) {
      movimiento.mover(self, direccion)
      mapa.revisarPuertas()
      puedeMoverse = false
      
      game.schedule(self.tiempoEntrePasos(), {
        puedeMoverse = true
        self.intentarSeguirMoviendose()
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
    
    return "estudiante" + self.sufijoSalud() + self.sufijoDireccion() + ".png"
  }

  method sufijoSalud() = if (vida <= vidaMaxima / 3) "_daniado" else ""
  
  method sufijoDireccion() = if (self.seMueveParaLaderecha()) "_der" else "_izq"

    method disparar(arma,direccion){
        if(puedeDisparar and direccion.esMovimiento()){
      self.puedeDisparar(false)
            arma.disparar(self,direccion)
        }
    }

    method finalizarRecarga(){
        self.puedeDisparar(true)
    }

    method chocarEnemigo(enemigo){
        self.recibirDanio(enemigo.danio())
    }

    method disparaContraEstudiante() = false

    // solo lo lastiman los proyectiles de los enemigos
    method chocarProyectil(proyectil){
        if (proyectil.contraEstudiante()) {
            self.recibirDanio(proyectil.danio())
            proyectil.destruir()
        }
    }

    method recibirDanio(cantidad) {
        vida = 0.max(vida - cantidad) 
        
        if (vida == 0) {
            self.morir()
        }
    }
    method morir(){
    velocidad=0
    puedeDisparar=false
    game.say(self,"Nos vemos en el recu")
    game.schedule(1000,{game.removeVisual(self)})
    game.schedule(300,{game.stop()})
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
    
    var position

    method position() = position

    const cuerpo = new Cuerpo(duenio = self)

    method position(nueva) {
    position = nueva
    cuerpo.seguirA()
    }

    var enEscena = false

    method nombreTick() = "enemigo_persigue_" + self.identity().toString()

    method iniciarMov(){
        game.onTick(500, self.nombreTick(), { self.acercarseAenemigo() })
    }

    method disparaContraEstudiante() = true
    // solo lo lastiman los proyectiles del estudiante
    method chocarProyectil(proyectil){
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

    method chocarItem(item) { }

    // Pone al enemigo en el juego
    method aparecer() {
    game.addVisual(self)
    cuerpo.agregar()
    enEscena = true
    self.iniciarMov()
}

}
// Enemigo que persigue al estudiante (usa los estados por defecto: atacando / persiguiendo)
class ParcialFuncional inherits Enemigo(
    vida = 5,
    vidaMaxima = 5,
    danio = 0.5,
    imagenDaniado = "parcialDaniado.png",
    imagenEnemigo = "parcial.png",
    imagenMuerto = "parcialMuerto.png"
) { }

// Enemigo que no se mueve: dispara hacia donde está el estudiante
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
            arma.disparar(self, self.direccionAlEstudiante())
        }
    }

    method direccionAlEstudiante() {
        const dx = estudiante.position().x() - self.position().x()
        const dy = estudiante.position().y() - self.position().y()
        if (dx.abs() >= dy.abs()) {
            if (dx >= 0) { return haciaLaDerecha }
            return haciaLaIzquierda
        }
        if (dy >= 0) { return haciaArriba }
        return haciaAbajo
    }
}
