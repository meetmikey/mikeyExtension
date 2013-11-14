template = """
  <div class="modal hide fade modal-wide" style="display: none;">
    
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Upgrade Mikey</h3>
    </div>

    <div class="modal-body">
      <p>Your account is on the <b>Mikey {{billingPlanCapitalized}} Plan</b>.</p>


      {{#unless isGrantedPremium}}
        <p>Sadly, Mikey is shutting down so upgrading is no longer an option.</p>
        <p>Please contact <a href="mailto:support@mikeyteam.com" target="_blank">Mikey support</a> with any questions.</p>
        <p>Thanks for being a great customer.</p>

        <!--
        <div class='pricing'>
          <div id='mm-stripe-basic' class='pricing-tier'></div>
          <div id='mm-stripe-pro' class='pricing-tier'></div>
          <div id='mm-stripe-enterprise' class='pricing-tier'></div>
          <p>Simple monthly rates. No surprises. See Mikey's <a href="https://meetmikey.com/premium-terms.html" target="_blank">premium terms</a> for more info.</p>
        </div>
        -->

      {{/unless}}
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
    #'stripeTeam':
     #viewClass: MeetMikey.View.PayWithStripe
     #selector: '#mm-stripe-team'
     #args: {billingPlan: 'team'}
    'stripeEnterprise':
     viewClass: MeetMikey.View.PayWithStripe
     selector: '#mm-stripe-enterprise'
     args: {billingPlan: 'enterprise'}

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
    MeetMikey.Helper.Analytics.trackEvent 'paymentSuccess'
    @tryReloadingUserWithBillingPlan billingPlan
    @showSubscriptionChangeNotification 'success'
    $('#mmPaymentMessage').html 'Mikey payment success!  You are now subscribed to the Mikey ' + billingPlan.capitalize() + ' Plan.  It may take a few hours to process your account data.'

  paymentFail: (billingPlan) =>
    MeetMikey.Helper.Analytics.trackEvent 'paymentFail'
    @showSubscriptionChangeNotification 'error'
    $('#mmPaymentMessage').html 'Mikey payment failed.  You will not be charged.  Our <a tabindex="-1" href="mailto:support@mikeyteam.com">support team</a> has been notified.'

  cancelSuccess: (oldBillingPlan) =>
    MeetMikey.Helper.Analytics.trackEvent 'cancelSuccess'
    @tryReloadingUserWithBillingPlan 'free'
    @showSubscriptionChangeNotification 'success'
    $('#mmPaymentMessage').html 'Your Mikey subscription has been cancelled.'

  cancelFail: (oldBillingPlan) =>
    MeetMikey.Helper.Analytics.trackEvent 'cancelFail'
    @showSubscriptionChangeNotification 'error'
    $('#mmPaymentMessage').html 'Mikey subscription cancellation failed.  Our <a tabindex="-1" href="mailto:support@mikeyteam.com">support team</a> has been notified.'


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
          $('#mmPaymentConfirmation').remove()
          MeetMikey.Helper.Analytics.trackEvent 'userAccountUpdateFail', {billingPlan: billingPlan}
        else
          newDelay = delay * 2
          if newDelay == 0
            newDelay = 500
          @tryReloadingUserWithBillingPlan billingPlan, newDelay, ( numAttempts + 1 )
    , delay

  getTemplateData: =>
    object = {}
    object.billingPlanCapitalized = MeetMikey.globalUser.getBillingPlan().capitalize()
    object.isGrantedPremium = MeetMikey.globalUser.get('isGrantedPremium')
    object