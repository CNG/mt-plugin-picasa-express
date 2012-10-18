# PicasaExpress plugin for Movable Type
# Author: Charlie Gorichanaz, charlie@gorichanaz.com
# Copyright (C) 2012 Charlie Gorichanaz
package PicasaExpress::Plugin;

use strict;
use MT 4;
use URI::Escape;
use LWP::UserAgent;
use MIME::Base64 ();


################################################################################
#                                                                              #
#      HANDLE DISPLAYING AND LOGGING ERRORS WITHIN MOVABLE TYPE INTERFACE      #
#                                                                              #
################################################################################

# display error message
sub err {
  my $msg = shift;
  my $app = MT->instance;
  return $app->show_error( $msg );
}

# return translated message
sub trans {
  my $msg = shift;
  my $plugin = MT->component('PicasaExpress');
  return $plugin->translate( $msg );
}

# log input string to MT's activity log
# param: string $type 'error' or 'info'
# param: string $msg message to log
# param: integer $blog_id optional
sub log_message {
  require MT::Log;
  my ($type, $msg, $blog_id) = @_;
  my $level = MT::Log::INFO();
  if ($type eq 'error') { $level = MT::Log::ERROR(); }
  MT->log(
    {
      message => "Picasa Express: " . $msg,
      class   => 'system',
      category => 'callback',
      level    => $level,
      $blog_id ? ( blog_id => $blog_id ) : ()
    }
  );
}


################################################################################
#                                                                              #
#                           MISCELLANEOUS  UTILITIES                           #
#                                                                              #
################################################################################

# Returns string with whitespace removed from the start and end
sub trim {
  my $s = shift;
  $s =~ s/^\s+//;
  $s =~ s/\s+$//;
  return $s;
}

# Returns string with [&<>'"] replaces with HTML entity equivalents
sub escape {
  my $str = shift;
  $str =~ s/&/&amp;/g;
  $str =~ s/</&lt;/g;
  $str =~ s/>/&gt;/g;
  $str =~ s/"/&quot;/g;
  $str =~ s/'/&#039;/g;
  $str;
}

# These two routines were not present in a Base64.pm as new as version 3.08,
# taken from http://cpansearch.perl.org/src/GAAS/MIME-Base64-3.13/Base64.pm
sub encode_base64url {
  my $e = MIME::Base64::encode(shift, "");
  $e =~ s/=+\z//;
  $e =~ tr[+/][-_];
  return $e;
}
sub decode_base64url {
  my $s = shift;
  $s =~ tr[-_][+/];
  $s .= '=' while length($s) % 4;
  return MIME::Base64::decode($s);
}


################################################################################
#                                                                              #
#          HANDLE PLUGIN SETUP AND AUTHORIZATION FROM SETTINGS SCREEN          #
#                                                                              #
################################################################################

# Return true if stored token valid, false otherwise
sub check_token {
  my $app = MT->instance;
  my $blog = $app->blog;
  my $blog_id = $blog ? $blog->id : 0;
  my $plugin = MT->component('PicasaExpress');
  my $token = $plugin->get_config_value('pwa_token', 'blog:' . $blog_id);
  my $url = 'https://www.google.com/accounts/AuthSubTokenInfo';
  my $ua = LWP::UserAgent->new();
  my $res = $ua->get(
    $url,
    'Authorization' => 'AuthSub token="'.$token.'"',
    'user-agent' => 'MovableType/' . MT->version_id . '; ' . $blog->site_url,
    'timeout' => 30,
    'sslverify' => 0
  );
  return $res->code eq 200 if defined $res;
  return 0;
}

# Look up stored token, try to revoke it and clear stored token if successful
# Return true if successful, false otherwise
sub revoke_token {
  my $app = MT->instance;
  my $blog = $app->blog;
  my $blog_id = $blog ? $blog->id : 0;
  my $plugin = MT->component('PicasaExpress');
  my $config = $plugin->get_config_hash('blog:' . $blog_id);
  my $url = 'https://www.google.com/accounts/AuthSubRevokeToken';
  my $ua = LWP::UserAgent->new();
  my $res = $ua->get(
    $url,
    'Authorization' => 'AuthSub token="'.$config->{pwa_token}.'"',
    'user-agent' => 'MovableType/' . MT->version_id . '; ' . $blog->site_url,
    'timeout' => 30,
    'sslverify' => 0
  );
  if (defined $res) {
    if ($res->is_success){
      $plugin->set_config_value('pwa_token', '', 'blog:' . $blog_id);
      log_message('info', trans( "Private album access revoked" ), $blog_id);
      return 1;
    } else {
      log_message('error', trans( "Error revoking access" ) . ": " . $res->status_line, $blog_id);
    }
  } else {
    log_message('error', trans( "Cannot retrieve" ) . " " . $url . ": " . $res->status_line, $blog_id);
  }
  return 0;
}

