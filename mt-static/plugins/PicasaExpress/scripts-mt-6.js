function insert_html(value) {
  if (value) {
    window.parent.app.insertHTML( value, 'editor-input-content' );
  }
}

// runs upon clicking Insert button
var writePicasaMarkup = function(pwa_html) {
  insert_html(pwa_html);
  parent.jQuery.fn.mtDialog.close();
};

