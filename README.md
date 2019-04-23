# Po(e)sible Vandalismo

Proyecto para el [_Poetry Slash 2019_](https://poesia.javier.is/)

El código de este repositorio intenta generar poemas a partir de las ediciones eliminadas de páginas de Wikipedia y que los editores que las han deshecho han marcado con la [etiqueta](https://es.wikipedia.org/wiki/Especial:Etiquetas) `"posible vandalismo"` (en algunos casos también se añaden los textos de las ediciones etiquetadas con `"mw-rollback"`.


## Uso

El código se basa en dos actores principales:

* La clase `Vandal`: se encarga de consultar Wikipedia y obtener las cadenas de texto de las ediciones deshechas por vandalismo. Escribe todos esos textos en un archivo en el directorio `data`.

* La clase `Poet`: lee los archivos de texto creados por vandal y trata sus contenidos como posibles versos. Aleatoriamente construye un poema a partir de ellos, de longitud aleatoria entre 3 y 14 lineas, cada una de ellas también de longitud aleatoria entre 2 y 9 palabras.

Para poder hacer las llamadas correctas a Wikipedia hace falta utilizar un archivo en el que se mapean los terminos a usar en los poemas con el título de su correspondiente página en Wikipedia. Por defecto dicho archivo debe llamarse `wiki-terms.yml` y estar en formato YAML. El nombre es configurable via inicialización de la clase Vandal.


## Ejemplo de uso

Para los poemas presentados en la Poetry Slash 2019 se utilizo el código que se encuentra en la carpeta `/poetry_slash`. Es simplemente un script `slash` escrito en ruby que crea una instancia de Poet y le pide un poema con el término recibido como argumento (si es que este está incluido en el archivo de mapping).

```ruby
#!/usr/bin/env ruby
require_relative "../vandal"
require_relative "../poet"

poet = Poet.new
puts poet.poem(ARGV[0])

```

Para ejecutarlo basta con hacer:

```bash
> cd poetry_slash
> ./slash titulo_del_poema

```
donde `titulo_del_poema` tiene que estar definido en `poetry_slash/wikiterms.yml`


## Licencia

Copyright © 2019 Juanjo Bazán, liberado con [licencia MIT](https://github.com/xuanxu/poesible-vandalismo/blob/master/LICENSE).