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
    html = '<div id="mmPaymentConfirmation" class="mm-alert alert fade in">You are awesome.<a class="close" data-dismiss="alert" href="#" style="text-decoration: none;">×</a></div>'
    $('body').append $(html)
    $('#mmPaymentConfirmation').addClass 'alert-' + type
    $('#mmPaymentConfirmation').on 'hide', () =>
      console.log 'alert hidden!'
      $('#mmPaymentConfirmation').remove()

  subscriptionChangeSubmitted: () =>
    console.log 'subscriptionChangeSubmitted'
    @hide()
    @showSubscriptionChangeNotification 'info'
    @$('#mmPaymentConfirmation').html 'Processing your Mikey subscription change...'
    
  paymentSuccess: (billingPlan) =>
    console.log 'upgradeModal paymentSuccess, billingPlan: ', billingPlan
    @tryReloadingUserWithBillingPlan billingPlan
    @showSubscriptionChangeNotification 'success'
    @$('#mmPaymentConfirmation').html 'Mikey payment success!'

  paymentFail: (billingPlan) =>
    console.log 'upgradeModal paymentFail, billingPlan: ', billingPlan
    @showSubscriptionChangeNotification 'error'
    $('#mmPaymentConfirmation').html 'Mikey payment failed.  You will not be charged.'

  cancelSuccess: (oldBillingPlan) =>
    console.log 'upgradeModal cancelSuccess, oldBillingPlan: ', oldBillingPlan
    @tryReloadingUserWithBillingPlan 'free'
    @showSubscriptionChangeNotification 'success'
    $('#mmPaymentConfirmation').html 'Mikey cancellation success.'

  cancelFail: (oldBillingPlan) =>
    console.log 'upgradeModal cancelFail, oldBillingPlan: ', oldBillingPlan
    @showSubscriptionChangeNotification 'error'
    $('#mmPaymentConfirmation').html 'Mikey Cancellation failed.  Please contact <a tabindex="-1" href="mailto:support@mikeyteam.com">support</a></li>.'


  tryReloadingUserWithBillingPlan: ( billingPlan, delayInput, numAttemptsInput ) =>
    numAttempts = 0
    if numAttemptsInput
      numAttempts = numAttemptsInput

    delay = 500
    if delayInput
      delay = delayInput

    setTimeout () =>
      MeetMikey.globalUser.refreshFromServer () =>
        if MeetMikey.globalUser.get('billingPlan') == billingPlan
          @renderSubviews()
        else if numAttempts >= 6
          @paymentFail()
        else
          @tryReloadingUserWithBillingPlan billingPlan, delay * 2, ( numAttempts + 1 )
    , delay

  getTemplateData: =>
    object = {}
    object