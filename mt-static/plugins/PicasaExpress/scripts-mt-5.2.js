// save original sizes so they can be reset upon closing modal
// Note mt5 doesn't use the same DIV with id="dialog" but this shouldn't hurt anything
var pwa_orig_x = jQuery(window.top.document).find('#dialog').width();
var pwa_orig_y = jQuery(window.top.document).find('#dialog').height();
var pwa_max_y  = jQuery(window.top).height();
var pwa_head_y = jQuery('.pwa-header').height();

var pwa_set_dialog_size = function(x,y){
  jQuery(window.top.document).find('#dialog').width(x);
  jQuery(window.top.document).find('#dialog').height(y);
}

function insert_html(value) {
  var editor = window.parent.tinyMCE;
  if (value) {
    editor.execInstanceCommand('editor-input-content', 'mceInsertRawHTML', false, value);
  }
}

// runs upon clicking Insert button
var writePicasaMarkup = function(pwa_html) {
  insert_html(pwa_html);
  pwa_set_dialog_size(pwa_orig_x,pwa_orig_y);

  if( typeof(parent.jQuery) != "undefined" )
    if( typeof(parent.jQuery.fn) != "undefined" )
      if( typeof(parent.jQuery.fn.mtDialog) != "undefined" )
        if( typeof(parent.jQuery.fn.mtDialog.close) != "undefined" )
          parent.jQuery.fn.mtDialog.close();
};


// adjust various properties to make modal tall as possible
jQuery(window.top.document).find('#dialog, #dialog-iframe').width(pwa_orig_x + 40);
jQuery(window.top.document).find('#dialog, #dialog-iframe').height(pwa_max_y - 80);
jQuery(document).find('#container').height(pwa_max_y - 80 - 45).width(650);
jQuery(document).find('#content').height(pwa_max_y - 80 - 45 - 35).width(653);
jQuery(document).find('#pwa_content').height(pwa_max_y - 80 - 45 - 35 - 40 - pwa_head_y - 3);
