import wollok.game.*
import personajes.*
import items.*
import disparos.*
import configGenerales.*
import jefe.*
import sonidos.*

// ------------------------------------------------------------
// Puerta: salida en el borde de una sala que lleva a otra sala.
// Se dibuja como una flecha hacia donde se sale, y como una cruz
// mientras esté cerrada (hasta aprobar a todos los parciales de su sala).
// ------------------------------------------------------------
class Puerta {
  const property position
  const destino
  const aparecerEn
  const origen
  const property imagenAbierta

  method image() = if (self.estaAbierta()) imagenAbierta else "cruz.png"

  method estaAbierta() = origen.estaLimpia()

  // tanto la flecha como el estudiante ocupan 2x2 celdas: se tocan si sus cuadrados se superponen
  method estaTocadaPor(personaje) {
    const posicionPersonaje = personaje.position()
    const tocaEnX = (position.x() - posicionPersonaje.x()).abs() <= 1
    const tocaEnY = (position.y() - posicionPersonaje.y()).abs() <= 1
    return tocaEnX and tocaEnY
  }

  method atravesar() {
    if (self.estaAbierta()) {
      mapa.cambiarA(destino, aparecerEn)
      sonidos.abrirPuerta()
    } else {
      game.say(estudiante, "Primero hay que aprobar a todos los parciales")
    }
  }

  method chocarProyectil(proyectil) { proyectil.destruir() }
  method chocarItem(item) { }
}

// ------------------------------------------------------------
// Sala: conoce su fondo, su colección de enemigos y sus puertas.
// cargar() y descargar() son template methods: las subclases
// (por ahora SalaDelTesoro) agregan cosas con los "extras".
// ------------------------------------------------------------
class Sala {
  const property fondo
  const property enemigos
  const itemsSueltos = []
  const enemigosAgregados = []
  var puertasCargadas = []
  const property sonidoFondo 

  method puertas() = []

  method cargar() {
    game.boardGround(fondo)
    puertasCargadas = self.puertas()
    puertasCargadas.forEach({ puerta => game.addVisual(puerta) })
    self.enemigosVivos().forEach({ enemigo => enemigo.aparecer() })
    self.itemsSinAgarrar().forEach({ item => self.mostrarItemSuelto(item) })
    self.cargarExtras()
    sonidos.sonidoFondoSala(self)
  }

  method descargar() {
    enemigos.forEach({ enemigo => enemigo.retirar() })
    puertasCargadas.forEach({ puerta => game.removeVisual(puerta) })
    puertasCargadas = []
    self.itemsSinAgarrar().forEach({ item => game.removeVisual(item) })
    self.descargarExtras()
  }

  method reiniciar() {
    itemsSueltos.clear()
    // los enemigos que aparecieron en medio de la partida (hijos del divisible) se descartan
    enemigos.removeAll(enemigosAgregados)
    enemigosAgregados.clear()
    enemigos.forEach({ enemigo => enemigo.reiniciar() }) // restaurar vida = vidaMaxima
  }

  // Un enemigo que aparece en medio de la partida (por ejemplo, los que suelta
  // el parcial divisible) pasa a ser de la sala: hay que derrotarlo para abrir las puertas.
  method agregarEnemigo(enemigo) {
    enemigos.add(enemigo)
    enemigosAgregados.add(enemigo)
    enemigo.aparecer()
  }

  // Un ítem que se suelta en la sala se queda en esta sala (no viaja a la siguiente).
  method soltarItem(item) {
    itemsSueltos.add(item)
    self.mostrarItemSuelto(item)
  }

  method mostrarItemSuelto(item) {
    game.addVisual(item)
    game.whenCollideDo(item, { otro => otro.chocarItem(item) })
  }

  method itemsSinAgarrar() = itemsSueltos.filter({ item => !item.fueAgarrado() })

  method cargarExtras() { }
  method descargarExtras() { }

  method enemigosVivos() = enemigos.filter({ enemigo => !enemigo.estaMuerto() })

  method estaLimpia() = enemigos.all({ enemigo => enemigo.estaMuerto() })

