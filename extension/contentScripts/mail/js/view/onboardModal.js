(function() {
  var template,
    _this = this,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  template = "<div class=\"modal hide fade\">\n  <div class=\"modal-header\">\n    <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button>\n    <h3>Get Mikey</h3>\n  </div>\n  <div class=\"modal-body\">\n    <p>You need to let Mikey access your Gmail in order to let him work his magic.</p>\n  </div>\n\n\n  <div class=\"footer-buttons\">\n    <a href=\"#\" id=\"authorize-button\" class=\"button buttons\">Connect</a>\n    <a href=\"#\" id=\"not-now-button\" class=\"button-grey buttons\">Not right now</a>\n    <a href=\"#\" id=\"not-now-button\" class=\"button-grey buttons\">Never this account</a>\n    \n  </div>\n \n</div>";

  MeetMikey.View.OnboardModal = (function(_super) {

    __extends(OnboardModal, _super);

    function OnboardModal() {
      var _this = this;
      this.authorize = function() {
        return OnboardModal.prototype.authorize.apply(_this, arguments);
      };
      this.hide = function() {
        return OnboardModal.prototype.hide.apply(_this, arguments);
      };
      this.show = function() {
        return OnboardModal.prototype.show.apply(_this, arguments);
      };
      this.postRender = function() {
        return OnboardModal.prototype.postRender.apply(_this, arguments);
      };
      return OnboardModal.__super__.constructor.apply(this, arguments);
    }

    OnboardModal.prototype.template = Handlebars.compile(template);

    OnboardModal.prototype.events = {
      'click #authorize-button': 'authorize',
      'click #not-now-button': 'hide'
    };

    OnboardModal.prototype.postRender = function() {
      return this.show();
    };

    OnboardModal.prototype.show = function() {
      return this.$('.modal').modal('show');
    };

    OnboardModal.prototype.hide = function() {
      return this.$('.modal').modal('hide');
    };

    OnboardModal.prototype.authorize = function() {
      var _this = this;
      MeetMikey.Helper.OAuth.openAuthWindow(function(data) {
        return _this.trigger('authorized', data);
      });
      return this.hide();
    };

    return OnboardModal;

  })(MeetMikey.View.Base);

}).call(this);
