###*
 * @namespace Slag.Views
###
Slag.register class PlaylistView extends Slag.View

  layout: 'PlaylistLayout'
  highlight: 'PlaylistsLayout'

  routes:
    'playlists/edit/:id': 'Редактирование'
    'playlists/new': 'Создание'

  menu_icons:
    'Все': 'globe'

  loadmask_css:
    'min-height': 200

  cur_id: null

  audit: true

  include:
    events: true
    el_prop: true
    loader: true

  bricks: {}

  open: (action, id) ->

    unless action is 'new'
      @loading true
      app.storage.get 'playlist', id, done: @render, error: @notFound

    else
      @render new Slag.Models.PlaylistModel

  render: (@model) =>

    @loading false
    @layout.loading false

    unless @model
      return @notFound()

    # если перешли к другому плейлисту
    # нужно перерисовать лейаут
    unless @cur_id is @model.id
      @cur_id = @model.id

    @title @model.title()

    super

    @holder = @$ '.contents-holder'

    @embedContent content_model for content_model in @model.related 'content'

  embedContent: (content_model) ->

    type = "#{content_model.get('content_type')}Brick"

    unless widget = Slag.Bricks[type]
      throw new Error "Brick #{type} was not found"

    bid = _.uniqueId 'brick'

    @holder.append Slag.template 'views/brick', content_model, bid: bid

    @bricks[content_model.id] = new Slag.Bricks[type] "##{bid}", content_model

  notFound: =>
    @$el.html 'NOT FOUND'



