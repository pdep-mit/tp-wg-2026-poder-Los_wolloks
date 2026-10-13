import wollok.game.*
import personajes.*
import movimientos.*
import disparos.*
import items.*
import obstaculos.*


object config {
  method anchoMax() = 30
  
  method alturaMax() = 22
  
  method tamanioCelda() = 25
  

  method configurarJuego() {
    self.configurarVentana()
    salaDelTesoro.cargar()
    self.agregarComponentesVisuales()
    self.configurarAcciones()
    game.onTick(50, "dispararEstudiante", { estadoTeclasDisparo.procesar() })
  }
  
  method configurarVentana() {
    game.title("Los Wolloks | Isaac UTN")
    game.width(self.anchoMax())
    game.height(self.alturaMax())
    game.cellSize(self.tamanioCelda())
  }
  
  method agregarComponentesVisuales() {
  game.addVisual(estudiante)
  estudiante.agregarHitboxes()
  parcial.aparecer() // reemplaza addVisual + agregarHitboxes + iniciarMov
 }
  
  method configurarAcciones() {
    keyboard.w().onPressDo({ 
      estadoTeclasMovimiento.modificarY(1)
      estadoTeclasMovimiento.procesar()
    })
    keyboard.w().onReleaseDo({ 
      estadoTeclasMovimiento.modificarY(-1)
      estadoTeclasMovimiento.procesar()
    })

    keyboard.s().onPressDo({ 
      estadoTeclasMovimiento.modificarY(-1)
      estadoTeclasMovimiento.procesar()
    })
    keyboard.s().onReleaseDo({ 
      estadoTeclasMovimiento.modificarY(1)
      estadoTeclasMovimiento.procesar()
    })

    keyboard.d().onPressDo({ 
      estadoTeclasMovimiento.modificarX(1)
      estadoTeclasMovimiento.procesar()
    })
    keyboard.d().onReleaseDo({ 
      estadoTeclasMovimiento.modificarX(-1)
      estadoTeclasMovimiento.procesar()
    })

    keyboard.a().onPressDo({ 
      estadoTeclasMovimiento.modificarX(-1)
      estadoTeclasMovimiento.procesar()
    })
    keyboard.a().onReleaseDo({ 
      estadoTeclasMovimiento.modificarX(1)
      estadoTeclasMovimiento.procesar()
    })

    keyboard.up().onPressDo({ 
      estadoTeclasDisparo.modificarY(1)
      estadoTeclasDisparo.procesar()
    })
    keyboard.up().onReleaseDo({ 
      estadoTeclasDisparo.modificarY(-1)
      estadoTeclasDisparo.procesar()
    })

    keyboard.down().onPressDo({ 
      estadoTeclasDisparo.modificarY(-1)
      estadoTeclasDisparo.procesar()
    })
    keyboard.down().onReleaseDo({ 
      estadoTeclasDisparo.modificarY(1)
      estadoTeclasDisparo.procesar()
    })

    keyboard.right().onPressDo({ 
      estadoTeclasDisparo.modificarX(1)
      estadoTeclasDisparo.procesar()
    })
    keyboard.right().onReleaseDo({ 
      estadoTeclasDisparo.modificarX(-1)
      estadoTeclasDisparo.procesar()
    })

    keyboard.left().onPressDo({ 
      estadoTeclasDisparo.modificarX(-1)
      estadoTeclasDisparo.procesar()
    })
    keyboard.left().onReleaseDo({ 
      estadoTeclasDisparo.modificarX(1)
      estadoTeclasDisparo.procesar()
    })
  }
}

object salaDelTesoro {
  method fondo() = "sala-del-tesoro.png"
  
  // el item flota una celda arriba del pedestal
  method posicionDelItem() = pedestal.position().up(2)
  
  method cargar() {
    game.boardGround(self.fondo())
    game.addVisual(pedestal)
    
    const item = [
      new ConstanciaAprobado(position = self.posicionDelItem()),
      new ApuntesWollok(position = self.posicionDelItem()),
      new CafeDelBuffet(position = self.posicionDelItem())
    ].anyOne()
    game.addVisual(item)
    game.whenCollideDo(item, { otro => otro.chocarItem(item) })

    const obstaculos = [
    new Obstaculo(vida = 10, vidaMaxima = 10, danio = 0, position = game.at(25, 12), imagenBase = "banco.png", imagenDaniado = "bancoDaniado.png", imagenMuerto = "bancoDestruido.png"),
    new Obstaculo(vida = 10, vidaMaxima = 10, danio = 0, position = game.at(25, 11), imagenBase = "banco.png", imagenDaniado = "bancoDaniado.png", imagenMuerto = "bancoDestruido.png"),
    new Obstaculo(vida = 10, vidaMaxima = 10, danio = 0, position = game.at(25, 10), imagenBase = "banco.png", imagenDaniado = "bancoDaniado.png", imagenMuerto = "bancoDestruido.png"),
    new Obstaculo(vida = 10, vidaMaxima = 10, danio = 0, position = game.at(25, 9), imagenBase = "banco.png", imagenDaniado = "bancoDaniado.png", imagenMuerto = "bancoDestruido.png")
    ]

    obstaculos.forEach({ obstaculo => game.addVisual(obstaculo) })
  
  }

}

object pedestal {
  method position() = game.center().left(1).down(1)
  method esSolido() = false
  method image() = "pedestal.png"
  
  method chocarProyectil(proyectil) {
    proyectil.destruir()
  }
}