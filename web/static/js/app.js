$(document).ready(function() {
  // init first batch of albums
  (function($, undefined) {
    window.msr = {};

    $('.album').each(function(i) {
      var _this = this;
      imagesLoaded(_this, function() {
        window.msr[i] = new Masonry($(_this).find('.photos')[0], {
          photoSelector: '.photo',
          gutter: 10,
        });
      });
    });
  })(Zepto);

  (function($, undefined) {
    var html = $('html');
    var about = $('.about');
    var aboutBox = $('.about-box');
    var toggle = false;

    var toggleAboutOn = function() {
      toggle = true;
      aboutBox.css({'right': 0});
    }

    var toggleAboutOff = function(e) {
      toggle = false;
      aboutBox.css({'right': '-200%'});
    }

    about.on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();

      if (toggle) {
        toggleAboutOff();
      } else {
        toggleAboutOn();
      }
    });

    html.on('click', function(e) {
      toggleAboutOff();
    });
  })(Zepto);

  // init lightbox for first batch of albums
  (function($, undefined) {
    // lightbox prototype
    var lb = $('.light-box');
    var close = function() {
      lb.css({'opacity': '0'});
      lb.css({'z-index': '-1'});
    }

    $('.light-box a').on('click', close);


    $('.photo').on('click', function(e) {
      var topY = 0;
      var photo = $(e.currentTarget);
      var image = photo.find('img');

      // replace thumbnail with high res image after loading it
      var highRes = new Image();
      highRes.onload = function() {
        lb.css({'background-image': 'url(' + image.prop('src').replace('thumb_', 'large_') + ')'});
      };
      highRes.src = image.prop('src').replace('thumb_', 'large_');

      lb.css({'background-image': 'url(' + image.prop('src') + ')'});
      lb.css({'background-position': '50% 50%', 'background-repeat': 'no-repeat',
              'background-size': 'contain', 'top': topY + 'px'})

      lb.css({'z-index': '5'});
      lb.css({'opacity': '1'});
    });
  })(Zepto);
});
