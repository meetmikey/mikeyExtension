// Generated by CoffeeScript 1.4.0
(function() {
  var template,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  template = "{{#unless models}}\n  There doesn't seem to be any files here!?!\n{{else}}\n  <table class=\"inbox-table\" id=\"mm-attachments-table\" border=\"0\">\n    <thead class=\"labels\">\n      <th class=\"mm-toggle-box\"></th>\n      <th class=\"mm-file\">File</th>\n      <th class=\"mm-from\">From</th>\n      <th class=\"mm-to\">To</th>\n      <th class=\"mm-type\">Type</th>\n      <th class=\"mm-size\">Size</th>\n      <th class=\"mm-sent\">Sent</th>\n    </thead>\n    <tbody>\n  {{#each models}}\n    <tr class=\"files\" data-attachment-url=\"{{getAPIUrl}}/attachmentURL/{{_id}}\">\n      <td class=\"mm-toggle-box\">\n        <div class=\"checkbox\"><div class=\"check\"></div></div>\n      </td>\n      <td class=\"mm-file truncate\">{{filename}}</td>\n      <td class=\"mm-from truncate\">{{from}}</td>\n      <td class=\"mm-to truncate\">{{to}}</td>\n      <td class=\"mm-type truncate\">pdf</td>\n      <td class=\"mm-size truncate\">{{size}}</td>\n      <td class=\"mm-sent truncate\">{{sentDate}}</td>\n    </tr>\n  {{/each}}\n  </tbody>\n  </table>\n{{/unless}}";

  MeetMikey.View.Attachments = (function(_super) {

    __extends(Attachments, _super);

    function Attachments() {
      this.openAttachment = __bind(this.openAttachment, this);

      this.getTemplateData = __bind(this.getTemplateData, this);

      this.teardown = __bind(this.teardown, this);

      this.postInitialize = __bind(this.postInitialize, this);
      return Attachments.__super__.constructor.apply(this, arguments);
    }

    Attachments.prototype.template = Handlebars.compile(template);

    Attachments.prototype.events = {
      'click tr': 'openAttachment'
    };

    Attachments.prototype.postInitialize = function() {
      this.collection = new MeetMikey.Collection.Attachments();
      this.collection.on('reset', this.render);
      return this.collection.fetch();
    };

    Attachments.prototype.teardown = function() {
      return this.collection.off('reset', this.render);
    };

    Attachments.prototype.getTemplateData = function() {
      return {
        models: _.map(this.collection.models, function(model) {
          return new MeetMikey.Decorator.Attachment(model);
        })
      };
    };

    Attachments.prototype.openAttachment = function(event) {
      var target, url;
      target = $(event.currentTarget);
      url = target.attr('data-attachment-url');
      return window.open(url);
    };

    return Attachments;

  })(MeetMikey.View.Base);

}).call(this);
