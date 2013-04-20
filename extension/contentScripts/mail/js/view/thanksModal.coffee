template = """
<div>THANKS</div>
"""

class MeetMikey.View.ThanksModal extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  postRender: =>
    @show()

  show: =>
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'
