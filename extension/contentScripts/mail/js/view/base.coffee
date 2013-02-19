class MeetMikey.View.Base extends Backbone.View
  initialize: =>
    for name, obj of @subViews
      obj.view = new obj.view(obj.args)
      obj.view.setElement obj.selector
    @postInitialize()
    this

  postInitialize: ->

  subView: (name) =>
    @subViews[name].view

  _teardown: =>
    _.chain(@subViews).values().pluck('view').invoke('_teardown')

    @teardown()
    @off()
    @remove()
    @undelegateEvents()
    this

  teardown: ->

  renderSelf: true
  renderChildren: true

  render: =>
    @$el.html @template(@getTemplateData()) if @renderSelf
    @renderSubviews() if @renderChildren
    @postRender()
    this

  postRender: ->

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
