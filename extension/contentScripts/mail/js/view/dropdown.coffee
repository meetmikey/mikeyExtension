template = """
	<li class="dropdown gbt">
    <a class="dropdown-toggle" id="drop4" role="button" data-toggle="dropdown" href="#">Mikey <span class="mm-carat"></span></a>
    <ul id="menu1" class="dropdown-menu mm-menu" role="menu" aria-labelledby="drop4">
      <li><a tabindex="-1" href="http://mikey.uservoice.com">Suggest a feature</a></li>
      <li><a tabindex="-1" href="mailto:support@mikeyteam.com">Mikey support</a></li>
      <li><a tabindex="-1" href="#">Disable Mikey</a></li>
      <li class="divider"></li>
      <li><div class="index-status">Index depth<div class="index-number">30 days</div></div></li>
    </ul>
  </li>
"""

class MeetMikey.View.Dropdown extends MeetMikey.View.Base
  template: Handlebars.compile(template)
