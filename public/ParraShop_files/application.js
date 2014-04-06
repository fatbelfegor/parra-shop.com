(function() {
  var expire, getCookie, iframe, menuImages, ready;

  iframe = document.createElement('iframe');

  menuImages = [];

  ready = function() {
    var color, count, curBg, i, item, items, minus, option, size, _i, _len;
    curBg = 0;
    $('#mainMenu li div div').each(function(i) {
      return this.style.backgroundImage = menuImages[i];
    });
    $('#mainMenu li ul li').mouseover(function() {
      $(this).parents('li').find('div div').eq(curBg).css('left', '-2000px');
      curBg = $(this).index();
      return $(this).parents('li').find('div div').eq(curBg).css('left', '0');
    });
    $('#addImages input').click(function() {
      iframe.src = '/images/new';
      return this.parentNode.appendChild(iframe);
    });
    window.cart = eval(getCookie('cart'));
    if (!cart) {
      window.cart = [];
    }
    count = 0;
    cart.forEach(function(i) {
      return count += i.c;
    });
    $('#cartCount').html(count);
    if ($('#cartfield')[0]) {
      $('#cartfield').val(JSON.stringify(cart));
    }
    if ($('#cart')[0]) {
      items = '';
      i = 0;
      for (_i = 0, _len = cart.length; _i < _len; _i++) {
        item = cart[_i];
        if (item.c > 1) {
          minus = '<span class="left" onclick="changeCount(this)">++</span>';
        } else {
          minus = '<span class="left invis">++</span>';
        }
        if (item.l) {
          color = '<p>Цвет: ' + item.l + '</p>';
        } else {
          color = '';
        }
        if (item.s) {
          size = '<p>Размер: ' + item.s + '</p>';
        } else {
          size = '';
        }
        if (item.o) {
          option = '<p>Опции: ' + item.o + '</p>';
        } else {
          option = '';
        }
        items += '<div><a href="/kupit/' + item.n + '"><img><div><div><p><ins>' + item.n + '</ins></p><p>Код: <s id="scode"></s></p>' + color + size + option + '</div></div></a><div><p><b>' + item.p + '</b> руб.</p></div><div onselectstart="return false">' + minus + '<span id="count">' + item.c + '</span><span class="right" onclick="changeCount(this)">+</span></div><div onclick="cartDelete(this)"><span>+</span>Удалить</div></div>';
        $.ajax({
          url: "/cart.json?name=" + item.n,
          success: function(data) {
            console.log(data);
            item = $('#cart > div')[i++];
            $(item).find('img').attr('src', data.images.split(',')[0]);
            return $(item).find('#scode').html(data.scode);
          }
        });
      }
      $('#cart').html(items);
      window.changeCount = function(el) {
        var div, name;
        div = el.parentNode.parentNode;
        name = $(div).find('ins')[0].innerHTML;
        item = (cart.filter(function(item) {
          return item.n === name;
        }))[0];
        if (el.innerHTML === '+') {
          item.c++;
          if (item.c > 1) {
            $(div).find('.invis').attr('class', 'left').attr('onclick', 'changeCount(this)');
          }
        } else {
          item.c--;
          if (item.c === 1) {
            $(el).attr('class', 'left invis').attr('onclick', '');
          }
        }
        $(div).find('#count').html(item.c);
        return saveCart();
      };
      window.cartDelete = function(el) {
        var name;
        name = $(el.parentNode.parentNode).find('ins')[0].innerHTML;
        cart.splice(cart.indexOf((cart.filter(function(item) {
          return item.n === name;
        }))[0], 1));
        el.parentNode.parentNode.removeChild(el.parentNode);
        return saveCart();
      };
    }
    $(".accordion h3").click(function() {
      $(this).next(".panel").slideToggle("slow").siblings(".panel:visible").slideUp("slow");
      $(this).toggleClass("active");
      return $(this).siblings("h3").removeClass("active");
    });
    if ($('.show')[0]) {
      window.currency = $('#price').html().split(' ')[1];
      window.priceNum = parseFloat($('#price').html());
      window.optionsPrice = function() {
        var price;
        price = 0;
        $('select :selected').each(function() {
          return price += parseFloat(this.value);
        });
        return price;
      };
      return $('#price').html((priceNum + optionsPrice()).toFixed(2) + ' ' + currency);
    }
  };

  $(document).ready(function() {
    $('#mainMenu li div div').each(function() {
      return menuImages.push(this.style.backgroundImage);
    });
    return ready();
  });

  $(document).on('page:load', ready);

  getCookie = function(name) {
    var matches;
    matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"));
    if (matches) {
      return decodeURIComponent(matches[1]);
    } else {
      return undefined;
    }
  };

  expire = function() {
    return new Date(new Date().setDate(new Date().getDate() + 30));
  };

  window.addToCart = function(name, price) {
    var count, i, l, o, prev, s;
    s = $('[name=prsizes] :selected').html();
    l = $('[name=prcolors] :selected').html();
    o = $('[name=proptions] :selected').html();
    i = $('#product_id_field').val();
    if (!s) {
      s = '';
    }
    if (!l) {
      l = '';
    }
    if (!o) {
      o = '';
    }
    prev = (cart.filter(function(item) {
      return item.s === s && item.l === l && item.o === o && item.i === i;
    }))[0];
    if (prev) {
      prev.c++;
    } else {
      cart.push({
        n: name,
        c: 1,
        p: price,
        s: s,
        l: l,
        o: o,
        i: i
      });
    }
    count = 0;
    price = 0;
    cart.forEach(function(i) {
      count += i.c;
      return price += parseFloat(i.p) * i.c;
    });
    $('#cartCount').html(count);
    $('body').append('<div id="alert"><div onclick="this.parentNode.parentNode.removeChild(this.parentNode)"></div><div style="top:' + ($(window).height() / 2 - 150) + 'px; left:' + ($(window).width() / 2 - 200) + 'px"><div><div onclick="this.parentNode.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode.parentNode)"></div></div><p>Товар "' + name + '" добавлен в <a href="/cart">корзину</a>.</p><p>В корзине ' + count + ', общая стоимость ' + price + '</p><a class="continue" onclick="this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode)">Продолжить покупки</a></div></div>');
    $('#alert').fadeIn(300);
    return saveCart();
  };

  window.saveCart = function() {
    cart.forEach(function(i) {
      return i.n = encodeURIComponent(i.n);
    });
    document.cookie = 'cart=' + JSON.stringify(cart) + ';path=/;expires=' + expire().toGMTString();
    return cart.forEach(function(i) {
      return i.n = decodeURIComponent(i.n);
    });
  };

  window.addImageUrl = function(url) {
    var images, imagesHtml, img, input, inputName, _i, _len;
    inputName = iframe.parentNode.className;
    input = $('#' + inputName);
    images = input.val().split(',');
    if (images[0] === '') {
      images = [];
    }
    images.push(url);
    imagesHtml = '';
    input.val(images.join(','));
    for (_i = 0, _len = images.length; _i < _len; _i++) {
      img = images[_i];
      imagesHtml += '<img src="' + img + '">';
    }
    if (inputName === "product_images") {
      $(iframe.parentNode).find('div').html(imagesHtml);
    } else {
      $(iframe.parentNode).html(imagesHtml);
    }
    return iframe.parentNode.removeChild(iframe);
  };

  window.deleteImage = function(el) {
    var images, index, li, url;
    li = el.parentNode;
    url = li.firstElementChild.href;
    $.get("/images/delete", {
      url: url
    });
    li.parentNode.removeChild(li);
    index = $('.images li').index(li);
    images = $('#product_images').val().split(',');
    images.splice(index, 1);
    $('#product_images').val(images.join(','));
    index = $('.images li').index(li);
    images = $('#product_images').val().split(',');
    return $('#product_images').val(images.join(','));
  };

  window.priceChange = function(el) {
    return $('#price').html((priceNum + optionsPrice()).toFixed(2) + ' ' + currency);
  };

}).call(this);