# Take single use token and save session token to MT plugin config for blog
# Return true if successful, false otherwise
sub get_token {
  my $token = shift;
  my $app = MT->instance;
  my $blog = $app->blog;
  my $blog_id = $blog ? $blog->id : 0;
  my $plugin = MT->component('PicasaExpress');
  my $url = 'https://www.google.com/accounts/AuthSubSessionToken';
  my $ua = LWP::UserAgent->new();
  my $res = $ua->get(
    $url,
    'Authorization' => 'AuthSub token="'.$token.'"',
    'user-agent' => 'MovableType/' . MT->version_id . '; ' . $blog->site_url,
    'timeout' => 30,
    'sslverify' => 0
  );
  if (defined $res and $res->code eq 200) {
    my @splits = split(/=/, $res->content);
    $plugin->set_config_value('pwa_token', trim($splits[1]), 'blog:' . $blog_id);
    log_message('info', trans( "Private album access obtained" ), $blog_id);
    return 1;
  }
  log_message('error', trans( "Cannot get session token. HTTP response:" ) . " " . $res->code, $blog_id);
  return 0;
}

sub tag_pwa_auth_buttons {
  my $app = MT->instance;
  my $blog = $app->blog;
  my $blog_id = $blog ? $blog->id : 0;
  my $plugin = MT->component('PicasaExpress');
  my $script_full_url = $app->base . $app->uri; # full URL to mt.cgi
  my $button = '';
  if (check_token()) {
    my $phrase = trans( "Revoke access to private albums" );
    # We are authenticated with Picasa Web Albums. Store the revoke button.
    $button = qq{<button type="button" onclick="window.location.href='$script_full_url?__mode=pwa_token_receiver&blog_id=$blog_id&pwa_revoke=1'" class="cancel" accesskey="x" title="$phrase">$phrase</button>};
  } else {
    # We are not yet authenticated with Picasa Web Albums. Store the authenticate button. (pwa_auth=1 is used by blog_config.tmpl to trigger plugin settings tab automatically)
    my $auth_url = 'https://www.google.com/accounts/AuthSubRequest?next=' .
      uri_escape( $script_full_url . '?__mode=pwa_token_receiver&blog_id=' . $blog_id ) .
      '&scope=http%3A%2F%2Fpicasaweb.google.com%2Fdata%2F&session=1&secure=0';
    my $phrase = trans( "Get access to private albums" );
    $button = qq{<button type="button" onclick="window.location.href='$auth_url'" accesskey="s" class="primary-button close" title="$phrase">$phrase</button>};
  }
  if ($button) {
    return qq{<div class="actions-bar"><div class="actions-bar-inner pkg actions">$button</div></div>};
  }
  return 0;
}

# MT template tag to retrieve stored settings for inclusion in JavaScript array
sub tag_pwa_settings {
  my $app = MT->instance;
  my $blog = $app->blog;
  my $blog_id = $blog ? $blog->id : 0;
  my $plugin = MT->component('PicasaExpress');
  my $config = $plugin->get_config_hash('blog:' . $blog_id);
  my $output = '';
  for my $key (keys %$config) {
    my $value = $config->{$key};
    if ($value =~ /\D/) {
      # $value contains nondigits
      $value =~ s/'/\'/;
      $value = "'".$value."'";
    }
    if ($value eq '') {
      $value = "''";
    }
    $output .= "$key: $value, ";
  }
  return substr $output, 0, -2;
}

# MT template tags to check if authenticated
sub tag_pwa_if_authenticated { return check_token(); }
sub tag_pwa_unless_authenticated { return !check_token(); }

