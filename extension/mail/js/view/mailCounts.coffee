template = """
  <div class="mail-counts">
    {{mailProcessedDays}}/{{mailTotalDays}} <a href="#" class="get-more-link">get more days</a>
  </div>
"""

class MeetMikey.View.MailCounts extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .get-more-link': 'openGetMoreModal'

  getTemplateData: =>
    object = {}
    object.mailProcessedDays = MeetMikey.globalUser.getMailProcessedDays()
    object.mailTotalDays = MeetMikey.globalUser.getMailTotalDays()
    object

  postRender: =>
    if MeetMikey.globalUser && MeetMikey.globalUser.getMailTotalDays() && ! MeetMikey.globalUser.isPremium()
      @$el.show()
    else
      @$el.hide()

  openGetMoreModal: =>
    $('body').append $('<div id="mm-get-more-modal"></div>')
    @getMoreModal = new MeetMikey.View.GetMoreModal el: '#mm-get-more-modal'
    @getMoreModal.render()