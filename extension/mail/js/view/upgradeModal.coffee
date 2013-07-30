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

  showSubscriptionChangeNotification: (type) =>
    $('#mmPaymentConfirmation').remove()
    html = '<div id="mmPaymentConfirmation" class="mm-alert alert"><div id="mmPaymentMessage" style="display:inline-block;"></div><a class="close" data-dismiss="alert" href="#" style="text-decoration: none;">×</a></div>'
    $('body').prepend $(html)
    alertClass = 'alert-' + type
    $('#mmPaymentConfirmation').addClass alertClass

  subscriptionChangeSubmitted: () =>
    @hide()
    @showSubscriptionChangeNotification 'info'
    $('#mmPaymentMessage').html 'Processing your Mikey account update...'
    
  paymentSuccess: (billingPlan) =>
    @tryReloadingUserWithBillingPlan billingPlan
    @showSubscriptionChangeNotification 'success'
    $('#mmPaymentMessage').html 'Mikey payment success!  You are now subscribed to the Mikey ' + billingPlan.capitalize() + ' Plan.'

  paymentFail: (billingPlan) =>
    @showSubscriptionChangeNotification 'error'
    $('#mmPaymentMessage').html 'Mikey payment failed.  You will not be charged.  You may contact <a tabindex="-1" href="mailto:support@mikeyteam.com">support</a> for more information.'

  cancelSuccess: (oldBillingPlan) =>
    @tryReloadingUserWithBillingPlan 'free'
    @showSubscriptionChangeNotification 'success'
    $('#mmPaymentMessage').html 'Your Mikey subscription has been cancelled.'

  cancelFail: (oldBillingPlan) =>
    @showSubscriptionChangeNotification 'error'
    $('#mmPaymentMessage').html 'Mikey subscription cancellation failed.  You may contact <a tabindex="-1" href="mailto:support@mikeyteam.com">support</a> for more information.'


  tryReloadingUserWithBillingPlan: ( billingPlan, delayInput, numAttemptsInput ) =>
    numAttempts = 0
    if numAttemptsInput
      numAttempts = numAttemptsInput

    delay = 0
    if delayInput
      delay = delayInput

    setTimeout () =>
      MeetMikey.globalUser.refreshFromServer () =>
        if MeetMikey.globalUser.get('billingPlan') == billingPlan
          @renderSubviews()
        else if numAttempts >= 6
          @paymentFail()
        else
          newDelay = delay * 2
          if newDelay == 0
            newDelay = 500
          @tryReloadingUserWithBillingPlan billingPlan, newDelay, ( numAttempts + 1 )
    , delay

  getTemplateData: =>
    object = {}
    object