# Insert Picasa button in Movable Type rich text editor if authenticated
sub xfrm_archetype_editor {
  if (MT->version_number < 5.2) {
    my ($cb, $app, $src) = @_;
    my $slug = '';
    $slug = <<END_TMPL;
<mt:PicasaIfAuthenticated>
<mt:setvarblock name="html_head" append="1">
  <style type="text/css">
    .editor-toolbar a.picasa-express-button { background-image: url(<mt:var name="static_uri">plugins/PicasaExpress/toolbar-picasa-express.gif) !important; }
    .editor-toolbar a.picasa-express-button:hover:active { background-image: url(<mt:var name="static_uri">plugins/PicasaExpress/toolbar-picasa-express-active.gif) !important; }
    .editor-toolbar a.picasa-express-button:hover { background-image: url(<mt:var name="static_uri">plugins/PicasaExpress/toolbar-picasa-express-hover.gif) !important; }
  </style>
</mt:setvarblock>
END_TMPL
    if (MT->version_number < 5.1) {
      $slug .= q{<a href="javascript: void 0;" title="Picasa Express" mt:command="open-dialog" mt:dialog-params="__mode=pwa_albums&amp;blog_id=<mt:var name="blog_id">&amp;dialog_view=1" class="picasa-express-button toolbar button">};
      $slug .= '<b>Picasa Express</b><s></s></a></mt:PicasaIfAuthenticated>';
      $$src =~ s/(Insert Image<\/b><s><\/s><\/a>)/$1$slug/;
    } else {
      $slug .= q{<a href="<mt:var name="script_url">?__mode=pwa_albums&amp;blog_id=<mt:var name="blog_id">&amp;dialog_view=1" title="Picasa Express" class="picasa-express-button toolbar button mt-open-dialog">};
      $slug .= '<span class="button-label">Picasa Express</span></a></mt:PicasaIfAuthenticated>';
      $$src =~ s/(Insert Image"><\/span><\/a>)/$1$slug/;
    }
  }
}

sub xfrm_edit_entry {
  if (MT->version_number >= 5.2) {
    my ($cb, $app, $src) = @_;
    my $slug = <<END_TMPL;
  <mt:PicasaIfAuthenticated>
  <style type="text/css">
    #picasa-express-button {
      background-image: url(<mt:var name="static_uri">plugins/PicasaExpress/toolbar-picasa-express.gif) !important;
      display:block;overflow:hidden;width:22px;height:22px;float:right;position:relative;right:275px;text-indent:1000em;top:2px;
    }
    #picasa-express-button:hover:active { background-image: url(<mt:var name="static_uri">plugins/PicasaExpress/toolbar-picasa-express-active.gif) !important; }
    #picasa-express-button:hover { background-image: url(<mt:var name="static_uri">plugins/PicasaExpress/toolbar-picasa-express-hover.gif) !important; }
  </style>
  <a href="<mt:AdminCGIPath><mt:AdminScript>?__mode=pwa_albums&amp;blog_id=<mt:var name="blog_id">&amp;dialog_view=1" title="Picasa Express" class="mt-open-dialog" id="picasa-express-button">Picasa Express</a>
  </mt:PicasaIfAuthenticated>
END_TMPL
    $$src =~ s|(<div id="field-convert_breaks">)|$1$slug|;
  }
}

# Handler for calls to MT with __mode=pwa_token_receiver
# Handles saving tokens from Picasa Web Albums
# Template used is pwa_token_receiver.tmpl
sub mode_pwa_token_receiver {
  my $app = shift;
  my $blog = $app->blog;
  my $blog_id = $blog ? $blog->id : 0;
  my $script_full_url = $app->base . $app->uri; # full URL to mt.cgi
  if (defined $app->param('token')) {
    # We're just receiving a single use token from Google
    # Exchange it for and store a session token
    get_token($app->param('token'));
  } elsif (defined $app->param('pwa_revoke')) {
    # User probably clicked the revoke button, which set the 'pwa_revoke' URL param
    revoke_token();
  }
  print 'Location: ' . $script_full_url . '?__mode=cfg_plugins&_type=blog&blog_id=' . $blog_id . '&pwa_auth=1' . "\n\n";
}

# Handler for calls to MT with __mode=pwa_albums
# Displays main interface for selecting photos from Picasa Web Albums
# Template used is pwa_albums.tmpl
sub mode_pwa_albums {
  my $app = shift;
  my $plugin = MT->component('PicasaExpress');
  my $tmpl = $plugin->load_tmpl('pwa_albums.tmpl');
  return $app->build_page( $tmpl );
}


################################################################################
#                                                                              #
#   HANDLE AJAX REQUESTS FOR MOVABLE TYPE TO INTERACT WITH PICASA WEB ALBUMS   #
#                                                                              #
################################################################################

