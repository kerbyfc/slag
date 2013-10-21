###*
 * @namespace Slag.Widgets
###
Slag.register class CollectionWidget extends Slag.Widget

  include:
    events: true
    el_prop: true
    loader: true

  defaults:
    collection: false
    entity: false
    auto_render: true
    scroll: true
    empty_text: "Объектов не найдено"
    route: ''

  handeling: false

  # audit: true

  initialize: (options = {}) ->

    @options = _.defaults options, @defaults

    unless options.collection
      throw new Error "CollectionWidget must give collection option"

    # можно передать коллекцию строкой
    if _.isString options.collection
      options.collection = app.storage.get options.collection

    # не будем держать в @options - "наложим" прямо во вьюху
    _.extend @, options

    @entity = @collection.getEntityName()

    @ids = []

    # по умолчанию виджеты коллекций располагаются в %ul.{entity}-collection-widget
    @setEl( options.el || ".#{@entity}-collection-widget" )

    @$el.after "<div class='loadmask'></div><div class='noop'>#{@empty_text}</div>"
    @loadmask = @$el.next()
    @noop = @loadmask.next()

    if @collection.getModels().length < @options.min
      @more()
    else
      @render()

    if @options.scroll
      $(window).on 'scroll', @handleScroll

    Slag.on "#{@collection.model.name}.change", @updateRow
    Slag.on "#{@collection.model.name}.removeRow", @removeRow

  initChangesHandeling: =>
    @collection.on "add", @prepareToUpdate
    @collection.on "sync", @prepareToUpdate
    @handeling = true

  prepareToUpdate: =>
    _.throttle(@update, 500) unless @loading @loadmask

  get: (model) ->
    @$ ".#{@entity}-#{model.id || model}"

  render: (force = false) =>

    if !@collection.getModels().length and !force
      unless @loading @loadmask
        @more()
      return false

    @update()
    
  update: (models = @collection.getModels(_:true)) => 

    models = @collection.getModels(_:true)
    @removeRow id:id for id in _.difference @ids, models.pluck('id')

    models = models.toArray()

    @loading @loadmask, false

    if models.length
      @noop.hide()
      @add model for model in @collection.getModels()
    else
      @noop.fadeIn 200
    models

  more: =>

    @loading @loadmask, true

    console.log "COLLECTION", @collection
    dfd = app.storage.more @collection, {}, =>

      unless @handeling
        @initChangesHandeling()

      @render(true)

    unless dfd
      @loading @loadmask, false

  template: (model) ->
    el = Slag.template "collections/#{@entity}", model
    $(el).addClass("#{@entity}-#{model.id} #{@entity}-collection-item")

  embedRow: (model, method = 'append') ->
    @template(model).data('model', model)["#{method}To"](@el)
    @highlight model

  updateRow: (model) =>
    if (el = @get(model)) and el.length
      @get(model).replaceWith @template(model)
      @highlight model

  removeRow: (model) =>
    if (el = @get(model)) and el.length
      @models = _.without @models, model
      @invoke model, 'hide', 'highlight', color: "#FFDBDB", complete: =>
        @invoke model, 'removeRow'

  appendRow: (model) ->
    @embedRow model

  highlight: (model) ->
    @get(model).hide().show 'highlight', color: "#DBEDFF"

  prepend: (model) ->
    @embedRow model, 'prepend'

  add: (model) =>
    if _.indexOf(@ids, model.id) < 0
      @ids.push model.id
      @appendRow model

  hide: ->
    @$el.hide()
    @noop.hide()
    @loadmask.hide()

  show: ->
    @$el.show()
    if @loading()
      @loadmask.show()
    else
      @noop.show() if @ids.length is 0 and @loading(@loadmask) is false

  invoke: (model, action, options...) ->
    @get(model)[action](options...)

  handleScroll: =>
    return if not @$el.is(":visible") or @loading(@loadmask) or @collection.isFullyLoaded()
    w = $(window)
    if @$el.height() + @$el.offset().top - w.scrollTop() - w.height() < w.height()/3
      @more()













