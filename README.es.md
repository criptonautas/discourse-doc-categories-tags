# Doc Categories Tags

[ENGLISH](README.md) | **ESPAÑOL**

Mantenido por Criptonautas. Sin afiliación ni respaldo de Discourse (Civilized Discourse Construction Kit, Inc.).

Un componente de tema para Discourse que integra en la lista de temas de una
categoría todos los temas que llevan una etiqueta dada, de modo que los temas
etiquetados y repartidos por el foro se leen como parte de la documentación de
esa categoría.

El plugin [Doc Categories](https://github.com/discourse/discourse-doc-categories)
construye documentación a partir de una categoría, así que no puede reunir
temas que viven en otro sitio. Este componente cubre ese hueco: etiqueta un
tema en cualquier parte y aparecerá en la categoría de documentación junto a
los temas que pertenecen nativamente a ella.

| Escritorio | Móvil |
|---|---|
| ![Temas etiquetados integrados en una categoría, escritorio](docs/screenshots/doc-tags-desktop.png) | ![Temas etiquetados integrados en una categoría, móvil](docs/screenshots/doc-tags-mobile.png) |

## Requisitos

- Discourse 2026.7.2 o posterior.
- Etiquetado activado.
- El plugin Doc Categories, para el comportamiento de la barra lateral que se
  describe más abajo. La integración en la lista funciona sin él.

## Instalación

Admin → Personalizar → Temas → Instalar → Desde un repositorio git, con la URL
de clonado de este repositorio. Luego añade el componente a los temas que
deban usarlo y configura `target_category`: la integración lo necesita. El
comportamiento de la barra lateral no, así que se aplica en cuanto el componente
está activo y Doc Categories tiene un índice.

## Ajustes

| Ajuste | Por defecto | Notas |
| --- | --- | --- |
| `tag_name` | `wiki` | Etiqueta cuyos temas se integran. Solo se usa la primera etiqueta. |
| `target_category` | — | Categoría cuya lista recibe esos temas. Solo se usa la primera categoría. Obligatorio para la integración. |
| `redirect_tag_page` | `false` | Envía `/tag/<etiqueta>` a la categoría destino. |
| `hide_tag_hashtags` | `false` | **En todo el sitio:** un hashtag `#<etiqueta>` no muestra nada en los posts. |
| `hide_disabled_tag_rows` | `false` | **En todo el sitio:** oculta las filas que el núcleo marca como no permitidas en la búsqueda de etiquetas del editor. |

## Qué hace

### Integra los temas etiquetados en la lista

Solo en la categoría destino, obtiene la lista de temas de la etiqueta para la
pestaña actual y los integra en la lista propia de la categoría. Las filas se
renderizan con la lista de temas del núcleo, así que conservan los avatares,
el número de respuestas, la actividad y las insignias de siempre, y siguen el
orden de la propia pestaña: Latest sigue ordenado por actividad.

Los temas que ya están en la categoría destino se omiten, así que nada aparece
dos veces, y los temas fijados de la categoría siguen fijados. Las insignias
de categoría de origen se vuelven a mostrar, porque la lista ya no contiene una
sola categoría, y las filas integradas llevan la clase
`doc-categories-tags-topic` para aplicarles estilos.

Los resultados se guardan en memoria por etiqueta y pestaña durante la sesión,
así que cambiar de pestaña no vuelve a pedirlos; recargar la página sí. Si la
petición falla, la lista nativa se queda exactamente como estaba y no se
muestra ningún error.

### Trata como documentación los temas enlazados en un índice

Doc Categories decide su barra lateral según la categoría en la que vive el
tema, así que un tema enlazado desde un índice de documentación pero archivado
en otra categoría no recibe barra lateral, aunque forme parte de esa
documentación. Este componente hace que la pertenencia siga al índice: la
categoría cuyo índice enlaza un tema es la que gobierna su barra lateral.

Esta parte es independiente de la etiqueta a propósito —se basa en el índice,
no en `tag_name`—, así que también sirve a temas de documentación que no tienen
nada que ver con la integración anterior. La navegación anterior/siguiente para
el mismo caso está en
[discourse-course-progress-nautas](https://github.com/somos-criptonautas/discourse-course-progress-nautas),
que resuelve la pertenencia igual.

### Quita el ruido que deja la etiqueta

La píldora de la etiqueta se oculta en la lista de la categoría destino, donde solo
repite lo que la página ya es. Sigue visible en todos los demás lugares, y las otras
etiquetas no cambian.

Otras tres reglas asumen que la etiqueta es parte de la mecánica, no algo que los
lectores deban ver ni escribir. Son opinadas, así que vienen desactivadas:

- `redirect_tag_page`: `/tag/<etiqueta>` redirige a la categoría destino, porque la
  categoría ya contiene todo lo que lleva la etiqueta. La edición de etiquetas y las
  intersecciones `/tags/c/...` no cambian.
- `hide_tag_hashtags`: un hashtag `#<etiqueta>` escrito en un post no muestra nada,
  **en todo el sitio**, de modo que la etiqueta se aplica desde el selector. Los demás
  hashtags no cambian y la palabra sigue en el markdown original.
- `hide_disabled_tag_rows`: las filas deshabilitadas se ocultan en la búsqueda de
  etiquetas del editor, **en todo el sitio**. Cuando una categoría restringe qué
  etiquetas admite, el núcleo lista las no permitidas como filas deshabilitadas que
  explican el motivo; esto oculta esa explicación. Lo que se ofrece se sigue decidiendo
  en el servidor.

## Límites y advertencias

- La pestaña **Top** es aproximada: el orden integrado va por número de vistas,
  que no es el ranking que usa el servidor, y el periodo (`top/weekly` y
  demás) no se traslada.
- Los temas integrados aparecen un instante después de la lista nativa, al
  terminar la petición, lo que reorganiza la lista con una conexión lenta.
- Todo lo que lleva la etiqueta se pide de golpe, hasta 20 páginas, mientras
  los temas propios de la categoría siguen paginando al hacer scroll.
- El comportamiento de la barra lateral parchea interioridades del plugin que
  no son API pública. Si Doc Categories las cambia, la barra lateral vuelve a
  su comportamiento propio y el componente registra un aviso que lo nombra;
  nada más se rompe. Hay un test de sistema contra el plugin real para
  detectarlo, y CI también se ejecuta cada semana.
- La redirección de la etiqueta es del lado del cliente, porque los Permalinks
  de Discourse solo actúan en URLs que no coinciden con ninguna ruta, y
  `/tag/<etiqueta>` coincide antes con la ruta real de la etiqueta. Los clics
  dentro de la aplicación nunca renderizan la página de la etiqueta, pero una
  visita directa la carga un instante antes de rebotar, y los rastreadores no
  la siguen. Un 301 en tu proxy inverso lo arregla, siempre que afecte solo a
  las rutas HTML y deje en paz `/tag/<etiqueta>/l/<filtro>.json`: el componente
  lo usa para obtener sus datos.
- Las filas desactivadas ocultas en el buscador de etiquetas no tienen test;
  probarlas exige una categoría con grupos de etiquetas restringidos manejada
  desde el editor. Todo lo demás sí lo tiene.

## Desarrollo

```bash
pnpm install
pnpm lint
```

Los tests de sistema se ejecutan contra un Discourse real mediante la
[CLI discourse_theme](https://github.com/discourse/discourse_theme), que
instala el plugin Doc Categories desde `tests.requiredPlugins`:

```bash
discourse_theme rspec .
```

Verificado contra Discourse `2026.7.2` (estable) y `2026.9.0-latest`.

## Licencia

MIT. Ver [LICENSE](LICENSE).

El texto de este README está bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
