import pantallas.*
import wollok.game.*
import personajes.*
import movimientos.*
import disparos.*
import configGenerales.*
import mapa.*
import sonidos.*

// ------------------------------------------------------------
// Estados propios del jefe. Siguen el mismo protocolo que estados.wlk
// (aplicaA y actuar), asi que Enemigo.acercarseAenemigo() los usa tal cual.
// Si prefieren, se pueden mover a estados.wlk.
// ------------------------------------------------------------
object huyendo {
  method aplicaA(enemigo) = enemigo.estaCercaDelEstudiante()
  method actuar(enemigo) { enemigo.huir() }
}

object vigilando {
  method aplicaA(enemigo) = true
  method actuar(enemigo) { }
}

// ------------------------------------------------------------
// Una celda de la barra de vida. Su imagen depende de la vida del jefe.
// ------------------------------------------------------------
class SegmentoBarraJefe {
  const property position
  const indice
  const jefe

  method image() =
    if (jefe.vida() * 10 / jefe.vidaMaxima() > indice) "barraJefeLlena.png" else "barraJefeVacia.png"

  // los disparos y el estudiante la atraviesan sin efecto
  method chocarProyectil(proyectil) { }
  method chocarItem(item) { }
}

// ------------------------------------------------------------
// Jefe final:
//  - se aleja lentamente del estudiante cuando este se acerca
//  - le dispara periodicamente (mas rapido con la mitad de la vida)
//  - invoca mini parciales al bajar del 75%, 50% y 25% de su vida
//  - muestra una barra de vida arriba de la pantalla
// ------------------------------------------------------------
class JefeFinal inherits Enemigo {
  const distanciaSegura = 8
  const tiempoEntrePasos = 700
  const umbrales = [0.75, 0.5, 0.25]
  const minisPorOleada = [2, 2, 3]
  const desplazamientos = [game.at(-3, 0), game.at(3, 0), game.at(0, 3)]
  const minis = []
  const barra = []
  var puedeDisparar = true
  var activo = false
  var oleadasInvocadas = 0

  method nombreTickDisparo() = "jefe_dispara_" + self.identity().toString()

  // ---------- comportamiento (mismo mecanismo de estados que Enemigo) ----------
  override method estados() = [huyendo, vigilando]

  method estaCercaDelEstudiante() =
    self.position().distance(estudiante.position()) < distanciaSegura

  override method iniciarMov() {
    game.onTick(tiempoEntrePasos, self.nombreTick(), { self.acercarseAenemigo() })
    game.onTick(500, self.nombreTickDisparo(), { self.disparar() })
  }

  // De las 4 direcciones, elige la que lo deja mas lejos del estudiante.
  // Si ninguna lo aleja (pared o esquina), se queda quieto.
  method huir() {
    const distanciaActual = self.position().distance(estudiante.position())
    const mejor = [haciaArriba, haciaAbajo, haciaLaDerecha, haciaLaIzquierda]
      .max({ direccion => direccion.posicionSig(self).distance(estudiante.position()) })
    if (mejor.posicionSig(self).distance(estudiante.position()) > distanciaActual) {
      self.intentarMoverse(mejor)
    }
  }

  // ---------- disparo (usa arma, como ParcialProlog) ----------
  method enFaseFinal() = self.vida() <= self.vidaMaxima() / 2

  // arma.disparar le pregunta cuanto tarda en recargar
  method velocidadAtaque() = if (self.enFaseFinal()) 1300 else 1800

  method finalizarRecarga() {
    puedeDisparar = true
  }

  method disparar() {
    if (puedeDisparar and not self.estaMuerto()) {
      puedeDisparar = false
      arma.disparar(self, self.direccionAlEstudiante())
    }
  }

  // ---------- oleadas de mini parciales ----------
  override method recibirDanio(cantidad) {
    super(cantidad)
    if (not self.estaMuerto()) {
      self.revisarUmbrales()
    }
  }

