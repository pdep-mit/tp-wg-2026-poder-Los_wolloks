import wollok.game.*
import personajes.*
import movimientos.*
import disparos.*
import items.*
import hud.*
import mapa.*
import pantallas.*



object config {
  method anchoMax() = 30
  
  method alturaMax() = 22
  
  method tamanioCelda() = 25
  

  method configurarJuego() {
    self.configurarVentana()
    gestorPantallas.mostrarIntro()
  }

  //Despues de la intro
  method iniciarPartida() {
    mapa.iniciar()
    self.agregarComponentesVisuales()
    self.configurarAcciones()
    game.onTick(50, "dispararEstudiante", {
      if (estadoTeclasDisparo.estaActivo()) {
        estadoTeclasDisparo.procesar()
      }
    })
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
  hud.cargarCorazones()
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
