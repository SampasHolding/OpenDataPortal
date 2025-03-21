// Global ckan namespace
this.ckan = this.ckan || {};

(function (ckan, jQuery) {
  ckan.PRODUCTION = 'production';
  ckan.DEVELOPMENT = 'development';
  ckan.TESTING = 'testing';

  /* Initialises the CKAN JavaScript setting up environment variables and
   * loading localisations etc. Should be called once the page is ready.
   *
   * Examples
   *
   *   jQuery(function () {
   *     ckan.initialize();
   *   });
   *
   * Returns nothing.
   */
  ckan.initialize = function () {
    var body = jQuery('body');
    var locale = jQuery('html').attr('lang');
    var location = window.location;
    var root = location.protocol + '//' + location.host;

    function getRootFromData(key) {
      return (body.data(key) || root).replace(/\/$/, '');
    }

    ckan.SITE_ROOT   = getRootFromData('siteRoot');
    ckan.LOCALE_ROOT = getRootFromData('localeRoot');

    // Convert all datetimes to the users timezone
    jQuery('.automatic-local-datetime').each(function() {
        moment.locale(locale);
        var date = moment(jQuery(this).data('datetime'));
        if (date.isValid()) {
            jQuery(this).html(date.format("LL, LT ([UTC]Z)"));
        }
        jQuery(this).show();
    })

    // Load the localisations before instantiating the modules.
    ckan.sandbox().client.getLocaleData(locale).done(function (data) {
      ckan.i18n.load(data);
      ckan.module.initialize();
    });

    // Initialize all popovers on a page if popover function exists
    if (jQuery.fn.popover !== undefined) {
      jQuery('[data-bs-toggle="popover"]').popover();
    }
  };

  /* Returns a full url for the current site with the provided path appended.
   *
   * path          - A path to append to the url (default: '/')
   * includeLocale - If true the current locale will be added to the page.
   *
   * Examples
   *
   *   var imageUrl = sandbox.url('/my-image.png');
   *   // => http://example.ckan.org/my-image.png
   *
   *   var imageUrl = sandbox.url('/my-image.png', true);
   *   // => http://example.ckan.org/en/my-image.png
   *
   *   var localeUrl = sandbox.url(true);
   *   // => http://example.ckan.org/en
   *
   * Returns a url string.
   */
  ckan.url = function (path, includeLocale) {
    if (typeof path === 'boolean') {
      includeLocale = path;
      path = null;
    }

    path = (path || '').replace(/^\//, '');

    var root = includeLocale ? ckan.LOCALE_ROOT : ckan.SITE_ROOT;
    return path ? root + '/' + path : root;
  };

  ckan.sandbox.extend({url: ckan.url});

  if (ckan.ENV !== ckan.TESTING) {
    jQuery(function () {
      ckan.initialize();
    });
  }

})(this.ckan, this.jQuery);

// Show / hide filters for mobile
$(function() {
  $(".show-filters").click(function() {
    $("body").addClass("filters-modal");
  });
  $(".hide-filters").click(function() {
    $("body").removeClass("filters-modal");
  });
});

// Initialize tooltips using Bootstrap
$(function() {
  $('[data-bs-toggle="tooltip"]').each(function (index, element) {
    bootstrap.Tooltip.getOrCreateInstance(element)
  })
})
