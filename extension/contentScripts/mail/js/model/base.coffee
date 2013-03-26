class MeetMikey.Model.Base extends Backbone.Model

  decorate: =>
    @decorator.decorate this

  increment: (attr, n) =>
    @set attr, @get(attr) + n

  decrement: (attr, n) =>
    @set attr, @get(attr) - n
