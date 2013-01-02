// Generated by CoffeeScript 1.3.3

dojo.provide('app.layout.LayerAndNotice');

dojo.require('dojo.date.locale');

dojo.declare('app.layout.LayerAndNotice', null, {
  count: 0,
  logs: [],
  components: {
    layer: null,
    loading: null,
    notice: null
  },
  constructor: function() {
    this.setLayer();
    this.setNoticeArea();
    return this.setSubscribe();
  },
  setLayer: function() {
    this.components.layer = $('<div id="layer"></div>');
    return $(this.components.layer).css({
      'position': 'absolute',
      'zIndex': '5',
      'width': '100%',
      'height': '100%',
      'backgroundColor': '#555',
      'opacity': '0.5',
      'backgroundImage': 'url(img/loading.gif)',
      'backgroundRepeat': 'no-repeat',
      'backgroundPosition': 'center center',
      'display': 'none'
    }).appendTo('body');
  },
  setNoticeArea: function() {
    this.components.loading = $('<div id="notice">Loading</div>');
    $(this.components.loading).css({
      'zIndex': '6',
      'position': 'absolute',
      'width': '100%',
      'textAlign': 'center',
      'top': '50%',
      'margin-top': '-9px',
      'font-weight': 'bold',
      'font-size': '18px',
      'color': '#D2EAF5'
    }).appendTo(this.components.layer);
    this.components.notice = $('<div id="noticeArea"></div>');
    return $(this.components.notice).css({
      'margin-top': '80px',
      'font-size': '15px'
    }).appendTo(this.components.loading);
  },
  setSubscribe: function() {
    dojo.subscribe('layout/LAN/fadeIn', this, this.fadeIn);
    dojo.subscribe('layout/LAN/fadeOut', this, this.fadeOut);
    dojo.subscribe('layout/LAN/setNotice', this, this.setNotice);
    return dojo.subscribe('layout/LAN/clearNotice', this, this.clearNotice);
  },
  fadeIn: function(string) {
    this.count++;
    console.log('layer> now count is ' + this.count);
    return $(this.components.layer).fadeIn(50);
  },
  fadeOut: function(string) {
    var _this = this;
    this.count--;
    console.log('layer> now count is ' + this.count);
    if (this.count === 0) {
      console.log('layer> count is zero, fade-out');
      return $(this.components.layer).fadeOut(200, function() {
        return _this.clearNotice();
      });
    }
  },
  setNotice: function(string) {
    this.logs.push({
      'time': dojo.date.locale.format(new Date(), "yyyy/MM/dd HH:mm"),
      'string': string
    });
    return $(this.components.notice).text(string);
  },
  clearNotice: function() {
    return $(this.components.notice).text('');
  }
});