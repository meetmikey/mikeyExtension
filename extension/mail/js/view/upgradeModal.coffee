template = """
  <div class="modal hide fade modal-wide" style="display: none;">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Upgrade Mikey</h3>
    </div>
    <div class="modal-body">
      <p>
        Thanks for your interest in upgrading Mikey!
      </p>
      <p>
        <div id='mm-stripe-basic'></div>
        <div id='mm-stripe-pro'></div>
      </p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Not now</a>
    </div>
  </div>
"""

class MeetMikey.View.UpgradeModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  subViews:
    'stripeBasic':
      viewClass: MeetMikey.View.PayWithStripe
      selector: '#mm-stripe-basic'
      args: {plan: 'basic'}
    'stripePro':
      viewClass: MeetMikey.View.PayWithStripe
      selector: '#mm-stripe-pro'
      args: {plan: 'pro'}

  events:
    'hidden .modal': 'modalHidden'

  getTemplateData: =>
    object = {}
    object