# Handler for calls to MT with __mode=pwa_ajax
# 'action' parameter values:
#   --- save_state: supply 'state' and 'last_request' params
#   -- get_gallery: return JSON encoded structure with user's album info
#   --- get_images: supply 'guid' param for specific album
#                   return JSON encoded structure with album's image info
sub mode_pwa_ajax {
  my $app = MT->instance;
  my $q = $app->param;
  return err( trans( "Missing parameter:" ) . "blog_id" ) unless defined $q->param('blog_id');
  my $blog_id = defined $q->param('blog_id') ? $q->param('blog_id') : 0; # shouldn't reach 0 since we require blog_id param
  return err( trans( "Missing parameter:" ) . " action" ) unless defined $q->param('action');
  my $action = $q->param('action') if defined $q->param('action');
  my $plugin = MT->component('PicasaExpress');
  my $config = $plugin->get_config_hash('blog:' . $blog_id);
  use Switch;
  switch ($action) {

    case 'save_state' {
      return err( trans( "Missing parameter:" ) . 'state' ) unless defined $q->param('state');
      my $state = $q->param('state') if defined $q->param('state');
      return err( trans( "Missing parameter:" ) . 'last_request' ) unless defined $q->param('last_request');
      my $last_request = $q->param('last_request') if defined $q->param('last_request');
      switch ($state) {
        case 'albums' {
          # No longer anything to do here since we only change user on settings screen
        }
        case 'images' {
          $plugin->set_config_value('pwa_last_album', $last_request, 'blog:' . $blog_id);
        }
      }
      $plugin->set_config_value('pwa_saved_state', $state, 'blog:' . $blog_id);
      return 1;
    } # end case 'save_state'

    case 'get_gallery' {
      my $token = $config->{pwa_token} if defined $config->{pwa_token};
      return err( trans( "Must have value for configuration setting:" ) . ' token' ) unless defined $token;
      my $url = 'http://picasaweb.google.com/data/feed/base/user/default?alt=rss&kind=album&hl=en_US';
      my $rss = get_feed($url, $blog_id, $token);
      use XML::Parser;
      use XML::Parser::Style::ETree;
      my $parser = new XML::Parser(Style => 'ETree');
      my $tree = $parser->parse($rss);
      my $out = {};
      if (!$tree->{rss}->{channel}->{'atom:id'}) {
        $out->{error} = trans( "Gallery RSS feed did not parse properly" );
      } else {
        my $items = $tree->{rss}->{channel}->{item};
        my $output = '';
        if (defined $items) {
          if (ref($items) ne 'ARRAY') { $items = [ $items ]; }
          $output .= "\n<table><tr>\n";
          my $i = 0;
          for my $item (@$items) {
            my $guid = $item->{guid}->{'#text'} . "&kind=photo";
            $guid =~ s/entry/feed/g;
            $guid = encode_base64url($guid);
            my $title = escape($item->{title});
            my $desc  = escape($item->{'media:group'}->{'media:description'}->{'#text'});
            my $url   = $item->{'media:group'}->{'media:thumbnail'}->{'-url'};
            $output .= "<td><a href='#$guid'><img src='$url' alt='$desc' width='144' /><span>$title</span></a></td>\n";
            $output .= "</tr><tr>\n" if $i++ % 4 == 3;
          }
          $output .= "</tr></table>\n";
        }
        $out->{items} = $tree->{rss}->{channel}->{'openSearch:totalResults'};
        #$out->{title} = escape($tree->{rss}->{channel}->{'title'});
        $out->{title} = $tree->{rss}->{channel}->{'title'};
        $out->{data} = $output;
        $out->{cache} = $q->param('pwa_cache') if defined $q->param('pwa_cache');
        use JSON;
        return encode_json($out);
      }
    } # end case 'get_gallery'

    case 'get_images' {
      my $token = $config->{pwa_token} if defined $config->{pwa_token};
      return err( trans( "Must have value for configuration setting:" ) . ': token' ) unless defined $token;
      my $guid = decode_base64url($q->param('guid')) if defined $q->param('guid');
      return err( trans( "Must have value for parameter:" ) . ' guid' ) unless defined $guid;
      my $sort = $config->{image_sort_by} if defined $config->{image_sort_by};
      return err( trans( "Must have value for configuration setting:" ) . ' image_sort_by' ) unless defined $sort;
      my $order = $config->{image_sort_order} if defined $config->{image_sort_order};
      return err( trans( "Must have value for configuration setting:" ) . ' image_sort_order' ) unless defined $order;
      my $rss = get_feed($guid.'&imgmax=d', $blog_id, $token);
      use XML::Parser;
      use XML::Parser::Style::ETree;
      my $parser = new XML::Parser(Style => 'ETree');
      my $tree = $parser->parse($rss);
      my $out = {};
      if (!$tree->{rss}->{channel}->{'atom:id'}) {
        $out->{error} = trans( "Images RSS feed did not parse properly" );
      } else {
        my $items = $tree->{rss}->{channel}->{item};
        #use Data::Dumper;return Dumper($items);
        my $output = '';
        my $key = 0;
        my $images = {};
        if (defined $items) {
          if (ref($items) ne 'ARRAY') { $items = [ $items ]; }
          for my $item (@$items) {
            switch ($sort) {
              case 'none' { $key++; }
              case 'date' {
                use Date::Parse;
                $key = str2time($item->{'pubDate'});
                # need to swap order if key is date since timestamps used
                if ($order eq 'ascending') { $order = 'descending'; }
                if ($order eq 'descending') { $order = 'ascending'; }
              }
              case 'title' { $key = $item->{'title'}; }
              case 'filename' { $key = $item->{'media:group'}->{'media:title'}->{'#text'}; }
            }
            my $url = $item->{'media:group'}->{'media:thumbnail'}->[0]->{'-url'};
            $url =~ s/s72/w144/g;
            $images->{$key} = {
              'guid' => $item->{'link'},
              'title' => $item->{'title'},
              'file' => $item->{'media:group'}->{'media:title'}->{'#text'},
              'desc' => $item->{'media:group'}->{'media:description'}->{'#text'},
              'height' => $item->{'media:group'}->{'media:content'}->{'-height'},
              'width' => $item->{'media:group'}->{'media:content'}->{'-width'},
              'url' => $url
            };
          }
          my @images_ordered_keys = ();
          if ($order eq 'ascending') {
            @images_ordered_keys = sort { lc($a) cmp lc($b) } keys %$images;
          } else {
            @images_ordered_keys = reverse sort { lc($a) cmp lc($b) } keys %$images;
          }
          $output .= "\n<table><tr>\n";
          my $i = 0;
          for my $key (@images_ordered_keys) {
            my $image = $images->{$key};
            $output .= "<td><a href='$image->{guid}'><img src='$image->{url}' alt='$image->{file}' title='$image->{desc}' data-width='$image->{width}' data-height='$image->{height}' width='144' /><span>$image->{title}</span></a></td>\n";
            $output .= "</tr><tr>\n" if $i++ % 4 == 3;
          }
          $output .= "</tr></table>\n";
        }
        $out->{items} = $tree->{rss}->{channel}->{'openSearch:totalResults'};
        #$out->{title} = escape($tree->{rss}->{channel}->{'title'});
        $out->{title} = $tree->{rss}->{channel}->{'title'};
        $out->{data} = $output;
        $out->{cache} = $q->param('pwa_cache') if defined $q->param('pwa_cache');
        use JSON;
        return encode_json($out);
      }
    } # end case 'get_images'

  } # end switch ($action)

  return err( trans( "Invalid action parameter value:" ) . ' ' . $action );
}

sub get_feed {
  return err( trans( "Missing parameter:" ) . ' url' ) unless @_;
  my $url = shift if @_;
  return err( trans( "Missing parameter:" ) . ' blog_id' ) unless @_;
  my $blog_id = shift if @_;
  return err( trans( "Missing parameter:" ) . ' token' ) unless @_;
  my $token = shift if @_;
  my $app = MT->instance;
  my $blog = $app->blog;
  my $ua = LWP::UserAgent->new();
  my $res = $ua->get(
    $url,
    'Authorization' => 'AuthSub token="'.$token.'"',
    'user-agent' => 'MovableType/' . MT->version_id . '; ' . $blog->site_url,
    'timeout' => 30,
    'sslverify' => 0
  );
  if (defined $res) {
    if ($res->is_success){
      return $res->{_content};
    } else {
      log_message('error', trans( "Error retrieving feed:" ) . " " . $res->status_line, $blog_id);
    }
  } else {
    log_message('error', trans( "Cannot retrieve" ) . " " . $url . ": " . $res->status_line, $blog_id);
  }
  return 0;
}

1;
