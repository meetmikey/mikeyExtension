// Generated by CoffeeScript 1.4.0
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MeetMikey.Collection.Links = (function(_super) {

    __extends(Links, _super);

    function Links() {
      return Links.__super__.constructor.apply(this, arguments);
    }

    Links.prototype.url = MeetMikey.Settings.APIUrl + '/link';

    Links.prototype.model = MeetMikey.Model.Link;

    return Links;

  })(MeetMikey.Collection.Base);

}).call(this);
