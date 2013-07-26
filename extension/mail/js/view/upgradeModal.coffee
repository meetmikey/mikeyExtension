template = """
  <div class="modal hide fade modal-wide" style="display: none;">
    
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Upgrade Mikey</h3>
    </div>

    <div class="modal-body">
      <p>Simple monthly rates. No surprises.</p>
      <div class='pricing'>
        <div id='mm-stripe-basic' class='pricing-tier'></div>
        <div id='mm-stripe-pro' class='pricing-tier'></div>
        <div id='mm-stripe-team' class='pricing-tier'></div>
      </div>
    </div>

    <div class="footer-buttons">
      <!-- <a href="#" data-dismiss="modal" class="button buttons">Not now</a> -->
    </div>

  </div>
"""

class MeetMikey.View.UpgradeModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  subViews:
    'stripeBasic':
      viewClass: MeetMikey.View.PayWithStripe
      selector: '#mm-stripe-basic'
      args: {billingPlan: 'basic'}
    'stripePro':
      viewClass: MeetMikey.View.PayWithStripe
      selector: '#mm-stripe-pro'
      args: {billingPlan: 'pro'}
    'stripeTeam':
      viewClass: MeetMikey.View.PayWithStripe
      selector: '#mm-stripe-team'
      args: {billingPlan: 'team'}

  events:
    'hidden .modal': 'modalHidden'

  getTemplateData: =>
    object = {}
    object