  method revisarPuertas(personaje) {
    const tocadas = puertasCargadas.filter({ puerta => puerta.estaTocadaPor(personaje) })
    tocadas.forEach({ puerta => puerta.atravesar() })
  }

  // --- posiciones de las puertas y de dónde aparece el estudiante en la otra sala ---
  method xMedio() = config.anchoMax().div(2) - 1
  method yMedio() = config.alturaMax().div(2) - 1

  method salidaArriba() = game.at(self.xMedio(), config.alturaMax() - 2)
  method llegadaDesdeAbajo() = game.at(self.xMedio() - 1, 2)

  method puertaDerecha(destino) = new Puerta(
    position = game.at(config.anchoMax() - 2, self.yMedio()),
    destino = destino,
    aparecerEn = game.at(2, self.yMedio() - 1),
    origen = self,
    imagenAbierta = "flecha_derecha.png"
  )

  method puertaIzquierda(destino) = new Puerta(
    position = game.at(0, self.yMedio()),
    destino = destino,
    aparecerEn = game.at(config.anchoMax() - 4, self.yMedio() - 1),
    origen = self,
    imagenAbierta = "flecha_izquierda.png"
  )

  method puertaArriba(destino) = new Puerta(
    position = self.salidaArriba(),
    destino = destino,
    aparecerEn = self.llegadaDesdeAbajo(),
    origen = self,
    imagenAbierta = "flecha_arriba.png"
  )

  method puertaAbajo(destino) = new Puerta(
    position = game.at(self.xMedio(), 0),
    destino = destino,
    aparecerEn = game.at(self.xMedio() - 1, config.alturaMax() - 4),
    origen = self,
    imagenAbierta = "flecha_abajo.png"
  )
}

// ------------------------------------------------------------
// Sala del tesoro: tiene un pedestal con un ítem al azar (que se
// elige una sola vez, así no reaparece otro distinto al volver).
// Cada sala del tesoro hereda de acá y solo dice a dónde vuelve.
// ------------------------------------------------------------
class SalaDelTesoro inherits Sala {
  var item = null

  // el item flota dos celdas arriba del pedestal
  method posicionDelItem() = pedestal.position().up(2)

  method itemDeLaSala() {
    if (item == null) {
      item = [
        new ConstanciaAprobado(position = self.posicionDelItem(),sonido_pick = "recoger_items.mp3"),
        new ApuntesWollok(position = self.posicionDelItem(),sonido_pick = "recoger_items.mp3"),
        new CafeDelBuffet(position = self.posicionDelItem(),sonido_pick = "recoger_items.mp3")
      ].anyOne()
    }
    return item
  }

  override method cargarExtras() {
    game.addVisual(pedestal)
    const elegido = self.itemDeLaSala()
    if (!elegido.fueAgarrado()) {
      game.addVisual(elegido)
      game.whenCollideDo(elegido, { otro => otro.chocarItem(elegido) })
    }
  }

  override method descargarExtras() {
    game.removeVisual(pedestal)
    if (item != null and !item.fueAgarrado()) {
      game.removeVisual(item)
    }
  }

  // al reiniciar se elige un ítem nuevo (el anterior ya pudo haber sido agarrado)
  override method reiniciar() {
    super()
    item = null
  }
}

// ------------------------------------------------------------
// Mapa: todo en línea hacia la derecha, y arriba de cada sala con
// enemigos hay una sala del tesoro que se abre al limpiarla.
//
//    [Tesoro]    [Tesoro C]   [Tesoro D]
//       |            |            |
//  [Inicio] -> [B] -> [C]  ->    [D]
// ------------------------------------------------------------
object salaInicio inherits Sala(fondo = "sala-normal.png", enemigos = [],sonidoFondo="salaInicioo.mp3") {
  override method puertas() = [self.puertaDerecha(salaB)]
}

