# Explicaciones teóricas

## Explicaciones Teoricas y Justificacion del Diseño

### 1. Polimorfismo e Interfaces Implicitas

En Wollok, el polimorfismo se logra mediante interfaces implicitas: dos o mas objetos o clases son polimorficos cuando entienden el mismo conjunto de mensajes con el mismo significado, permitiendo intercambiarlos dinamicamente y evitando el uso innecesario de condicionales (`if/else`).

* **Comportamiento del Enemigo:** En lugar de preguntar con condicionales a que distancia se encuentra el estudiante, la clase `Enemigo` delega la decisión de su acción en una colección de estados (`atacando`, `persiguiendo`, `disparando`). Todos cumplen con la interfaz explícita `EstadoEnemigo` al entender los mensajes `aplicaA(enemigo)` y `actuar(enemigo)`. Esto permite agregar nuevos estados (ej. huyendo) sin modificar la clase `Enemigo`.

* **Sistema de Defensas y Daño:** Al recibir daño, el estudiante no evalúa con un `if` si tiene o no un escudo equipado. Simplemente ejecuta `defensa.absorberDanio(cantidad, self)`. Tanto `sinEscudo` como `DefensaEscudo` entienden el mensaje por ende son polimorficos y aportan tambien su sufijo visual (`sufijoVisual()`).
  * `sinEscudo`: Aplica el daño directamente a la vida del estudiante (`personaje.restarVida(cantidad)`).
  * `DefensaEscudo` (Clase): Absorbe el impacto restando durabilidad a su propio escudo y, al llegar a 0, desequipa la defensa restableciendo `sinEscudo`.

* **Efectos de Items en Pedestal:** Cuando el estudiante colisiona con un item de la sala del tesoro, no necesita conocer la clase concreta del recolectable. Solo le envía el mensaje `efecto(personaje)`. Las distintas subclases (`ConstanciaAprobado`, `ApuntesWollok`, `CafeDelBuffet`, `ItemEscudo`) responden polimorficamente aplicando su ventaja particular.

* **Direcciones de Movimiento:** Las direcciones (`haciaArriba`, `haciaAbajo`, `haciaLaDerecha`, `haciaLaIzquierda`, `quieto`) son objetos polimorficos que entienden los mensajes `posicionSig(objetoMovil)` y `esMovimiento()`.

* **Interfaz Implicita de Colisiones:** El contrato que forman los metodos `chocarProyectil()`, `chocarEnemigo()` y `chocarItem()`. Cuando dos elementos se tocan en el motor gráfico, no se pregunta por el "tipo" de objeto. Simplemente se envia el mensaje. Objetos conceptualmente distintos como el `estudiante`, el `Enemigo`, el `pedestal`, y los items entienden `chocarProyectil(proyectil)`, reaccionando de forma diferente pero respetando el mismo contrato polimorfico.

### 2. Herencia, Redefinicion y Template Method

Utilizamos herencia de clases para compartir estructura y comportamiento base, evitando la repeticion de codigo y permitiendo la redefinicion (`override`) cuando una subclase necesitaba un comportamiento especializado.

* **Carga de Salas y el Patron Template Method (Sala):** La clase base `Sala` define el algoritmo general para cambiar de habitacion mediante el metodo `cargar()`, el cual establece el fondo, dibuja las puertas y activa a los enemigos vivos. Dentro de esta secuencia, invoca al metodo gancho (hook) `cargarExtras()`. Subclases o salas especializadas como `salaDelTesoro` hacen override method `cargarExtras()` para incorporar el pedestal y el item aleatorio.

* **Jerarquia de Enemigos y Proyectiles:**
  * **Proyectiles:** `ProyectilEnemigo` hereda de `Proyectil`. Redefine `avanzar()` llamando a `super()` para ejecutar la traslacion espacial base, y añade la verificacion de colision directa contra la posicion del estudiante.
  * **Enemigos:** Las clases `EnemigoTirador`, `EnemigoDivisible` y `Parcial` heredan de la clase base `Enemigo`. Mientras que `Parcial` solo hereda para configurar un estado base de variables, las otras redefinen el metodo `morir()` invocando a `super()` para asegurar que desaparezca el objeto del tablero, pero agregando su logica propia (desactivar el temporizador o dividirse).

* **Ciclo de Vida de los Items (ItemPedestal):** La superclase `ItemPedestal` maneja el estado agarrado, la deteccion de colision y su posterior remocion del tablero (`game.removeVisual(self)`). Las subclases solo heredan esta estructura y redefinen el metodo abstracto `efecto(personaje)`.

* **El Buffer del Teclado (EstadoTeclas):** Se creo una clase base `EstadoTeclas` que concentra la logica matematica de sumar/restar coordenadas y ejecutar acciones con un buffer de tiempo. De ella heredan `estadoTeclasMovimiento` y `estadoTeclasDisparo` para no repetir esa estructura dos veces.

### 3. Delegacion y Cohesion (Separacion de Responsabilidades)

Buscamos que cada clase u objeto tenga una única responsabilidad clara y delegue las tareas complementarias en objetos especializados:

* **El Motor de Fisicas (Cuerpo y Hitbox):** Tanto el `estudiante` como el `Enemigo` no realizan calculos de coordenadas matematicas para gestionar sus areas de colision de 2x2 celdas. Ambos delegan instanciando un objeto `Cuerpo`, el cual agrupa y actualiza la posicion de las multiples instancias de `Hitbox`. A su vez, las `Hitbox` delegan los choques de vuelta a su dueño original (`duenio.chocarProyectil(...)`).

* **Gestion de Disparos (arma):** El personaje no crea ni administra el ciclo de vida de los proyectiles. Al disparar, le delega el mensaje `arma.disparar(self, direccion)`, siendo el objeto `arma` el responsable de instanciar la lagrima, agregarla al tablero e iniciar su movimiento.

* **Control del Espacio (movimiento):** El calculo de limites del mapa y la actualizacion de coordenadas se delega `movimiento` junto con la Direccion elegida.

### Uso de Colecciones y Bloques (Closures)

* **Gestión del Ciclo de Vida de Entidades:**
  * En la clase `Sala`, utilizamos listas para guardar los `enemigos`. Con `enemigos.all({ enemigo => enemigo.estaMuerto() })` validamos fácilmente si la habitación está despejada para habilitar las puertas.   
  * También filtramos a los enemigos con `enemigos.filter({ enemigo => !enemigo.estaMuerto() })` para activar únicamente a los vivos al momento de entrar a la sala, y usamos `forEach` para darles la orden de `aparecer()` o `retirar()`.   
* **Control de Impactos Complejos (`Cuerpo`):**
  * Para armar el volumen físico del personaje, la clase `Cuerpo` gestiona una colección `hitboxes` (múltiples instancias de la clase `Hitbox`). Cuando el cuerpo necesita actualizar su posición o removerse de la pantalla, simplemente delega la acción enviando un `forEach` a todos los elementos de su lista.   
* **Interfaz Dinámica (`hud`):**
  * Para generar la interfaz de salud, el objeto `hud` utiliza el mensaje `map` sobre un rango numérico (`1..estudiante.vidaMaxima()`) para crear una colección de instancias de `Corazon` y posicionarlas en la pantalla de forma escalable sin escribir el código visual para cada corazón individual.
# Diagrama
![Diagrama: ](<diagrama.png>)
