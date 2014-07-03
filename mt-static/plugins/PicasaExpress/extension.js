tinymce.PluginManager.add('picasaexpress', function(ed, url) {
    // Add a button that opens a window
    ed.addButton('picasaexpress', {
        text: 'Picasa Express',
        icon: 'https://votecharlie.com/mt/mt-static/plugins/PicasaExpress/toolbar-picasa-express.gif',
        onclick: function() {
            var blogId = jQuery('#blog-id').val() || 0;
            // Open window
            ed.windowManager.open({
      					//url : '/test.htm',
      					url : ScriptURI + '?__mode=pwa_albums&blog_id=' + blogId + '&dialog_view=1',
                title: 'Picasa Express'
            });
        }
    });

});

(function($) {

var config  = MT.Editor.TinyMCE.config;

$.extend(config, {
    plugins: config.plugins + ',picasaexpress',
    plugin_mt_source_buttons1: 'picasaexpress,|,|,|,|,' + (config.plugin_mt_source_buttons1 || ''),
    plugin_mt_common_buttons1: 'picasaexpress,|,' + (config.plugin_mt_common_buttons1 || '')
});

var blogId = jQuery('#blog-id').val() || 0;

$.extend(config.plugin_mt_inlinepopups_window_sizes, {
    //'picasaexpress.htm': {
     'dialog_view=1': {
        top: function() {
            var height = $(window).height() - 110,
                vp     = tinymce.DOM.getViewPort();
            return Math.round(Math.max(vp.y, vp.y + (vp.h / 2.0) - ((height+60) / 2.0)));
        },
        height: function() {
            return $(window).height() - 110;
        },
        width: function() {
            return $(window).width() - 110;
        },
        width: 680,
        left: function() {
            var width = 680,
                vp    = tinymce.DOM.getViewPort();
            return Math.round(Math.max(vp.x, vp.x + (vp.w / 2.0) - ((width+60) / 2.0)));
        },
				inline : 1
    }
});

})(jQuery);
