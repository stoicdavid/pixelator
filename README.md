# Pixelator

Aplicación web que realiza algunos filtros básicos sobre procesamiento digital de imágenes.
Esta construida sobre el famoso framework Ruby on Rails (RoR)
Y para el procesamiento digital de imágenes utilizo las bibliotecas nativas de Rails 6.1.3

## Como empezar

En este archivo encontrarás las instrucciones para que el software puedas ejecutarlo en tu máquina en desarrollo o bien para verificar su uso en la siguiente liga donde tengo corriendo la aplicacion

```
http://165.232.136.224/welcome/index
```
La aplicacion esta corriendo actualmente en Digital Ocean con servidor virtualizado con Ubuntu 20, sin embargo puedes instalar la aplicacion en linux on mac si quieres ejecutarla localmente. Abajo los detalles.

### Pre-requisitos

A pesar de utilizar las bibliotecas nativas de Rails y si se quiere instalar de manera local debe contarse con lo siguiente:

Mi recomendacion para un buen development stack es lo siguiente:

* zsh -> Recomiendo OhMyZsh
* XCode -> si estas en macos y descargar las command line tools
* apt -> ubuntu o 
* homebrew -> macos
* rbenv -> para manejar diferentes versiones del lenguaje ruby o bien
* adsf -> para manejar versiones de software no solo ruby
* git -> para gestionar las versiones del codigo
* Yarn y Node -> instalar via adsf, son requeridos por rails

Con lo anterior procede a instalar ruby

```
$ asdf plugin add ruby
$ asdf list all ruby
$ asdf list all ruby
$ asdf install ruby latest
```
Configura la variable en asdf para usar la version mas reciente de ruby y no la de tu sistema

```
$ asdf global ruby 3.0.0
```

