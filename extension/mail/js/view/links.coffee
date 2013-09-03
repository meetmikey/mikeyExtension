spriteUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
driveIcon = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/google-drive-icon.png")

linkTemplate = """
  <tr class="files" data-cid="{{cid}}">

    <td class="mm-madness mm-download shift-right" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="View email">
        <div class="inbox-icon message"></div>
      </div>
    </td>

    <td class="mm-madness mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Star">
        <div id="mm-resource-favorite-{{cid}}" class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
      </div>
    </td>

    <td class="mm-madness mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
        <div id="mm-resource-like-{{cid}}" class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
      </div>
    </td>
 
    {{#if isGoogleDoc}}
      <td class="mm-favicon" style="background:url('#{driveIcon}') no-repeat;">&nbsp;</td>
    {{else}}
      <td class="mm-favicon" style="background:url({{faviconURL}}) no-repeat;">&nbsp;</td>
    {{/if}}

    <td class="mm-file truncate" {{#if deleting}}style="display:none;{{/if}}>
      <div class="flex">
        {{title}}
        <span class="mm-file-text">{{summary}}</span>
      </div>
      <div class="mm-hide hide-overlay">
        <div class="close-x">Hide link</div>
      </div>
    </td>

    <td class="mm-undo truncate" {{#unless deleting}}style="display:none;{{/unless}}>
      <div class="flex">
        Link is hidden! <strong>Undo</strong> 
      </div> 
    </td>

    <td class="mm-source truncate" {{#if deleting}}style="opacity:0.1"{{/if}}><div class="inner-text">{{displayUrl}}</div></td>
    <td class="mm-from truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{from}}</td>
    <td class="mm-to truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{to}}</td>
    <td class="mm-sent truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{sentDate}}</td>

  </tr>
"""

template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
  {{else}}
    <div class="section-header active">
      <div class="section-toggle">
        <div class="section-arrow active">
        </div>
        <div class="section-name active">
          {{sectionHeader}}
        </div>
      </div>
      <div class="pagination-container"></div>
      <div class="section-border"></div>
    <div class='sectionContents'>
      <table class="inbox-table search-results" id="mm-links-table" border="0">
        <thead class="labels">
          <th class="mm-download" colspan="4" data-mm-field="title">Link<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-file mm-link"></th>
          <th class="mm-source" data-mm-field="url">Source<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-from" data-mm-field="sender">From<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-to" data-mm-field="recipients">To<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-sent" data-mm-field="sentDate">Sent<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        </thead>
        <tbody class="resourceModelsStart">
          {{#each models}}
            """ + linkTemplate + """
          {{/each}}
        </tbody>
      </table>
      <div class="rollover-container"></div>
    </div>
  {{/unless}}
"""

class MeetMikey.View.Links extends MeetMikey.View.ResourcesList
  
  template: Handlebars.compile(template)
  resourceTemplate: Handlebars.compile(linkTemplate)
  modelClass: MeetMikey.Model.Link
  collectionClass: MeetMikey.Collection.Links
  rolloverClass: MeetMikey.View.LinkRollover
  resourceType: 'link'

  subViews:
    'pagination':
      selector: '.pagination-container'
      viewClass: MeetMikey.View.Pagination
      args: {}

  events:
    'click .files .mm-file': 'openResource'
    'click .files .mm-source': 'openResource'
    'click .files .mm-download': 'openMessage'
    'click .close-x' : 'markDeletingEvent'
    'click .files .mm-undo' : 'unMarkDeletingEvent'
    'click th': 'sortByColumn'
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'
    'click .section-toggle': 'sectionToggle'
    'mouseenter .files .mm-file, .files .mm-source': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-source': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-source': 'delayRollover'