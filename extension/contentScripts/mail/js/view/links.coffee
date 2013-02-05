template = """
  <div>I EXIST</div>
"""

class MeetMikey.View.Links extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @collection.on 'reset', @render
    @collection.fetch()

  teardown: =>
    @collection.off 'reset', @render

  postRender: ->
    console.log @collection.models
    console.log ('yay i exist')
