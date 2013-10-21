###*
 * @namespace Slag.Models
###
Slag.register class PlaylistModel extends Slag.Model

  mappings: ->
    content_ids: 'contents'

  contentsCount: ->
    (@get('content_ids') || []).length

  title: ->
    unless @id 
      return 'Новый плейлист'
    @get('title') || "Плейлист №#{@id}"

  duration: -> 
    _.reduce @related('content'), (memo, m) ->
      memo += m.get('duration') || 0
    , 0

  humanizeDuration: -> 
    Slag.Content::humanizeDuration.call this, @duration()

  getContentsPreview: ->
    badgets = _.map @related('content'), (m) ->
      data = _.pick m, 'badge', 'icon'
      data.title = m.humanizeDuration() + " | " + (_.escape(m.get 'attrs.brick_description') || m.title)
      Slag.template 'widgets/content_badge', data
    badgets.join('')

