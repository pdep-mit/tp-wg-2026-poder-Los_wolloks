import wollok.game.*
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
    game.schedule(2000,{game.stop()})
  }


}



class Enemigo {
    var property vida   
    var property vidaMaxima
    var property danio
    var property position //deberia setearse al crear el enemigo
    
    var property imagenDaniado 
    var property imagenEnemigo 
    var property imagenMuerto 
    
    method iniciarMov(){
        game.onTick(500, "enemigo_persigue_" + self.identity().toString(), { self.acercarseA() })

        game.onCollideDo(self, {objetoChoque => objetoChoque.recibirDanio(danio)})
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
    
    method acercarseA() {
        var nuevaPosicion = position
        
        if (position.x() < estudiante.position().x()) {
            nuevaPosicion = nuevaPosicion.right(1)
        } else if (position.x() > estudiante.position().x()) {
            nuevaPosicion = nuevaPosicion.left(1)
        }
        
        if (position.y() < estudiante.position().y()) {
            nuevaPosicion = nuevaPosicion.up(1)
        } else if (position.y() > estudiante.position().y()) {
            nuevaPosicion = nuevaPosicion.down(1)
        }
        
        position = nuevaPosicion
    }

}
const parcial = new Enemigo(
    vida = 5, 
    vidaMaxima = 5,
    danio = 1.5,
    position = game.at(7,8), 
    imagenDaniado = "parcialDaniado.png", 
    imagenEnemigo = "parcial.png", 
    imagenMuerto = "parcialMuerto.png"
)
