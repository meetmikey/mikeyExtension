template = """
  <div class="modal hide fade modal-wide" style="display: none;">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Upgrade Mikey</h3>
    </div>
    <div class="modal-body">
      <p>
        Simple monthly rates. No surprises.
      </p>
      <p>
       
        <div class="pricing">
          <div class="pricing-tier basic user-plan">
            <div class="status current">
              current
            </div>
            <div class="status cancel">
              cancel
            </div>
            <div class="status upgrade">
              get it
            </div>
            <div class="plan-highlight">
              <div class="plan-cost">
                <div class="per-month">
                  Basic
                </div>
                <div class="dollar-sign">
                  $
                </div>
                <div class="amount">
                  2
                </div>

              </div>
            </div>
            <div class="plan-feature">
              365 days
            </div>
            <div class="plan-feature">
              1 account
            </div>
            <!-- <div class="upgrade-button">
              upgrade now
            </div> -->
          </div>

          <div class="pricing-tier pro">
            <div class="status current">
              current
            </div>
            <div class="status cancel">
              cancel
            </div>
            <div class="status upgrade">
              get it
            </div>
            <div class="plan-highlight">
              <div class="plan-cost">
                <div class="per-month">
                  Pro
                </div>
                <div class="dollar-sign">
                  $
                </div>
                <div class="amount">
                  5
                </div>

              </div>
            </div>
            <div class="plan-feature">
              Unlimited days
            </div>
            <div class="plan-feature">
              1 account
            </div>
            <!-- <div class="upgrade-button">
              upgrade now
            </div> -->
          </div>

          <div class="pricing-tier team">
            <div class="status current">
              current
            </div>
            <div class="status cancel">
              cancel
            </div>
            <div class="status upgrade">
              get it
            </div>
            <div class="plan-highlight">
              <div class="plan-cost">
                <div class="per-month">
                  Team
                </div>

                <div class="dollar-sign">
                  $
                </div>
                <div class="amount">
                  20
                </div>

              </div>
            </div>
            <div class="plan-feature">
              Unlimited days
            </div>
            <div class="plan-feature">
              5 accounts
            </div>

            <!-- <div class="upgrade-button">
              upgrade now
            </div> -->
          </div>

 

          

      </p>
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