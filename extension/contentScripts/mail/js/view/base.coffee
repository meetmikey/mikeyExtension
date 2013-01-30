class MeetMikey.View.Base extends Backbone.View
  initialize: =>
    for name, obj of @subViews
      obj.view = new obj.view(obj.args)
    this

  _teadown: =>
    _.chain(@subViews).values().pluck('view').invoke('_teardown')

    @teardown()
    @off()
    @remove()
    @undelegateEvents()
    this

  teardown: ->

  render: =>
    @$el.html @template(@getTemplateData())
    @renderSubviews()
    this

  getTemplateData: -> {}

  renderSubviews: =>
    for name of @subViews
      @renderSubview name
    this

  renderSubview: (name) =>
    view = @subViews[name]
    @assign view.selector, view.view
    this

  assign: (selector, view) =>
    view.setElement(selector).render()
