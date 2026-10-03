import wollok.game.*
object arma {
  method disparar(tirador,direccionDisparo) {
   const nuevaLagrima  = new Proyectil(
    position=tirador.position(),
    direccion=direccionDisparo) 
    game.addVisual(nuevaLagrima)
    nuevaLagrima.iniciarMov()
  }
}

class Proyectil  {
  var property position
  var property direccion
  var property velocidad = 1

  method image() = "lagrima.png"  

  method iniciarMov(){
    game.onTick(200,"lagrima_nro_" + self.identity().toString()  , {self.avanzar()})
      }
 method avanzar(){
    const nuevaPos=direccion.posicionSig(self)
    if(nuevaPos==self.position()){
        self.destruir()
    }
    else{
        self.position(nuevaPos)
    }
 }
method destruir(){
    game.removeVisual(self)
    game.removeTickEvent("lagrima_nro" + self.identity().toString())
}
}