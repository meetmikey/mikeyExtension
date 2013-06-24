class ReAuthModalDecorator

  decorate: (model) =>
    object = {}
    object.errMsg = model.get('errMsg')
    object.cid = model.cid

    object


MeetMikey.Decorator.ReAuthModal = new ReAuthModalDecorator()