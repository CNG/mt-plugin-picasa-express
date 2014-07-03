function insert_html(value) {
  //parent.jQuery('#editor-input-content').text(parent.jQuery('#editor-input-content').text()+value);
  var editor = window.parent.tinyMCE;
  if (value) {
    editor.execInstanceCommand('editor-input-content', 'mceInsertRawHTML', false, value);
  }
}

// runs upon clicking Insert button
var writePicasaMarkup = function(pwa_html) {
  //alert(pwa_html);
  //console.log(pwa_html);

  insert_html(pwa_html);
  pwa_set_dialog_size(pwa_orig_x,pwa_orig_y);

  if( typeof(parent.jQuery) != "undefined" )
    if( typeof(parent.jQuery.fn) != "undefined" )
      if( typeof(parent.jQuery.fn.mtDialog) != "undefined" )
        if( typeof(parent.jQuery.fn.mtDialog.close) != "undefined" )
          parent.jQuery.fn.mtDialog.close();
  /*
  */
};

