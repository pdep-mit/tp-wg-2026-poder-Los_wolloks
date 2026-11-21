import wollok.game.*
import personajes.*
import items.*
import disparos.*
import configGenerales.*
import jefe.*

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
  const imagenAbierta

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
// (por ahora salaDelTesoro) agregan cosas con los "extras".
// ------------------------------------------------------------
class Sala {
  const property fondo
  const property enemigos
  var puertasCargadas = []

  method puertas() = []

  method cargar() {
    game.boardGround(fondo)
    puertasCargadas = self.puertas()
    puertasCargadas.forEach({ puerta => game.addVisual(puerta) })
    self.enemigosVivos().forEach({ enemigo => enemigo.aparecer() })
    self.cargarExtras()
  }

  method descargar() {
    enemigos.forEach({ enemigo => enemigo.retirar() })
    puertasCargadas.forEach({ puerta => game.removeVisual(puerta) })
    puertasCargadas = []
    self.descargarExtras()
  }

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
    position = game.at(self.xMedio(), config.alturaMax() - 2),
    destino = destino,
    aparecerEn = game.at(self.xMedio() - 1, 2),
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
// Mapa:
//
//              [Tesoro]
//   [Inicio] -  [B]  -  [C]
//               [D]
// ------------------------------------------------------------
object salaInicio inherits Sala(fondo = "sala-normal.png", enemigos = []) {
  override method puertas() = [self.puertaDerecha(salaB)]
}

object salaB inherits Sala(
  fondo = "sala-normal.png",
  enemigos = [
    parcialTirador,//queda asi por ahora para que no tire error
    parcialDivisible

  ]
) {
  override method puertas() = [
    self.puertaIzquierda(salaInicio),
    self.puertaDerecha(salaDelJefe),
    self.puertaArriba(salaDelTesoro),
    self.puertaAbajo(salaD)
  ]
}

object salaC inherits Sala(
  fondo = "sala-normal.png",
  enemigos = [
    parcialTirador, //queda asi por ahora para que no tire error
    parcialDivisible
  ]
) {
  override method puertas() = [self.puertaIzquierda(salaB)]
}

object salaD inherits Sala(
  fondo = "sala-normal.png",
  enemigos = [
   parcialTirador,
   parcialDivisible
  ]
) {
  override method puertas() = [self.puertaArriba(salaB)]
}

object salaDelTesoro inherits Sala(fondo = "sala-del-tesoro.png", enemigos = []) {
  var item = null

  // el item flota dos celdas arriba del pedestal
  method posicionDelItem() = pedestal.position().up(2)

  // se elige una sola vez, así no reaparece otro distinto al volver
  method itemDeLaSala() {
    if (item == null) {
      item = [
        new ConstanciaAprobado(position = self.posicionDelItem()),
        new ApuntesWollok(position = self.posicionDelItem()),
        new CafeDelBuffet(position = self.posicionDelItem())
      ].anyOne()
    }
    return item
  }

  override method puertas() = [self.puertaAbajo(salaB)]

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
  const property salas = [salaInicio, salaB, salaC, salaD, salaDelTesoro, salaDelJefe]
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
}