  method revisarUmbrales() {
    const cruzados = umbrales.count({ umbral => self.vida() <= self.vidaMaxima() * umbral })
    if (cruzados > oleadasInvocadas) {
      self.invocarOleada()
    }
  }

  method invocarOleada() {
    self.limpiarMinisMuertos()

    const cantidad = minisPorOleada.get(oleadasInvocadas)
    oleadasInvocadas += 1

    game.say(self, "¡A rendir el recuperatorio!")
    desplazamientos.take(cantidad).forEach({ desplazamiento => self.invocarMiniEn(desplazamiento) })
  }

  method invocarMiniEn(desplazamiento) {
    const mini = new Enemigo(
      vida = 2,
      vidaMaxima = 2,
      danio = 0.5,
      position = self.posicionDentroDelTablero(
        self.position().x() + desplazamiento.x(),
        self.position().y() + desplazamiento.y()
      ),
      imagenDaniado = "parcialChicoDaniado.png",
      imagenEnemigo = "parcialChico.png",
      imagenMuerto = "parcialChicoMuerto.png"
    )
    minis.add(mini)
    mini.aparecer()
  }

  // los personajes miden 2x2, igual que el limite que usa movimiento
  method posicionDentroDelTablero(x, y) = game.at(
    x.limitBetween(0, config.anchoMax() - 2),
    y.limitBetween(0, config.alturaMax() - 2)
  )

  // ---------- barra de vida ----------
  method mostrarBarra() {
    const inicio = config.anchoMax().div(2) - 5
    (0..9).forEach({ i =>
      const segmento = new SegmentoBarraJefe(
        position = game.at(inicio + i, config.alturaMax() - 1),
        indice = i,
        jefe = self
      )
      barra.add(segmento)
      game.addVisual(segmento)
    })
  }

  method ocultarBarra() {
    barra.forEach({ segmento => game.removeVisual(segmento) })
    barra.clear()
  }

  // ---------- entrar y salir de la sala ----------
  // Si el estudiante vuelve a la sala, los minis que seguian vivos reaparecen.
  override method aparecer() {
    super()
    activo = true
    self.mostrarBarra()
    minis.filter({ mini => not mini.estaMuerto() }).forEach({ mini => mini.aparecer() })
  }

  override method morir() {
    game.removeTickEvent(self.nombreTickDisparo())
    self.ocultarBarra()
    game.say(self, "Bueno, te dejo pasar...")
    // al caer el jefe, los mini parciales caen con el
     minis.filter({ mini => not mini.estaMuerto() })
         .forEach({ mini => mini.recibirDanio(mini.vida()) })
    super()
    
    sonidos.detenerSonidoFondo()
    game.schedule(1000,{gestorPantallas.mostrarVictoria()})
  }

  override method retirar() {
    if (activo) {
      activo = false
      if (not self.estaMuerto()) {
        game.removeTickEvent(self.nombreTickDisparo())
      }
      self.ocultarBarra()
      self.limpiarMinisMuertos()
      minis.forEach({ mini => mini.retirar() })
    }
    super()
  }


  method limpiarMinisMuertos() {
    minis.filter({ mini =>
        mini.estaMuerto() and not game.hasVisual(mini)
    }).forEach({ mini =>
        minis.remove(mini)
    })
  }

  override method reiniciar() {
    super()
    oleadasInvocadas = 0
    minis.clear()
    puedeDisparar = true
    activo = false
  }
}

const jefeFinal = new JefeFinal(
  vida = 25,
  vidaMaxima = 25,
  danio = 0.5,
  position = game.at(22, 10),
  imagenDaniado = "jefeDaniado.png",
  imagenEnemigo = "jefe.png",
  imagenMuerto = "jefeMuerto.png"
)

// Sala del jefe: se entra por la derecha de salaC.
// Su puerta de vuelta se abre solo cuando el jefe esta derrotado.
object salaDelJefe inherits Sala(fondo = "sala-normal.png", enemigos = [jefeFinal],sonidoFondo = "salaFinal.mp3") {
  override method puertas() = [self.puertaIzquierda(salaC)]
}
