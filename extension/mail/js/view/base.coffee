class MeetMikey.View.Base extends Backbone.View
  logger: MeetMikey.Helper.Logger

  defaultArgs:
    render: true # should we replace content of $el with a template
    renderChildren: true # should we render our subViews on render
    append: false # should we append the template to $el rather than replace
    owned: true # do we own $el? can we destroy it on teardown?

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
      obj.view.parentView = this
    @postInitialize()
    this

  preInitialize: ->
  postInitialize: ->

  subView: (name) =>
    @subViews[name]?.view

  _teardown: =>
    @teardown()
    _.chain(@subViews).values().pluck('view').invoke('_teardown')

    @trigger 'teardown'
    @off()
    @remove() if @options.owned
    @undelegateEvents()
    this

  teardown: ->

  render: =>
    @preRender()
    if @options.render
      @renderTemplate()
    @renderSubviews() if @options.renderChildren
    @postRender()
    this

  renderTemplate: =>
    renderedTemplate = @template(@getTemplateData())
    if @options.append
      @$el.append renderedTemplate
    else
      @$el.html renderedTemplate
      
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
