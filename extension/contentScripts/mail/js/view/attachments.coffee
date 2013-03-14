template = """
  {{#unless models}}
    <div class="mm-placeholder">Oops. It doesn't look like Mikey has any files for you.</div>
  {{else}}
    <table class="inbox-table" id="mm-attachments-table" border="0">
      <thead class="labels">
        <!-- <th class="mm-toggle-box"></th> -->

        <th class="mm-download">File</th>
        <th class="mm-icon"></th>
        <th class="mm-file"></th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-type">Type</th>
        <th class="mm-size">Size</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
    {{#each models}}
      <tr class="files" data-cid="{{cid}}">
        <!-- <td class="mm-toggle-box">
          <div class="checkbox"><div class="check"></div></div>
        </td> -->

        <td class="mm-download">&nbsp;</td>
        <td class="mm-icon" style="background:url('{{iconUrl}}') no-repeat;">&nbsp;</td>
        <td class="mm-file truncate">{{filename}}&nbsp;</td>
        <td class="mm-from truncate">{{from}}</td>
        <td class="mm-to truncate">{{to}}</td>
        <td class="mm-type truncate">{{readableFileType}}</td>
        <td class="mm-size truncate">{{size}}</td>
        <td class="mm-sent truncate">{{sentDate}}</td>
      </tr>
    {{/each}}
    </tbody>
    </table>
    <div class="rollover-container"></div>
  {{/unless}}
"""

class MeetMikey.View.Attachments extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .files': 'openAttachment'
    'mouseenter .mm-file, .mm-icon': 'startRollover'
    'mouseleave .mm-file, .mm-icon': 'cancelRollover'
    'mousemove .mm-file, .mm-icon': 'delayRollover'

  pollDelay: 1000*45

  preInitialize: =>

  postInitialize: =>
    @collection = new MeetMikey.Collection.Attachments()
    @collection.on 'reset add', _.debounce(@render, 50)
    if @options.fetch
      @collection.fetch success: @waitAndPoll

  postRender: =>
    @rollover = new MeetMikey.View.AttachmentRollover el: @$('.rollover-container'), collection: @collection

  teardown: =>
    @collection.off('reset', @render)

  getTemplateData: =>
    models: _.invoke(@collection.models, 'decorate')

  openAttachment: (event) =>
    cid = $(event.currentTarget).attr('data-cid')
    model = @collection.get(cid)
    url = MeetMikey.Decorator.Attachment.getUrl model

    window.open(url)

  startRollover: (event) => @rollover.startSpawn event

  delayRollover: (event) => @rollover.delaySpawn event

  cancelRollover: => @rollover.cancelSpawn()

  waitAndPoll: =>
    setTimeout @poll, @pollDelay

  poll: =>
    console.log 'attachments are polling'
    @collection.fetch
      update: true
      remove: false
      data:
        after: @collection.first()?.get('sentDate')
      success: @waitAndPoll
      error: @waitAndPoll
