template = """
  <div class="mmSubscribeButton {{billingPlan}} {{#if isActiveBillingPlan}}user-plan{{/if}}">
    <div class="status current">current</div>
    <div class="status cancel">cancel</div>
    <div class="status upgrade">get it</div>
    <div class="plan-highlight">
      <div class="plan-cost">
        <div class="per-month">{{billingPlanUpperCase}}</div>
        <div class="dollar-sign">$</div>
        <div class="amount">{{amount}}</div>
      </div>
    </div>
    <div class="plan-feature">{{numDaysString}}</div>
    <div class="plan-feature">{{numAccountsString}}</div>
  </div>
"""

class MeetMikey.View.PayWithStripe extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  mikeyIcon: 'mikeyIcon120x120.png'

  events:
    'click .mmSubscribeButton': 'subscribeButtonClicked'

  postInitialize: =>

  getTemplateData: =>
    object = {}
    object.billingPlan = @options.billingPlan
    object.billingPlanUpperCase = @options.billingPlan.capitalize()
    object.isActiveBillingPlan = @isActiveBillingPlan()
    object.amount = @getAmount()
    object.numDaysString = @getNumDaysString()
    object.numAccountsString = @getNumAccountsString()
    object

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
    else
      days = MeetMikey.Constants.teamPlanDays
    days + ' days'

  getNumAccountsString: =>
    if @options.billingPlan == 'basic'
      numAccounts = MeetMikey.Constants.basicPlanNumAccounts
    else if @options.billingPlan == 'pro'
      numAccounts = MeetMikey.Constants.proPlanNumAccounts
    else
      numAccounts = MeetMikey.Constants.teamPlanNumAccounts
    label = ' account'
    if numAccounts != 1
      label += 's'
    numAccounts + label


  subscribeButtonClicked: =>
    token = (res) =>
      stripeCardToken = res.id
      @performPayment stripeCardToken

    stripeData = {
        key: MeetMikey.Constants.stripeKey
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

  paymentSuccess: =>
    console.log 'payment success!'

  paymentFail: =>
    console.log 'payment fail!'

  handlePaymentAPIResponse: (response, status) =>
    if status && status == 'success'
      @paymentSuccess()
    else
      @paymentFail()

  performPayment: (stripeCardToken) =>
    userEmail = MeetMikey.globalUser?.get 'email'
    MeetMikey.Helper.callAPI
      url: 'upgrade'
      type: 'POST'
      data:
        userEmail: userEmail
        billingPlan: @options.billingPlan
        stripeCardToken: stripeCardToken
      complete: @handlePaymentAPIResponse
