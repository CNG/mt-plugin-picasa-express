(function($){

  // return value corresponding to passed in URL parameter key
  function gup( name ) {
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+name+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( window.location.href );
    if( results == null )
      return "";
    else
      return results[1];
  }
  // return somewhat random 13 character string appended to passed in prefix
  function uniqid(prefix){
    var text = prefix;
    var pool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for(var i=0; i < 13; i++) { text += pool.charAt(Math.floor(Math.random() * pool.length)); }
    return text;
  }

  var pwa_debug = false;

  var blog_id = gup('blog_id');
  var ajaxurl = mt_admin_url+'?__mode=pwa_ajax&blog_id='+blog_id;
  var pwa_gallery = false; // gallery/image switch by button #pwa-switch
  // header state: albums (show albums) or images (show images from an album)
  var pwa_state = 'albums';
  var pwa_current = 1; // numbering
  var pwa_last_request = false; // save the last request to the server for reload button
  var pwa_no_request = false;
  var pwa_cache = [];
  var pwa_defaults = {
    waiting: '<img src="'+pwa_static_url+'loading.gif" height="16" width="16" /> '+PWA_l10n.waiting,
    image: PWA_l10n.image,
    gallery: PWA_l10n.gallery,
    reload: PWA_l10n.reload,
    options: PWA_l10n.options,
    album: PWA_l10n.album,
    uniqid: uniqid(''),
    state: 'albums'
  };

  $(function() {
    // merge pwa_defaults with user defined PWA
    var i = ''; for(i in pwa_defaults) PWA[i]=pwa_defaults[i];
    // output all defined settings in debug DIV as a nice table
    if (pwa_debug) {
      var debug_output = '';
      for(i in PWA) { if (i != 'toJSON') debug_output += '<tr><td>' + i + ':</td><td>' + PWA[i] + '</td></tr>'; }
      $('#pwa_debug').show().html('<table>'+debug_output+'</table>');
    }
    // restore state
    if ('images' == PWA.pwa_saved_state) {
        $('#pwa-albums').show().siblings('.pwa-header').hide();
        pwa_request({
            action: 'get_images',
            guid: PWA.pwa_last_album
        });
    } else {
        pwa_switch_state(PWA.state);
    }
  });

  $(document).ajaxError(function(event, request, settings, error) {
      console.log("Error requesting page " + settings.url+'\nwith data: '+settings.data+'\n'+error);
  });

  // adjust header for either album listing or image listing view
  function pwa_switch_state(state){
    pwa_state = state;
    $('#pwa-'+state).show().siblings('.pwa-header').hide();
    pwa_set_handlers();
  }

  // keep track of album being viewed so we can return to it automatically next time
  function save_state(last_request) {
    if (PWA.save_state) {
      $.post(ajaxurl, {
        action: 'save_state',
        state:pwa_state,
        last_request:last_request
      });
    }
  }

  // set up click handlers
  function pwa_set_handlers() {
    $('.button').unbind();
    $('.pwa-reload').click(function(){
      if (pwa_last_request) {
        if (pwa_state != 'albums') $('#pwa-albums').show().siblings('.pwa-header').hide();
        pwa_cache[pwa_serialize(pwa_last_request)] = false;
        pwa_request(pwa_last_request);
      }
      return(false);
    });
    switch (pwa_state) {
      case 'albums':
        pwa_get_albums();
        break;
      case 'images':
        pwa_current=1;
        $('#pwa-switch').click(function() {
          pwa_gallery = pwa_gallery?false:true;
          // if image unselect siblings and run click for the first
          if (!pwa_gallery) {
            $('#pwa-main td.selected').removeClass('selected').eq(0).addClass('selected');
            $('#pwa-main td div.numbers').remove();
          } else {
            pwa_current=1;
            $('#pwa-main td.selected').removeClass('selected').click();
          }
          $(this).text((pwa_gallery)?PWA.gallery:PWA.image);
          return(false);
        });
        $('#pwa-album-name').click(function(){
          pwa_switch_state('albums');
          return(false);
        });
        $('#pwa-insert, #pwa_insert_button').click(function(){
          save_state(pwa_last_request.guid);
          writePicasaMarkup(pwa_make_html('#pwa-main td.selected'));
          return(false);
        }).hide();
        break;
    }
  }

  function pwa_request(data) {
    if (pwa_no_request) return;
    pwa_no_request = true;
    $('.pwa-reload').hide();
    pwa_last_request = data;
    var callback = (data.action=='get_gallery')?pwa_albums_apply:pwa_images_apply;
    if (pwa_cache[pwa_serialize(data)]) {
      callback(pwa_cache[pwa_serialize(data)]);
    } else {
      $('#pwa-message2').html(PWA.waiting);
      //data['cache'] = pwa_serialize(data);
      $.post(ajaxurl, data, callback, 'json');
    }
  }

  function pwa_get_albums(){
    pwa_request({
      action: 'get_gallery',
      user: 'default'
    });
  }

  function pwa_album_handler(){
    var guid = $('a',this).attr('href').replace(/^[^#]*#/,'');
    pwa_request({
      action: 'get_images',
      guid: guid
    });
    return(false);
  }

  function pwa_show_reload() {
    pwa_no_request = false;
    $('.pwa-reload').show().text(PWA.reload);
  }

  function pwa_albums_apply(response) {
    pwa_show_reload();
    if (response.error) {
      $('#pwa-message2').text(response.error);
      return;
    }
    pwa_cache[response.cache] = response;
    $('#pwa-main').html(response.data);
    $('#pwa-message2').text(response.title);
    document.body.scrollTop=0;

    $('#pwa-main td').unbind().click(pwa_album_handler);
    // state switched before request
  }

  function pwa_images_apply(response) {
    pwa_show_reload();
    if (response.error) {
      $('#pwa-message2').text(response.error);
      return;
    }
    pwa_cache[response.cache] = response;
    $('#pwa-main').html(response.data);
    $('#pwa-album-name').text(response.title);
    document.body.scrollTop=0;
    $('#pwa-main td').unbind().click(pwa_image_handler);
    pwa_switch_state('images');
  }

  function pwa_image_handler(){
    if (!pwa_gallery) $('#pwa-main td').removeClass('selected');
    if (PWA.gal_order && pwa_gallery) {
      if ($(this).hasClass('selected')) {
        var current = Number($('div.numbers',this).html());
        $('div.numbers',this).remove();
        // decrement number for rest if >current
        $('#pwa-main td.selected').each(function(){
          var i = Number($('div.numbers',this).html());
          if (i>current) $('div.numbers',this).html(i-1);
        });
        pwa_current--;
      } else {
        $(this).prepend("<div class='numbers'>"+pwa_current+"</div>");
        pwa_current++;
      }
    }
    $(this).toggleClass('selected');
    // check selected to show/hide Insert button
    if ($('#pwa-main td.selected').length==0) $('#pwa-insert, #pwa_insert_button').hide();
    else $('#pwa-insert, #pwa_insert_button').show();
    return(false);
  }

  function pwa_serialize(data) {
    function Dump(d,l) {
      if (l == null) l = 1;
      var s = '';
      if (typeof(d) == "object") {
        s += typeof(d) + " {\n";
        for (var k in d) {
          for (var i=0; i<l; i++) s += "  ";
          s += k+": " + Dump(d[k],l+1);
        }
        for (var i=0; i<l-1; i++) s += "  ";
        s += "}\n";
      } else {
        s += "" + d + "\n";
      }
      return s;
    }
    return Dump(data);
  }

  String.prototype.trim = function() {
    var s=this.toString().split('');
    for (var i=0;i<s.length;i++) if (s[i]!=' ') break;
    for (var j=s.length-1;j>=i;j--) if (s[j]!=' ') break;
    return this.substring(i,j+1);
  }

  String.prototype.escape = function() {
    var s = this.toString();
    s = s.replace(/&/g, "&amp;");
    s = s.replace(/>/g, "&gt;");
    s = s.replace(/</g, "&lt;");
    s = s.replace(/"/g, "&quot;");
    s = s.replace(/'/g, "&#039;");
    return s;
  }

  function pwa_make_html(case_selector) {

    var images=[], img, icaption, ialbum, isrc, ithumb, ialt, ititle, ilarge, origw, origh, inewwidth, inewheight;

    // produce HTML style info for insertion into output
    var dclass = [PWA.img_div_class || ''];
    var dstyle = [PWA.img_div_style || ''];
    var istyle = [ ( PWA.img_align != 'none' && 'float:'+PWA.img_align+';' ) || ''];
    if (PWA.img_style != "none") istyle.push(PWA.img_style);
    var cstyle = '';
    if (PWA.img_caption_align != "none") {
      cstyle = ' style="text-align:'+PWA.img_caption_align+';'+PWA.img_caption_style+'"';
    } else if (PWA.img_caption_style) {
      cstyle = ' style="'+PWA.img_caption_style+'"';
    }
    var gclass = [PWA.gal_class || ''];
    var gstyle = '';
    if (PWA.gal_align != "none") {
      gstyle = ' style="text-align:'+PWA.gal_align+';'+PWA.gal_style+'"';
    } else if (PWA.gal_style) {
      gstyle = ' style="'+PWA.gal_style+'"';
    }

    // link and gallery additions
    var amore='';
    switch (PWA.img_link) {
      case 'thickbox':
        amore = 'class="thickbox" ';
        if (pwa_gallery) amore += 'rel="'+PWA.uniqid+'" ';
        break;
      case 'lightbox':
        amore = (pwa_gallery)?'rel="lightbox-'+PWA.uniqid+'" ':'rel="lightbox" ';
        break;
      case 'highslide':
        amore = (pwa_gallery)?'class="highslide" onclick="return hs.expand(this,{ slideshowGroup: \''+PWA.uniqid+'\' })"':
          'class="highslide" onclick="return hs.expand(this)"';
        break;
    }

    // selection order
    var order = (PWA.gal_order && pwa_gallery); // why is pwa_gallery here?

    dclass = dclass.join(' ').trim();dclass = (dclass && ' class="'+dclass+'"') || '';
    dstyle = dstyle.join('').trim();dstyle = (dstyle && ' style="'+dstyle+'"') || '';
    istyle = istyle.join('').trim();
    gclass = gclass.join(' ').trim();gclass = (gclass && ' class="'+gclass+'"') || '';

    $(case_selector).each(function(i){

      icaption  = $('span',this).text().escape(); // ENT_QUOTES
      ialbum    = $('a',this).attr('href');
      isrc      = $('img',this).attr('src');
      ifilename = $('img',this).attr('alt');
      origw     = $('img',this).attr('data-width');
      origh     = $('img',this).attr('data-height');

      // set alt and title attribs. if not set (in case of 'none'), won't make the IMG attrib
      switch (PWA.img_alt) {
        case 'caption':  ialt = icaption; break;
        case 'filename': ialt = ifilename; break;
      }
      switch (PWA.img_title) {
        case 'caption':  ititle = icaption; break;
        case 'filename': ititle = ifilename; break;
      }

      // produce URL parameters for retrieving appropriately sized thumb and large images
      // Note Google apparently doesn't support dimension requests larger than 2560 pixels
      // Note Google apparently has a max height of 1060 when width not specified
      // returns '/d', '/s?-c', '/w?', '/h?' or '/w?-h?'
      function makeSizeParam(c, s, mw, mh, ow, oh) {
        if(c) return '/s' + ( s ? s : Math.min(ow, oh, 2560) ) + '-c';
        else return '/' + ( (mw || mh) ? '' : 'd' ) + (mw && 'w' + Math.min(mw, 2560)) + ((mw && mh) && '-') + ( mw ? (mh && 'h' + Math.min(mh, 2560)) : (mh && 'h' + Math.min(mh, 1060)) );
      }
      var new_thumb_size = makeSizeParam(PWA.img_thumb_crop, PWA.img_thumb_crop_size, PWA.img_thumb_width, PWA.img_thumb_height, origw, origh);
      var new_large_size = makeSizeParam(PWA.img_large_crop, PWA.img_large_crop_size, PWA.img_large_width, PWA.img_large_height, origw, origh);

      ilarge   = isrc.replace(/\/[swh]\d+(\/[^\/]+)$/,new_large_size+'$1');
      ithumb   = isrc.replace(/\/[swh]\d+(\/[^\/]+)$/,new_thumb_size+'$1');

      // produce dimensions for thumb image tag
      function makeSizeAttribs(c, s, mw, mh, ow, oh) {
        var w, h;
        if(c) {
          if(s) w = h = Math.min(s, 2560);
          else w = h = Math.min(ow, oh, 2560);
        } else {
          if(!mw && !mh) { w = ow; h = oh; }
          else {
            if(!mw) {
              h = Math.min(oh, mh, 1060);
              w = ow / oh * h;
            } else if(!mh) {
              w = Math.min(ow, mw, 2560);
              h = oh / ow * w;
            } else {
              var r = 1; // ratio of dimensions (max/orig)
              if(ow > mw || oh > mh) {
                var rw = mw / ow;
                var rh = mh / oh;
                if(rw > rh) r = rh;
                else r = rw;
              }
              w = ow * r;
              h = oh * r;
            }
          }
        }
        return 'width="' + Math.round(w) + '" height="' + Math.round(h) + '" ';
      }
      idimen = makeSizeAttribs(PWA.img_thumb_crop, PWA.img_thumb_crop_size, PWA.img_thumb_width, PWA.img_thumb_height, origw, origh);
      //console.log('thumb param: '+new_thumb_size+'; larger param: '+new_large_size+'; attribs: '+idimen);

      img = '<img %src%%alt%%title%%style%%dimen%/>'.replace(/%(\w+)%/g,function($0,$1) {
          switch ($1) {
            case 'src':   return 'src="' + ithumb + '" ';
            case 'alt':   return (ialt ? 'alt="' + ialt + '" ' : '');
            case 'title': return (ititle ? 'title="' + ititle + '" ' : '');
            case 'style': return (istyle ? 'style="' + istyle + '" ' : '');
            case 'dimen': return idimen;
          }
        });

      if (PWA.img_link != 'none') {
        if (PWA.img_link == 'album') ilarge = ialbum;
        img = '<a href="' + ilarge + '" ' + (ititle ? 'title="' + ititle + '" ' : '') + amore + '>' + img + '</a>';
      }
      if (PWA.img_caption) img += '<p' + cstyle + '>' + icaption + '</p>';
      img = '<div' + dclass + dstyle + '>' + img + '</div>';

      if (order) images[Number($('div.numbers',this).html())-1] = img;
      else images.push(img);

    }); // end each()

    if (pwa_gallery && PWA.gal_container) {
      images.unshift('<div' + gclass + gstyle + '>');
      images.push('</div>');
      images = images.join('\n');
    } else {
      images = images.join('\n')+' ';
    }
    return images;

  } // end function pwa_make_html()

})(jQuery);