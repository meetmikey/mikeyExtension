template = """
  <div class="mail-counts">
    <div class="mail-days mm-download-tooltip" data-toggle="tooltip" title="How much of your Gmail archive Mikey is showing you"><strong>{{mailDaysLimit}}</strong> of <strong>{{mailTotalDays}}</strong> days archived</div><a href="#" class="get-more-link">share Mikey</a>

  </div>
"""

class MeetMikey.View.MailCounts extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .get-more-link': 'openGetMoreModal'

  postInitialize: =>
    MeetMikey.globalUser?.on 'change', @render

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