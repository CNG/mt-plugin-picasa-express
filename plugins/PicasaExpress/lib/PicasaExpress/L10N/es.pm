package PicasaExpress::L10N::es;

use strict;
use base 'PicasaExpress::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
  '_CONFIG_DESCRIPTION' => q{Insertar fotos desde tus Picasa Web Albums en entradas blog con facilidad.},
  '_SPECIAL_THANKS' => q{Special thanks to <a href="http://timgorichanaz.com/">Tim Gorichanaz</a> for Spanish translations and Betsy Fraisse-Bailey for French translations!},
  '_REMEMBER_TO_AUTHENTICATE' => q{Tienes que autentificarte por hacer clic en el botón arriba para usar este plugin. Si ya has hecho cambios, puedes guarder este formulario de ajustes antes de autentificarte, pero ¡recuérdate de volver!},
  '_STRUCTURE_EXPLANATION' => q{Cada imagen de salida se contiene dentro de una etiqueta DIV para permitir el estilo CSS o script de targeting. Si la opción de leyendas está prendida, se salen dentro de etiquetas P después de la etiqueta de la imagen y dentro de la etiqueta DIV. Lo siguiente es la forma de la salida según los ajustes últimamente guardados:},
  '_GOOGLE_THUMB_NOTE' => q{OJO: Google no admite la dimensiones que superan 2560 píxeles. Si el recortamiento se permite por opción, la dimensión máxima será 2560x2560. Si el recortamiento no se permite y la anchura y altura están en blanco, la imagen original se usará sin importar sus dimensiones. Además, Google admite una altura máxima de 1060 píxeles si no se especifica una anchura.},
  '_image_sort_by_label' => q{Norma de ordenar imágenes},
  '_image_sort_order_label' => q{Orden de imágenes},
  '_save_state_label' => q{Recordar álbum ultimamente cargado},
  '_img_div_class_label' => q{Class de etiqueta DIV},
  '_img_div_class_hint' => q{Class para aplicar a las etiquetas DIV},
  '_img_div_style_label' => q{Estilos para las etiquetas DIV},
  '_img_div_style_hint' => q{Estilos CSS para poner en el código de los etiquetas DIV de imágenes},
  '_img_thumb_label' => q{Tamaño de miniaturas},
  '_img_thumb_hint' => q{Controla el tamaño máximo del imagen principal que se introduce en la entrada. Se nos refirimos como la &lsquo;imagen miniatura&rsquo; a diferencia de la &lsquo;imagen grande&rsquo;, la cual se aparece al hacer clic en la imagen miniatura, una vez permitido.},
  '_img_alt_label' => q{Propiedad alt de la imagen},
  '_img_alt_hint' => q{Se visualiza cuando la imagen no se carga o antes de cargarse y ayuda que los buscadores y usuarios aprendan del contenido},
  '_img_title_label' => q{Propiedad título de la imagen},
  '_img_title_hint' => q{Suele aparecer como tool-tip mientras el cursor está encima de la imagen},
  '_img_align_label' => q{Alineación de la imagen},
  '_img_align_hint' => q{Aplica un estilo float a la etiqueta IMG en el código},
  '_img_style_label' => q{Estilos de la etiqueta IMG},
  '_img_style_hint' => q{Estilos CSS para poner en el código de las etiquetas IMG},
  '_img_caption_label' => q{Mostrar leyenda debajo de la imagen},
  '_img_caption_align_label' => q{Alineación de la leyenda},
  '_img_caption_align_hint' => q{Aplica un estilo text-align en el código de la etiqueta leyenda},
  '_img_caption_style_label' => q{Estilos de la etiqueta leyenda},
  '_img_caption_style_hint' => q{Estilos CSS para poner en el código de las etiquetas P de leyenda},
  '_img_link_label' => q{Enlace de imagen principal},
  '_img_link_hint' => q{Para emplear bibliotecas externas como Thickbox, Lightbox o Highslide, se necesita instalarla y integrarla independientemente.},
  '_img_large_label' => q{Tamaño de imagen principal},
  '_img_large_hint' => q{Controla el tamaño máximo de la imagen principal, la que o parece al clic o es el destino de un enlace directo. Si para &lsquo;Enlace de imagen principal&rsquo; se ha seleccionado &lsquo;Enlace a Picasa Web Album&rsquo; o &lsquo;Sin enlace&rsquo;, esta sección se bloquea porque no nos importan las imágenes salvo las miniaturas que se introducen en la entrada.},
  '_gal_order_label' => q{Orden de selección},
  '_gal_order_hint' => q{Imprimir imágenes en el mismo orden que se seleccionan.},
  '_gal_container_label' => q{Contenedor de la galería},
  '_gal_container_hint' => q{Cuando desmarcado, las imagenes todavía se quedan dentro de etiquetas DIV individuales, pero no habrá una etiqueta DIV singular que contiene todas las imágenes.},
  '_gal_align_label' => q{Alineación de la galería},
  '_gal_align_hint' => q{Aplica estilo text-align en el código de la DIV de la galería},
  '_gal_class_label' => q{Class de la etiqueta DIV de la galería},
  '_gal_class_hint' => q{Class para aplicar a la etiqueta DIV de la galería},
  '_gal_style_label' => q{Estilos de la etiqueta DIV galeria},
  '_gal_style_hint' => q{Estilos CSS para poner en el código de la etiqueta DIV de la galería},
  '_REMEMBER_TO_AUTHENTICATE_2' => q{Volver a estos ajustes y hacer clic en el botón de autentificación después de guardar para usar el plugin.},
  'Add Picasa image or gallery' => q{Añadir imagen o galería de Picasa},
  'Album' => q{Álbum},
  'ascending' => q{ascendiente},
  'caption' => q{leyenda},
  'Center' => q{Centro},
  'Crop from center to create square large image, regardless of original aspect ratio' => q{Recortar desde el centra para crear una imagen cuadrado, sin que importe la proporción original},
  'Crop from center to create square thumbnail, regardless of original aspect ratio' => q{Recortar desde el centro para crear miniatura cuadrada, sin que importe la proporción original},
  'date' => q{Fecha},
  'descending' => q{descendiente},
  'Direct link' => q{Enlace directo},
  'filename' => q{nombre de fichero},
  'Galleries' => q{Galerías},
  'Gallery' => q{Galería},
  'Highslide' => q{Highslide},
  'Image' => q{Imagen},
  'Images' => q{Imágenes},
  'IMPORTANT:' => q{IMPORTANTE:},
  'Insert' => q{Insertar},
  'Left' => q{Izquierda},
  'Lightbox' => q{Lightbox},
  'Limit large image <strong>width</strong> to' => q{Limitar <strong>anchura</strong> de imagen principal a},
  'Limit thumbnail <strong>width</strong> to' => q{Limitar <strong>anchura</strong> de miniatura a},
  'Link to Picasa Web Album' => q{Enlace a Picasa Web Album},
  'No link' => q{Sin enlace},
  'None' => q{Ninguno},
  'nothing' => q{nada},
  'Options' => q{Opciones},
  'order' => q{orden},
  'Output images in same order in which they are selected' => q{Imprimir imágenes en el mismo orden que se seleccionan},
  'Picasa Web Albums display properties' => q{Propiedades de visualización de Picasa Web Albums},
  'pixels' => q{píxeles},
  'pixels and <strong>height</strong> to' => q{píxeles y <strong>altura</strong> a},
  'Please wait' => q{Esperar},
  'Populate image alt attribute with' => q{Poblar atributo alt de imagen con},
  'Populate image title attribute with' => q{Poblar atributo alt de imagen con},
  'Reload' => q{Recargar},
  'REMEMBER:' => q{OJO:},
  'Right' => q{Derecha},
  'Select an Album' => q{Seleccionar Álbum},
  'Select images' => q{Seleccionar imágenes},
  'Set cropped large image <strong>width</strong> and <strong>height</strong> to' => q{Definir <strong>anchura</strong> y <strong>altura</strong> de la imagen principal recortada como},
  'Set cropped thumbnail <strong>width</strong> and <strong>height</strong> to' => q{Definir <strong>anchura</strong> y <strong>altura</strong> de la miniatura recortada como},
  'Show album images in' => q{Mostrar imágenes de álbum en},
  'Sort album images by' => q{Ordenar imágenes de álbum},
  'Surround images with a single gallery DIV tag' => q{Rodear imágenes de la galería con una etiqueta DIV singular},
  'Thickbox' => q{Thickbox},
  'This is a caption' => q{Esto es una leyenda},
  'title' => q{título},

  # Strings from Plugin.pm
  'Cannot get session token. HTTP response:' => q{No se puede conseguir token de sesión. Respuesta HTTP:},
  'Cannot retrieve' => q{No se puede recuperar},
  'Error retrieving feed:' => q{Error en recuperar feed:},
  'Error revoking access' => q{Error en revocar acceso},
  'Gallery RSS feed did not parse properly' => q{Feed RSS de galería no se parseó bien},
  'Get access to private albums' => q{Obtener acceso a álbumes privados},
  'Images RSS feed did not parse properly' => q{Feed RSS de imágenes no se parseó bien},
  'Invalid action parameter value:' => q{Valor de parámetro acción invalido:},
  'Missing parameter:' => q{Falta parámetro:},
  'Must have value for configuration setting:' => q{Es imprescindible rellenar valor de configuración:},
  'Must have value for parameter:' => q{Es imprescindible rellenar valor del parámetro:},
  'Private album access obtained' => q{Acceso a álbum privado obtenido},
  'Private album access revoked' => q{Acceso a álbum privado revocados},
  'Revoke access to private albums' => q{Revocar acceso a álbumes privados}

);

1;