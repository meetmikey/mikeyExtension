template = """
  {{#unless models}}
    Hold up, finding your images boss
  {{else}}
    {{#each models}}
      <div class="image-box">
        <img class="mm-image" src="{{image}}" />
        <span>{{filename}}</span>
      </div>
    {{/each}}
    <div style="clear: both;"></div>
  {{/unless}}
"""

class MeetMikey.View.Images extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  postInitialize: =>
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset', @render
    @once 'showTab', @initIsotope

  postRender: =>

  getTemplateData: =>
    models: _.map(@collection.models, (model) -> new MeetMikey.Decorator.Attachment model)

  initIsotope: =>
    console.log 'isotoping'
    @$el.imagesLoaded =>
      @$el.isotope
        filter: '*'
        animationOptions:
          duration: 750
          easing: 'linesar'
          queue: false
