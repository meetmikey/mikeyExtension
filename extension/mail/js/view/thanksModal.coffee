template = """
<div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Awesome. Thanks for connecting!</h3>
    </div>
    <div class="modal-body">
      <p>Mikey is already hard at work making your files, links and images searchable. We will give you a heads up as soon as he is ready.</p>

    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Thanks</a>
    </div>
  </div>
"""

class MeetMikey.View.ThanksModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'hidden .modal': 'modalHidden'