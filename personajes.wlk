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
    var property position //me falta que se mueva solo y persiga al jugador
    
    var property imagenDaniado 
    var property imagenEnemigo 
    var property imagenMuerto 
    
    
    method recibirDanio(cantidad) {
        vida = 0.max(vida - cantidad) 
        
        if (vida == 0) {
            self.morir()
        }
    }
    
    method morir() {
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
