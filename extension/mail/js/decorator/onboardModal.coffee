class OnboardModalDecorator

  decorate: (model) =>
    console.log ('decorate')
    object = {}
    object.errMsg = model.get('errMsg')
    object.cid = model.cid

    object


MeetMikey.Decorator.OnboardModal = new OnboardModalDecorator()