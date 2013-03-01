class MeetMikey.View.Base extends Backbone.View
  defaultArgs:
    render: true
    renderChildren: true

  initialize: =>
    @preInitialize()
    for name, obj of @subViews
      args = _.defaults (obj.args ? {}), @defaultArgs
      obj.view = new obj.viewClass(obj.args)
      obj.view.setElement obj.selector
    @postInitialize()
    this

  preInitialize: ->
  postInitialize: ->

  subView: (name) =>
    @subViews[name]?.view

  _teardown: =>
    _.chain(@subViews).values().pluck('view').invoke('_teardown')

    @teardown()
    @off()
    @remove()
    @undelegateEvents()
    this

  teardown: ->

  render: =>
    @preRender()
    # console.log 'render', @options, 'and recurse', @renderChildren
    @$el.html @template(@getTemplateData()) if @options.render
    @renderSubviews() if @options.renderChildren
    @postRender()
    this

  preRender: ->
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
    view.setElement(@$ selector).render()
