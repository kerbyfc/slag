###*
 * @namespace Slag.Widgets
###
Slag.register class ContentTypesWidget extends Slag.Widget

  types: {}

  constructor: (el) ->
    super
    @setEl(el)
    unless _.size @types
      @types = _.map Slag.Contents, (c) -> _.pick c::, 'badge', 'icon', 'title'
    @render()

  render: ->
    for type in @types
      @$el.append @template('label', type)
    @$('.badge').tooltip()

  template: (tmp, data) ->
    Slag.template "widgets/content_#{tmp}", data
