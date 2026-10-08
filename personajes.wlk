import wollok.game.*
import movimientos.*
object estudiante {
var property position = game.at(4,4)
var property vidaMaxima = 3 
var property vida = 3
var property danio = 1
var property velocidad  = 1
var property puedeDisparar = true
var property velocidadAtaque = 500

method image() {
    if (vida<=vidaMaxima/3) {
        return "estudiante_danio.png"
    }
    else{
        return "estudiante.png"
    }
}
    method disparar(arma,direccion){
        if(puedeDisparar){
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
    method chocarProyectil(proyectil){
    
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
}   

  method chocarItem(item) {
    item.chocarEstudiante(self)
  }

}



class Enemigo {
    var property vida   
    var property vidaMaxima
    var property danio
    var property position //deberia setearse al crear el enemigo
    var property velocidad = 1
    
    var property imagenDaniado 
    var property imagenEnemigo 
    var property imagenMuerto 
    
    method iniciarMov(){
        game.onTick(1000, "enemigo_persigue_" + self.identity().toString(), { self.acercarseAenemigo() })
    }
    method chocarProyectil(proyectil){
    self.recibirDanio(proyectil.danio())
    proyectil.destruir()
    }
    method recibirDanio(cantidad) {
        vida = 0.max(vida - cantidad) 
        
        if (vida == 0) {
            self.morir()
        }
    }
    
    method morir() {
        game.removeTickEvent("enemigo_persigue_" + self.identity().toString())
        
        game.schedule(800, { game.removeVisual(self) })
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
    
    method acercarseAenemigo() {
        if (self.estaAlLadoDelEstudiante()) {
            estudiante.chocarEnemigo(self)
        } else {
            movimiento.mover(self, self.direccionHorizontal())
            movimiento.mover(self, self.direccionVertical())
        }
    }

    method estaAlLadoDelEstudiante() {
        return position.distance(estudiante.position()) <= 1.5
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

}
const parcial = new Enemigo(
    vida = 5, 
    vidaMaxima = 5,
    danio = 0.5,
    position = game.at(7,8), 
    imagenDaniado = "parcialDaniado.png", 
    imagenEnemigo = "parcial.png", 
    imagenMuerto = "parcialMuerto.png"
)

