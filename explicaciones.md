# Explicaciones teóricas

## Polimorfismo

Lo usamos bastante en el juego, uno de los ejemplos más claros es cómo
manejamos los estados de los enemigos, en `Enemigo.acercarseAenemigo()`
buscamos dentro de `estados()` cual es el estado que corresponde usando
`find`, y después ejecutamos `actuar(self)`, tanto `atacando` como
`persiguiendo` entienden los mismos mensajes (`aplicaA` y `actuar`),
pero hacen cosas distintas, de esta manera el enemigo no necesita
tener un montón de "if's y else's" para decidir qué hacer.

El jefe final también aprovecha esto. Redefine `estados()` para devolver
`huyendo` y `vigilando`, en lugar de los estados comunes, de esta manera
puede usar el mismo mecanismo que los demás enemigos (parciales),
pero con comportamientos propios.

Otros lugares donde se usó polimorfismo:

-   **`defensa`:** cuando el estudiante recibe daño, simplemente hace
    `defensa.absorberDanio(cantidad, self)`, hay 2 caminos posibles:
    1. Si tiene `sinEscudo`, el daño se descuenta de su vida.
    2. Si tiene una `DefensaEscudo`, primero se descuenta de la vida
    del escudo y, cuando llega a cero, vuelve a `sinEscudo`.
    El estudiante no necesita preguntar qué defensa tiene equipada.
-   **`efecto(personaje)`:** todos los ítems del pedestal entienden este
    mensaje, pero cada uno hace algo diferente. `ConstanciaAprobado`
    aumenta la vida, `ApuntesWollok` aumenta el daño y `CafeDelBuffet`
    reduce el tiempo entre disparos, así podemos agregar otro ítem sin
    tener que modificar la forma en que el estudiante los recoge.
-   **Direcciones:** `haciaArriba`, `haciaAbajo`, `haciaLaDerecha`,
    `haciaLaIzquierda` y `quieto` son objetos que entienden
    `posicionSig(objetoMovil)` y `esMovimiento()`. El movimiento puede
    trabajar con cualquiera de ellos sin necesitar saber qué dirección
    recibió
-   **Colisiones:** usamos mensajes como `chocarProyectil()` y
    `chocarItem()` para que los objetos reaccionen cuando se encuentran
    Un ejemplo es que el estudiante y los enemigos responden de manera
    diferente cuando reciben un proyectil. También hay objetos como
    `Puerta` o `SegmentoBarraJefe` que tienen sus propias respuestas a
    las colisiones

## Colecciones

-   **`Sala.enemigos`:** usamos una lista para guardar los enemigos de
    cada habitación. Con `filter` obtenemos los que siguen vivos
    (`enemigosVivos()`) y con `all` comprobamos si todos murieron para
    saber si se puede abrir la puerta. También usamos `forEach` para
    hacer aparecer o retirar a los enemigos cuando entramos o salimos de
    una sala.
-   **Enemigos cercanos:** en `Enemigo.companierosVivos()` filtramos los
    enemigos de la sala actual para quedarnos con los compañeros que
    siguen vivos y no incluir al propio enemigo. Después usamos `any` en
    `companieroCercaDe()` para saber si alguno está demasiado cerca de
    una posición. Esto sirve para evitar que los enemigos se amontonen
    al perseguir al estudiante.
-   **`Sala.itemsSueltos`:** guardamos los ítems que se sueltan durante
    la partida. Usamos `filter` en `itemsSinAgarrar()` para mostrar
    solamente los que todavía no fueron recogidos.
-   **`Cuerpo.hitboxes`:** guardamos las hitboxes de cada personaje en
    una lista, con `forEach` las agregamos al juego y también las
    retiramos cuando el personaje sale de escena.
-   **`arma.proyectilesActivos`:** tenemos una lista con los proyectiles
    que están en juego, cuando cambiamos de sala usamos `limpiar()` para
    destruirlos y evitar que queden disparos de la habitación anterior.
