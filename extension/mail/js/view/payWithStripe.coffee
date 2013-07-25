template = """
  <button class="payButton">Subscribe to {{plan}} plan</button>
"""

class MeetMikey.View.PayWithStripe extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  mikeyIcon: 'mikeyIcon120x120.png'

  events:
    'click .payButton': 'payButtonClicked'

  postInitialize: =>

  getTemplateData: =>
    object = {}
    object.plan = @options.plan
    object

  getReadableAmount: =>
    if @options.plan == 'basic'
      MeetMikey.Constants.basicPlanPriceReadable
    else
      MeetMikey.Constants.proPlanPriceReadable

  getTitle: =>
    'Mikey ' + @options.plan.capitalize() + ' Plan (' + @getReadableAmount() + '/month)'

  payButtonClicked: =>
    token = (res) =>
      stripeToken = res.id
      @performPayment stripeToken

    stripeData = {
        key: MeetMikey.Constants.stripeKey
      , plan: @options.plan
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

  performPayment: (stripeToken) =>
    userEmail = MeetMikey.globalUser?.get 'email'
    console.log 'performPayment, stripeToken: ', stripeToken, ', userEmail: ', userEmail
    MeetMikey.Helper.callAPI
      url: 'upgrade'
      type: 'POST'
      data:
        userEmail: userEmail
        plan: @options.plan
        stripeToken: stripeToken
      complete: @handlePaymentAPIResponse
