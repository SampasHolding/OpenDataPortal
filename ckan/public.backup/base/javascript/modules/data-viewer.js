// data viewer module
// resizes the iframe when the content is loaded
this.ckan.module('data-viewer', function (jQuery) {
  return {
    options: {
      timeout: 200,
      minHeight: 400,
      padding: 30
    },

    initialize: function () {
      jQuery.proxyAll(this, /_on/);
      this.el.on('load', this._onLoad);
      this._FirefoxFix();
      this.sandbox.subscribe('data-viewer-error', this._onDataViewerError);
    },

    _onDataViewerError: function(message) {
      var parent = this.el.parent();
      $('.data-viewer-error .collapse', parent).html(message);
      $('.data-viewer-error', parent).removeClass('js-hide');
       this.el.hide();
    },

    _onLoad: function() {
      var self = this;
      var loc = $('body').data('site-root');
      // see if page is in part of the same domain
      if (this.el.attr('src').substring(0, loc.length) === loc) {
        this._recalibrate();
        setTimeout(function() {
          self._recalibrate();
        }, this.options.timeout);
      } else {
        this.el.css('height', 600);
      }
    },

    _recalibrate: function() {
      var height = this.el.contents().find('body').outerHeight(true);
      height = Math.max(height, this.options.minHeight);
      this.el.css('height', height + this.options.padding);
    },

    // firefox caches iframes so force it to get fresh content
    _FirefoxFix: function() {
      if(/#$/.test(this.el.src)) {
        this.el.src = this.el.src.substr(0, this.src.length - 1);
      } else {
        this.el.src = this.el.src + '#';
      }
    }
  };
});