-   **`HUD`:** usamos `map` sobre el rango `1..estudiante.vidaMaxima()`
    para crear los corazones, hacemos algo parecido con los escudos,
    así no tenemos que crear cada corazón o escudo por separado y
    la cantidad se adapta a la vida que tenga el estudiante.

## Herencia

-   **`Enemigo` → `EnemigoTirador` / `EnemigoDivisible`:** los dos
    heredan de `Enemigo`, porque comparten cosas como la vida, el daño,
    el movimiento, las colisiones y la forma de morir, `EnemigoTirador`
    agrega los disparos y `EnemigoDivisible` hace que al morir aparezcan
    enemigos más chicos
-   **Clases de parciales:** `Parcial` hereda de `Enemigo` y define los
    valores iniciales y las imágenes del parcial común. `ParcialTirador`
    hereda de `EnemigoTirador` y `ParcialDivisible` de
    `EnemigoDivisible`, así podemos tener distintos tipos de parciales
    reutilizando los comportamientos que ya están definidos.
-   **`JefeFinal` → `Enemigo`:** el jefe también hereda de `Enemigo`,
    porque comparte varias características básicas con los demas.
    Después redefine algunos métodos como `iniciarMov()`, `morir()` y
    `recibirDanio()` para agregar sus propios comportamientos
-   **`ProyectilEnemigo` → `Proyectil`:** comparte con los proyectiles
    comunes la posición, dirección, daño y movimiento, redefine
    `image()` para tener otra imagen y `avanzar()` para comprobar si
    llega hasta el estudiante, también redefine `detectarChoques()`
    porque los proyectiles enemigos manejan el impacto de otra manera.
-   **`Sala` → `SalaDelTesoro`:** las salas del tesoro reutilizan la
    carga y descarga de una sala común, pero agregan el pedestal y un
    ítem. Para eso redefinen `cargarExtras()` y `descargarExtras()`.
-   **`VisualHUD` → `Corazon` / `EscudoHUD`:** ambos comparten la
    posición y el índice que representa cada elemento de la interfaz.
    Cada uno redefine `image()` para mostrar la cantidad de vida o
    escudo que corresponde.
-   **`EstadoTeclas` → `estadoTeclasMovimiento` /
    `estadoTeclasDisparo`:** comparten el manejo de las teclas, la
    dirección actual y el buffer de tiempo, cada uno define qué acción
    ejecutar: mover al estudiante o disparar.

## Delegación y composición

-   **`Cuerpo` y `Hitbox`:** tanto el estudiante como los enemigos
    tienen un `Cuerpo`, que se encarga de crear y administrar sus
    hitboxes, cada hitbox conoce a su dueño y, cuando ocurre una
    colisión, le delega la respuesta mediante `chocarProyectil()`,
    `chocarEnemigo()` o `chocarItem()`, de esta forma no tenemos que
    repetir la lógica del personaje en cada hitbox.
-   **Disparos (`arma`):** cuando el estudiante quiere disparar, le
    manda `disparar(self, direccion)` al objeto `arma`. El arma se
    encarga de crear el proyectil, agregarlo al juego, iniciar su
    movimiento y programar la recarga, así el estudiante no tiene que
    ocuparse de todos esos pasos.
-   **Movimiento:** el estudiante no calcula directamente las nuevas
    coordenadas, le delega el movimiento al objeto `movimiento`, que
    recibe una dirección y obtiene la siguiente posición usando
    `posicionSig()`. La clase `Direccion` se ocupa de calcular esa
    posición teniendo en cuenta los límites del mapa.
-   **Salas:** `Sala` se encarga de cargar y descargar los elementos de
    una habitación. Las salas del tesoro aprovechan ese comportamiento y
    solamente agregan lo que necesitan. También cada sala conoce sus
    enemigos y sus puertas, sin que el mapa tenga que encargarse de
    todos esos detalles.
