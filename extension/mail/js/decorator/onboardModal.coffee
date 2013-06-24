class OnboardModalDecorator

  decorate: (model) =>
    object = {}
    object.errMsg = model.get('errMsg')
    object.cid = model.cid

    object


MeetMikey.Decorator.OnboardModal = new OnboardModalDecorator()