viewthing = null
class MeetMikey.View.Base extends Backbone.View
  defaultArgs:
    render: true
    renderChildren: true

  initialize: =>
    @preInitialize()
    @options = _.defaults (@options ? {}), @defaultArgs
    # cloning object because otherwise @subView objects are shared
    # between all instances of views
    @subViews = $.extend(true, {}, @subViews)
    @options = $.extend true, {}, @options
    for name, obj of @subViews
      obj.view = new obj.viewClass(obj.args)

      if name is 'attachments'
        console.log 'view cmp', viewthing == obj.view
        viewthing = obj.view

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
