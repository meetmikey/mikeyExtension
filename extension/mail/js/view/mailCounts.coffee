template = """
  <div class="mail-counts" style="display: {{display}};>

    <div class="mail-days mm-download-tooltip" data-toggle="tooltip" title="How much of your Gmail archive Mikey is showing you">
      <a href="#" class="get-more-link">
        {{#if isFullyIndexed}}
          <strong>{{mailTotalDays}}</strong> of <strong>{{mailTotalDays}}</strong> days
        {{else}}
          <strong>{{mailDaysLimit}}</strong> of <strong>{{mailTotalDays}}</strong> days
        {{/if}}
      </a>
    </div>
    <a href="#" class="get-more-link" style="display: {{display}};">
      {{#if isFullyIndexed}}
        <!-- share Mikey -->
      {{else}}
        &nbsp get more
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
    Backbone.on 'change:tab', @render

  getTemplateData: =>
    isFullyIndexed = MeetMikey.globalUser?.isPremium() || ( MeetMikey.globalUser?.getDaysLimit() >= MeetMikey.globalUser?.getMailTotalDays() )
    object = {}
    object.mailDaysLimit = MeetMikey.globalUser?.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser?.getMailTotalDays()
    object.isFullyIndexed = isFullyIndexed
    object.display = @getDisplay()
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

  getDisplay: =>
    tab = MeetMikey.Globals.tabState
    tabsWidth = $('#mm-tabs-container').css('width')?.replace("px","")
    if !tabsWidth
      return 'inline'
    else
      tabsWidthInt = parseInt(tabsWidth, 10)
      method = if tab is 'email' or tabsWidthInt > 900 then 'inline' else 'none'