// Sala B: dos parciales comunes (clase Parcial, imagen parcial.png).
object salaB inherits Sala(fondo = "sala-normal.png",enemigos = [new ParcialDivisible(position = game.at(20, 16)),new Parcial(position = game.at(20, 4))],sonidoFondo="salaIntermedia.mp3") {
 const property salaCompletada = "salaCompletada.mp3"
 var salaYaCompletada = false

 override method estaLimpia() {
    const limpia = enemigos.all({ enemigo => enemigo.estaMuerto() })

    if (limpia and !salaYaCompletada) {
        salaYaCompletada = true
        sonidos.salaCompletada()
    }

    return limpia
 }
  override method puertas() = [
    self.puertaIzquierda(salaInicio),
    self.puertaDerecha(salaC),
    self.puertaArriba(salaDelTesoro)
  ]
}

// Sala C: un parcial Prolog (tirador).
object salaC inherits Sala( fondo = "sala-normal.png", enemigos = [new ParcialTirador(position = game.at(20, 10))],sonidoFondo="salaIntermedia.mp3") {
  const property salaCompletada = "salaCompletada.mp3"
  var salaYaCompletada = false

  override method estaLimpia() {
      const limpia = enemigos.all({ enemigo => enemigo.estaMuerto() })

      if (limpia and !salaYaCompletada) {
          salaYaCompletada = true
          sonidos.salaCompletada()
      }

      return limpia
  } 
 
  override method puertas() = [
    self.puertaIzquierda(salaB),
    self.puertaDerecha(salaD),
    self.puertaArriba(salaDelTesoroC)
  ]
  
}

// Sala D: un parcial divisible y un parcial tirador.
object salaD inherits Sala( fondo = "sala-normal.png",enemigos = [new Parcial(position = game.at(20, 16)),new ParcialTirador(position = game.at(20, 4))],sonidoFondo="salaIntermedia.mp3") {
  const property salaCompletada = "salaCompletada.mp3"
  var salaYaCompletada = false

  override method estaLimpia() {
      const limpia = enemigos.all({ enemigo => enemigo.estaMuerto() })

      if (limpia and !salaYaCompletada) {
          salaYaCompletada = true
          sonidos.salaCompletada()
      }

      return limpia
  }
  override method puertas() = [
    self.puertaIzquierda(salaC),
    self.puertaArriba(salaDelTesoroD),
    self.puertaDerecha(salaDelJefe)
  ]
}


object salaDelTesoro inherits SalaDelTesoro(fondo = "sala-del-tesoro.png", enemigos = [],sonidoFondo="salaTesoro.mp3") {
  override method puertas() = [self.puertaAbajo(salaB)]
}

object salaDelTesoroC inherits SalaDelTesoro(fondo = "sala-del-tesoro.png", enemigos = [],sonidoFondo="salaTesoro.mp3") {
  override method puertas() = [self.puertaAbajo(salaC)]
}

object salaDelTesoroD inherits SalaDelTesoro(fondo = "sala-del-tesoro.png", enemigos = [],sonidoFondo="salaTesoro.mp3") {
  override method puertas() = [self.puertaAbajo(salaD)]
}

object pedestal {
  method position() = game.center().left(1).down(1)

  method image() = "pedestal.png"

  method chocarProyectil(proyectil) {
    proyectil.destruir()
  }
}

// ------------------------------------------------------------
// El mapa conoce las salas y cuál es la actual.
// ------------------------------------------------------------
object mapa {
  const property salas = [salaInicio, salaB, salaC, salaD, salaDelJefe, salaDelTesoro, salaDelTesoroC, salaDelTesoroD]
  var property salaActual = salaInicio

  method iniciar() {
    salaActual.cargar()
  }

  method cambiarA(sala, posicionDelEstudiante) {
    salaActual.descargar()
    arma.limpiar()
    salaActual = sala
    estudiante.position(posicionDelEstudiante)
    sala.cargar()
  }

  method revisarPuertas() {
    salaActual.revisarPuertas(estudiante)
  }

  method todasLasSalasLimpias() = salas.all({ sala => sala.estaLimpia() })

  method reiniciar(){
    salaActual = salaInicio
    salas.forEach{sala => sala.reiniciar()}
  }
}
