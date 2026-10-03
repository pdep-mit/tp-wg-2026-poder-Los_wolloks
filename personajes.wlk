import wollok.game.*
object estudiante {
var property position = game.at(4,4)
var property vidaMaxima = 3 
var property vida = 3
var property danio = 1
var property velocidad  = 1

method image() {
    if (vida<=vidaMaxima/3) {
        return "estudiante_danio.png"
    }
    else{
        return "estudiante.png"
    }


  
}

}