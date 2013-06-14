template = """
  <div class="mail-counts">
    <div class="mail-days mm-download-tooltip" data-toggle="tooltip" title="This is how much of your Gmail Mikey is showing you">{{mailDaysLimit}} out of {{mailTotalDays}} possible days</div><a href="#" class="get-more-link">get more</a>

  </div>
"""

class MeetMikey.View.MailCounts extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .get-more-link': 'openGetMoreModal'

  postInitialize: =>
    MeetMikey.globalUser?.once 'doneOnboarding', @render

  getTemplateData: =>
    object = {}
    object.mailDaysLimit = MeetMikey.globalUser.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser.getMailTotalDays()
    object

  shouldShow: =>
    if MeetMikey.globalUser &&
    ! MeetMikey.globalUser.isPremium() &&
    ! MeetMikey.globalUser.get('onboarding') &&
    MeetMikey.globalUser.getMailTotalDays() &&
    MeetMikey.globalUser.getDaysLimit() &&
    MeetMikey.globalUser.getMailTotalDays() > MeetMikey.globalUser.getDaysLimit()
      true
    else
      false

  postRender: =>
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    if @shouldShow()
      @$el.show()
    else
      @$el.hide()

  openGetMoreModal: =>
    $('body').append $('<div id="mm-get-more-modal"></div>')
    @getMoreModal = new MeetMikey.View.GetMoreModal el: '#mm-get-more-modal'
    @getMoreModal.render()