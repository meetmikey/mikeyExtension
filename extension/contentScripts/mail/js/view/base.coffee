class MeetMikey.View.Base extends Backbone.View
  defaultArgs:
    render: true
    renderChildren: true
    append: false
    owned: true

  initialize: =>
    @preInitialize()
    @options = _.defaults (@options ? {}), @defaultArgs
    # cloning object because otherwise @subView objects are shared
    # between all instances of views
    @subViews = $.extend(true, {}, @subViews)
    @options = $.extend true, {}, @options
    for name, obj of @subViews
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
    @trigger 'teardown'
    @off()
    @remove() if @options.owned
    @undelegateEvents()
    this

  teardown: ->

  render: =>
    @preRender()
    if @options.render
      renderedTemplate = @template(@getTemplateData())
      if @options.append
        @$el.append renderedTemplate
      else
        @$el.html renderedTemplate
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