Ruby utiliza bibliotecas a manera de gemas o 'gems', actualiza para que no te instale la documentacion de cada gema a utilizar y evitar que tarde tiempo la actualizaci{on de gemas y posteriormente actualiza el sistema y las gemas a la versión mas reciente

```	
$ echo "gem: --no-document" >> ~/.gemrc
$ gem update --system
$ gem update
```

Ahora si instala Rails 6.1.3 a traves de 

```	
$ gem install rails
```

* PostgreSQL -> recomiendo instalar via apt o homebrew

* Tambien para el manejo de imagenes instalas las siguientes bibliotecas

macos
```
brew install imagemagick vips
```
ubuntu
```
apt-get install imagemagick vips
```
### Instalando pixelator

Ya una vez que cuentes con rails instalado clona el repositorio con el siguiente comando donde vayas a instalar la aplicacion.

```
git clone git@github.com:stoicdavid/pixelator.git
```

O bien si lo prefieres puedes acceder a esta liga para descargar el .zip
```
https://github.com/stoicdavid/pixelator
```

Entra al directorio donde se encuentra la aplicacion usualmente veras varias carpetas: 
```
app bin config ...
```

Ahi podras ejecutar los comandos para actualizar las gemas, crear la base de datos y activar el servidor 
```
$ bundle install
$ rails db:migrate
$ rails server
```

Una vez que hayas concluido abre un navegador y copia la siguiente liga:
```
http://localhost:3000/welcome/index
```


## Uso general


Al iniciar, la aplicación mostrará dos bloques vacíos pues no hay imágenes cargadas.
Seleccionar una imágen y cargarla.

La imágen se puede eliminar y cargar otra.

Siempre que se aplica un filtro la aplicación mostrará que se generó un filtro y lo colocará en la sección filtros aplicados

La aplicación utiliza una clase llamada 'Variation' para almacenar en la base de datos los filtros previamente aplicados y no volverlos a generar, aunque siempre se pueden eliminar los filtros de manera individual o bien toda la imagen que también elimina todas las variaciones creadas.

Solo los filtros Brillo y Mosaico pueden aplicarse varias veces para obtener diferentes imagenes con diferentes efectos.

Para el resto de los filtros se pueden aplicar una vez y se queda almacenada la imágen, si se quiere reaplicar el filtro simplemente se elimina la variación con el botón para eliminar.

La aplicacion permite cargar imágenes png o jpg y con un tamaño que no exceda los 5MB aunque la restriccion principal puede estar en imagenes con un alto conteo de pixeles.

Las imagenes pueden contener el canal alpha pues este canal se elimina del procesamiento y posteriormente se vuelve a integrar para operar los filtros únicamente con RGB

### Filtros básicos

La aplicación cuenta con los siguientes filtros implementados

* Nueve métodos de escalas de grises
* Filtro Brillo con un slider para seleccionar valores de 0 a 255
* Filtro Mosaico con entradas de Ancho y Alto (valor minimo 10 y maximo hasta la mitad de la imagen)
* Filtro Alto Contraste e Inverso
* Filtro Componente RGB con sliders para seleccionar el rango de RGB de cada color

### Filtros de convolución

Los filtros de convolución implementados son:

* Blur 1
* Blur 2
* Motion Blur
* Bordes
* Sharpen
* Emboss

### Filtros con letras

Los filtros implementados son:

* Una letra - coloca una letra en la imágen coloreando con el color promedio de una región usando el filtro mosaico
* Una letra gris - coloca una letra en la imágen colocando un valor de la escala de grises de una región usando el filtro mosaico
* Simula Grises - Se simula la escala de grises con la densidad de color de una conjunto de caractéres, no se usa el filtro mosaico, se reemplaza pixel por pixel y se obtiene la imágen en html.
* 16 colores - Se coloca una letra de un conjunto de caractéres, con el valor promedio de una región usando el filtro mosaico.
* 16 grises - Se coloca una letra de un conjunto de caractéres, con el valor de gris de una región usando el filtro mosaico.
* Letrero - Se reemplaza una región por una de las letras de un letrero hasta recorrer todo el letrero, este proceso se repite por tantas regiones se divida la imagen usando el filtro mosaico.
* Domino Blancas - Se reemplaza una región de la imágen por un carácter de la fuente de domino en color blanco con puntos negros, usando las partes izquierdas y derechas de la fuente hasta cubrir toda la imágen.
* Domino Negras - Se reemplaza una región de la imágen por un carácter de la fuente de domino en color negro con puntos blancos, usando las partes izquierdas y derechas de la fuente hasta cubrir toda la imágen.
* Naipes - e reemplaza una región de la imágen por un carácter de la fuente naipes, seleccionando un palo de los naipes de forma aleatoria. y en orden de la densidad de color de la fuente.

### Marca de Agua

La marca de agua acepta un texto abierto y se puede configurar de esta forma

* Texto en diagonal a lo largo de la imagen - Se coloca el texto a 45 grados y se sobrepone en la imagen, se calcula conforme el valor de la diagonal de la imágen.
* Repetir la imagen - Si se quiere que la imagen se repita en toda la imagen, se puede combinar con la opción de 45 grados.
* Se puede seleccionar la opacidad de la imagen, default 50% alfa
* Se puede hacer clic en una posición arbitraria de la imágen y en esa posición aparecerá la marca de agua.

### Estructura de la aplicación y clases principales

Rails utiliza el patrón de arquitectura MVC, por lo que las clases principales las encontrarás en la carpeta

```
cd app/models
```

La aplicación cuenta con dos modelos principales para almacenar las imagenes

* Picture -> Almacena la imagen principal o padre
* Variation -> Almacena las variaciones y filtros a aplicar

* ** Dentro de Variation se encuentra el metodo pdi_filter que recibe del controlador la instrucción para aplicar filtros

* ** Dependiendo del tipo de filtro, el método selecciona el correspondiente, lo opera y regresa una nueva imágen ya con el filtro aplicado.

* ** La imágen con la variación se almancena en la base de datos en postgres para posterior consulta.

Las clases donde se implementan los filtros se pueden consultar en https://github.com/stoicdavid/pixelator/tree/main/app/models/concerns

## Bibliotecas de imágenes empleadas

* [libvips](https://libvips.github.io/libvips/) - Default en Rails 6.1.3 usada para acceder a las imagenes
* [ruby-vips](https://github.com/libvips/ruby-vips) - Binding para ruby, el lenguaje utilizado
* [ImageMagick](https://imagemagick.org/index.php) - Usada para obtener pixeles de manera rápida y regresarlos a Vips


## Autor

* **David Rodriguez** - 

## Fuentes utilizadas

* [Convolution with color images](https://dev.to/sandeepbalachandran/machine-learning-convolution-with-color-images-2p41) - Filtros de convolución
* [Lode's Computer Graphics Tutorial](https://lodev.org/cgtutor/filtering.html) - Filtros de convolución
* [Convolution](http://www.songho.ca/dsp/convolution/convolution.html) - Background matemático de los filtros con implementación en C++
