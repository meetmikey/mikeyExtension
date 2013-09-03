spriteUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")

attachmentTemplate = """
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

    <td class="mm-icon" style="background:url('{{iconUrl}}') no-repeat; {{#if deleting}}opacity:0.1{{/if}}">&nbsp;</td>
    <td class="mm-undo" {{#unless deleting}}style="display:none;"{{/unless}}>File is hidden! <strong>Undo</strong></td>

    <td class="mm-file truncate" {{#if deleting}}style="display:none;"{{/if}}><div class="inner-text">{{filename}}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
      <div class="mm-hide hide-overlay">
        <div class="close-x">Hide file</div>
      </div>
    </td>

    <td class="mm-from truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{from}}</td>
    <td class="mm-to truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{to}}</td>
    <td class="mm-type truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{type}}</td>
    <td class="mm-size truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{size}}</td>
    <td class="mm-sent truncate fader" {{#if deleting}}style="opacity:0.1"{{/if}}>{{sentDate}}</td>
    
  </tr>
"""

template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
  {{else}}
  
  <div class="section-header active">
    <div class="section-toggle">
      <div class="section-arrow active"></div>
      <div class="section-name active">
        {{sectionHeader}}
      </div>
    </div>
    <div class="pagination-container"></div>
    <div class="section-border"></div>

    <div class='sectionContents'>
      <table class="inbox-table search-results" id="mm-attachments-table" border="0">
        <thead class="labels">
          <!-- <th class="mm-toggle-box"></th> -->

          <th class="mm-download" colspan="4" data-mm-field="filename">file<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-file">&nbsp;</th>
          <th class="mm-from" data-mm-field="sender">From<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-to" data-mm-field="recipients">To<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-type" data-mm-field="docType">Type<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-size" data-mm-field="fileSize">Size<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-sent" data-mm-field="sentDate">Sent<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>

        </thead>
        <tbody class="resourceModelsStart">
          {{#each models}}
            """ + attachmentTemplate + """
          {{/each}}
        </tbody>
      </table>
    </div>

  </div>
  {{/unless}}
"""

class MeetMikey.View.Attachments extends MeetMikey.View.ResourcesList
  
  template: Handlebars.compile(template)
  resourceTemplate: Handlebars.compile(attachmentTemplate)
  modelClass: MeetMikey.Model.Attachment
  collectionClass: MeetMikey.Collection.Attachments
  rolloverClass: MeetMikey.View.AttachmentRollover
  resourceType: 'attachment'

  subViews:
    'pagination':
      selector: '.pagination-container'
      viewClass: MeetMikey.View.Pagination
      args: {render: true}

  events:
    'click .files .mm-file': 'openResource'
    'click .files .mm-download': 'openMessage'
    'click .mm-hide' : 'markDeletingEvent'
    'click .files .mm-undo' : 'unMarkDeletingEvent'
    'click th': 'sortByColumn'
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'
    'click .section-toggle': 'sectionToggle'
    'mouseenter .files .mm-file, .files .mm-icon': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-icon': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-icon': 'delayRollover'