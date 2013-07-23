template = """
  <button class="payButton">Subscribe to {{plan}} plan</button>
"""

class MeetMikey.View.PayWithStripe extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  mikeyIcon: 'mikey-icon 120x120.png'

  events:
    'click .payButton': 'payButtonClicked'

  postInitialize: =>

  getTemplateData: =>
    object = {}
    object.plan = @options.plan
    object

  getAmount: =>
    if @options.plan == 'basic'
      199
    else
      499

  getReadableAmount: =>
    if @options.plan == 'basic'
      '$1.99'
    else
      '$4.99'

  getTitle: =>
    'Mikey ' + @options.plan.capitalize() + ' plan'

  getDescription: =>
    @getTitle() + ' (' + @getReadableAmount() + '/month)'

  payButtonClicked: =>
    token = (res) =>
      stripeToken = res.id
      @performPayment stripeToken

    stripeData = {
        key: MeetMikey.Constants.stripeKey
      , amount: @getAmount()
      , plan: @options.plan
      , currency: 'usd'
      , name: @getTitle()
      , description: @getDescription()
      , panelLabel: 'Checkout'
      , token: token
      , 'data-image': chrome.extension.getURL MeetMikey.Constants.imgPath + '/' + @mikeyIcon
    }
    StripeCheckout.open stripeData
    false

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