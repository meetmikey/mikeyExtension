class MeetMikey.View.BaseModal extends MeetMikey.View.Base

  postRender: =>
    console.log 'modal postRender'
    @show()

  show: =>
    $('.modal').modal 'hide'
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'
    @remove()

  modalHidden: (e) =>
    if e.target == e.currentTarget
      @hide()