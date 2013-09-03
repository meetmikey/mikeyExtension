template = """
  <div class="mmPlanButton {{billingPlan}} {{#if isActiveBillingPlan}}user-plan{{/if}}">
    <div class="status current">current</div>
    <div class="status cancel">cancel</div>
    <div class="status upgrade">get it</div>
    <div class="status blank">&nbsp;</div>
    <div class="plan-highlight">
      <div class="plan-cost">
        {{#if isEnterprise}}
          <div class="per-month">enterprise</div>
          <div class="icon-enterprise"></div>
        {{else}}
          <div class="per-month">{{billingPlanUpperCase}}</div>
          <div class="dollar-sign">$</div>
          <div class="amount">{{amount}}</div>
        {{/if}}
      </div>
    </div>
    <div class="plan-feature">{{numDaysString}}</div>
    <div class="plan-feature">{{numAccountsString}}</div>
  </div>
"""
class MeetMikey.View.PayWithStripe extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  mikeyIcon: 'mikeyIcon120x120.png'
  contactEmailAddress: 'sales@mikeyteam.com'
  contactEmailSubject: "I'm interested in the Mikey Enterprise Plan"

  events:
    'click .mmPlanButton': 'planButtonClicked'

  getTemplateData: =>
    object = {}
    object.billingPlan = @options.billingPlan
    object.billingPlanUpperCase = @options.billingPlan.capitalize()
    object.isActiveBillingPlan = @isActiveBillingPlan()
    object.amount = @getAmount()
    object.numDaysString = @getNumDaysString()
    object.numAccountsString = @getNumAccountsString()
    object.isEnterprise = @isEnterprise()
    object

  isEnterprise: =>
    if ( @options.billingPlan == 'enterprise' )
      return true
    false

  isActiveBillingPlan: =>
    activeBillingPlan = MeetMikey.globalUser?.get('billingPlan')
    if activeBillingPlan == @options.billingPlan
      true
    else
      false

  getTitle: =>
    'Mikey ' + @options.billingPlan.capitalize() + ' Plan ($' + @getAmount() + '/month)'

  getAmount: =>
    if @options.billingPlan == 'basic'
      MeetMikey.Constants.basicPlanPrice
    else if @options.billingPlan == 'pro'
      MeetMikey.Constants.proPlanPrice
    else
      MeetMikey.Constants.teamPlanPrice
      
  getNumDaysString: =>
    if @options.billingPlan == 'basic'
      days = MeetMikey.Constants.basicPlanDays
    else if @options.billingPlan == 'pro'
      days = MeetMikey.Constants.proPlanDays
    else if @options.billingPlan == 'team'
      days = MeetMikey.Constants.teamPlanDays
    else
      days = MeetMikey.Constants.enterprisePlanDays
    days + ' days'

  getNumAccountsString: =>
    if @options.billingPlan == 'basic'
      numAccounts = MeetMikey.Constants.basicPlanNumAccounts
    else if @options.billingPlan == 'pro'
      numAccounts = MeetMikey.Constants.proPlanNumAccounts
    else if @options.billingPlan == 'team'
      numAccounts = MeetMikey.Constants.teamPlanNumAccounts
    else
      numAccounts = MeetMikey.Constants.enterprisePlanNumAccounts
    label = ' account'
    if numAccounts != 1
      label += 's'
    numAccounts + label

  planButtonClicked: =>
    if @isActiveBillingPlan()
      @cancelClicked()
    else
      @upgradeClicked()

  cancelClicked: =>
    MeetMikey.Helper.Analytics.trackEvent 'cancelSubscriptionClicked'
    if confirm 'Are you sure you want to cancel your plan?'
      @cancelSubscription()

  cancelSubscription: =>
    MeetMikey.Helper.Analytics.trackEvent 'cancelSubscription', {billingPlan: @options.billingPlan}
    @subscriptionChangeSubmitted()
    MeetMikey.Helper.callAPI
      url: 'cancelBillingPlan'
      type: 'POST'
      complete: @handleCancelAPIResponse

  subscriptionChangeSubmitted: =>
    @parentView.subscriptionChangeSubmitted()

  handleCancelAPIResponse: (response, status) =>
    if status && status == 'success'
      @parentView.cancelSuccess @options.billingPlan
    else
      @parentView.cancelFail @options.billingPlan

  upgradeClicked: =>
    MeetMikey.Helper.Analytics.trackEvent 'subscribeToPlanClicked', {billingPlan: @options.billingPlan}

    if @isEnterprise()
      contactMailToURL = 'mailto:' + @contactEmailAddress + '?subject=' + @contactEmailSubject
      window.open contactMailToURL
    else
      token = (res) =>
        stripeCardToken = res.id
        @performPayment stripeCardToken

      stripeData = {
          key: MeetMikey.Helper.getStripeKey()
        , billingPlan: @options.billingPlan
        , currency: 'usd'
        , name: @getTitle()
        #, description: 
        , panelLabel: 'Purchase'
        , token: token
        , image: chrome.extension.getURL MeetMikey.Constants.imgPath + '/' + @mikeyIcon
      }
      StripeCheckout.open stripeData
    false

  handlePaymentAPIResponse: (response, status) =>
    if status && status == 'success'
      @parentView.paymentSuccess @options.billingPlan
    else
      @parentView.paymentFail @options.billingPlan

  performPayment: (stripeCardToken) =>
    MeetMikey.Helper.Analytics.trackEvent 'subscribeToPlan', {billingPlan: @options.billingPlan}
    @subscriptionChangeSubmitted()
    MeetMikey.Helper.callAPI
      url: 'upgradeToBillingPlan'
      type: 'POST'
      data:
        billingPlan: @options.billingPlan
        stripeCardToken: stripeCardToken
      complete: @handlePaymentAPIResponse
