template = """
  <div class="mail-counts">

    <div class="mail-days mm-download-tooltip" data-toggle="tooltip" title="How much of your Gmail archive Mikey is showing you">
      {{#if isFullyIndexed}}
        <strong>{{mailTotalDays}}</strong> of <strong>{{mailTotalDays}}</strong> days archived
      {{else}}
        Showing <strong>{{mailDaysLimit}}</strong> of <strong>{{mailTotalDays}}</strong> days
      {{/if}}
    </div>
    <a href="#" class="get-more-link">
      {{#if isFullyIndexed}}
        share Mikey
      {{else}}
        get more
      {{/if}}
    </a>
  </div>
"""

class MeetMikey.View.MailCounts extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .get-more-link': 'openGetMoreModal'

  postInitialize: =>
    MeetMikey.globalUser?.on 'change', @render

  getTemplateData: =>
    isFullyIndexed = MeetMikey.globalUser?.isPremium() || ( MeetMikey.globalUser?.getDaysLimit() >= MeetMikey.globalUser?.getMailTotalDays() )
    object = {}
    object.mailDaysLimit = MeetMikey.globalUser?.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser?.getMailTotalDays()
    object.isFullyIndexed = isFullyIndexed
    object

  shouldShow: =>
    if MeetMikey.globalUser &&
    ! MeetMikey.globalUser.get('onboarding') &&
    MeetMikey.globalUser.getMailTotalDays()
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