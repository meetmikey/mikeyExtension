// Generated by CoffeeScript 1.4.0
(function() {
  var template,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  template = "<div id=\"mm-tabs\"></div>\n<div id=\"mm-attachments-tab\" style=\"display: none;\"></div>\n<div id=\"mm-links-tab\" style=\"display: none;\"></div>";

  MeetMikey.View.Main = (function(_super) {

    __extends(Main, _super);

    function Main() {
      this.teardown = __bind(this.teardown, this);

      this.postRender = __bind(this.postRender, this);
      return Main.__super__.constructor.apply(this, arguments);
    }

    Main.prototype.template = Handlebars.compile(template);

    Main.prototype.subViews = {
      'tabs': {
        view: MeetMikey.View.Tabs,
        selector: '#mm-tabs'
      },
      'attachments': {
        view: MeetMikey.View.Attachments,
        selector: '#mm-attachments-tab'
      },
      'links': {
        view: MeetMikey.View.Links,
        selector: '#mm-links-tab'
      }
    };

    Main.prototype.tabs = {
      email: '.UI',
      attachments: '#mm-attachments-tab',
      links: '#mm-links-tab'
    };

    Main.prototype.postRender = function() {
      var contentSelector,
        _this = this;
      contentSelector = _.values(this.tabs).join(', ');
      return this.subView('tabs').on('clicked:tab', function(tab) {
        $(contentSelector).hide();
        return $(_this.tabs[tab]).show();
      });
    };

    Main.prototype.teardown = function() {
      return this.subView('tabs').off('clicked:tab');
    };

    return Main;

  })(MeetMikey.View.Base);

}).call(this);
