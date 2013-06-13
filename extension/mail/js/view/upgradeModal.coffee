template = """
  <div class="modal hide fade modal-wide" style="display: none;">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Upgrade Mikey</h3>
    </div>
    <div class="modal-body">
      <p>
        Thanks for your interest in upgrading to premium Mikey!
      </p>
      <p>
        We'll be rolling out our pricing soon, and we'll let you know when it's ready.
        If you have any questions in the meantime, you can reach Team Mikey by <a href="mailto:support@mikeyteam.com">email</a>.
      </p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Great</a>
    </div>
  </div>
"""

class MeetMikey.View.UpgradeModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  postRender: =>
    super
    MeetMikey.Helper.Analytics.trackEvent 'viewUpgradeModal'
    @notifyAboutUpgradeInterest()

  notifyAboutUpgradeInterest: =>
    if MeetMikey.Constants.env is 'production'
      email = MeetMikey.globalUser?.get('email')
      MeetMikey.Helper.callAPI
        url: 'upgradeInterest'
        type: 'GET'
        data:
          userEmail: email