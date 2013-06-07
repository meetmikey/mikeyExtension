class MeetMikey.View.BaseModal extends MeetMikey.View.Base

  events:
    'hidden .modal': 'remove'

  postRender: =>
    @show()

  show: =>
    $('.modal').modal 'hide'
    @$('.modal').modal 'show'

  hide: =>
    $('.modal').modal 'hide'