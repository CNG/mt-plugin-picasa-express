# Picasa Express 1.2 for Movable Type #

Plugin for Movable Type to display Picasa Web Albums photos and galleries within posts. Picasa Web Albums authorization and plugin settings are stored per blog.


# Requirements #

Picasa Express has been tested on Movable Type 4, 5 and 6.

This plugin requires the following Perl modules to be installed:

- `URI::Escape`
- `LWP::UserAgent`
- `MIME::Base64`

These are likely already installed, but be aware you may need to install them if you encounter problems using the plugin.


# Installation #

1. Unpack the archive
1. Copy contents of `PicasaExpress/mt-static` into `/path/to/mt/mt-static`
1. Copy contents of `PicasaExpress/plugins` into `/path/to/mt/plugins`


# Usage #

Navigate to the plugin settings screen for the first blog with which you want to use Picasa Express. Click the Picasa Express plugin, and then click Settings. You should first authorize the plugin to access your Picasa Web Albums account by clicking the button under the first header. Once you are back on the settings screen, you can configure the plugin to output images and galleries exactly how you want!

Once configured, a small Picasa Express button (![Picasa Express button](https://raw.githubusercontent.com/CNG/mt-plugin-picasa-express/master/mt-static/plugins/PicasaExpress/toolbar-picasa-express.gif) or ![Picasa Express button](https://raw.githubusercontent.com/CNG/mt-plugin-picasa-express/master/mt-static/plugins/PicasaExpress/toolbar-picasa-express.png)) should appear on or above the body text editor toolbar on the entry editing screen for that blog.


# Release notes #

This plugin should be fully functional on all versions of Movable Type 4, 5 and 6, but is currently developed for version 6.

On Movable Type 5.1X, the photo selection popup could use some better styles.

Movable Type 5.2 heralded a new default rich text editor, and I initially placed the Picasa Express button above the editor toolbar, to the left of the Format drop down menu. Additionally, inserting images only seems to work when the rich text editor is in WYSIWYG mode, and does not work when in raw HTML viewing mode. These issues were fixed in Movable Tpye 6.

I would appreciate your reporting issues, bugs and feature requests. If you have a Github account, please feel free to create an Issue within this repository. Otherwise you may e-mail me at my first name at my last name dot com. Please include the version of Movable Type you are using, your browser and operating system versions and any other information you deem relevant.

Thanks a lot for checking out my plugin. It was more work than I imagined, so I hope somebody can find a use!. ;-)


# Special Thanks #

I am infinitely thankful to David Phillips for his help in navigating Movable Type's infrastructure. I also am grateful to my brother Tim Gorichanaz for translations to Spanish and Betsy Fraisse-Bailey for translations to French.


# Changes #

## 1.2  20 October 2014 ##

* Movable Type 6 compatibility
* Minor fixes

## 1.0  17 October 2012 ##

* First release


# License #

Copyright 2012 Charlie Gorichanaz except files derived from Picasa Express for Wordpress. All other rights reserved.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
