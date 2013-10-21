Slag.register class Presenter extends Backbone.View

  el: '#layout-holders'

  include:
    el_prop: true
    events: true

  ###*
   * Классы представлений-лейаутов
   * @type {Object}
  ###
  Layouts: {}
  layouts: {}

  Views: {}
  views: {}

  current:
    layout: null
    view: null

  # audit: true

  ###*
   * Подписываемся на события навигатора о регистрации лейаутов и вьюх
   * и встраиваем в страницу элементы-холдеры для них
   * @return {Presenter}
  ###
  constructor: ->
    @setEl()
    Slag.on 'Navigator.register', @register
    Slag.on 'Navigator.updateMenu', (params) =>
      @present params...
    @fixContainerHeight()
    this

  register: (item) =>
    if item?
      @[app.utils.capitalize(item.type) + 's'][item.class.name] = item.class

  present: (view, args = []) =>
    key = view.name + '-' + _.union(view.state).join('-')
    argv = _.union view.state, args
    app.log view, view.name, key, argv
    viewInstance = unless @views[key]
      @initView view.name, key, _.clone(argv)
    else
      @views[key]
    layout = viewInstance.layout
    if not(@current.layout?) or @current.layout.cid isnt layout.cid
      if @current.layout?
        @current.layout.close()
        @current.layout.$el.hide()
      if layout?
        @current.layout = layout
        layout.open _.clone(argv)...
    if layout?
      layout.$el.show()
    if @current.view? and @current.view.cid isnt view.cid
      @current.view.close()
      @current.view.visible = false
      @current.view.$el.hide()
    if viewInstance
      @current.view = viewInstance
      @current.view.visible = true
      viewInstance.$el.show()
      viewInstance.open argv...

  embedLayout: (layout) ->
    @$el.append "<div class='layout-holder span12 #{layout.name}-layout'></div>"

  embedView: (layout, key) ->
    @$(".#{layout}-layout .view-holders").append "<div class='view-holder #{key}-view'></div>"

  initView: (viewName, key, args) =>
    args = _.clone args
    view = @Views[viewName]
    unless _.isFunction view
      throw new Error "View #{viewName} is not defined"
    layout = view::layout
    # нет своего лейаута - используем IndexLayout
    unless view::layout
      view::layout = layout = 'IndexLayout'
    if _.isString layout
      layout = @Layouts[layout]
      if layout is undefined
        throw new Error "Layout #{layout} is not defined"
    if _.isFunction layout
      @embedLayout layout
      layout = @layouts[layout.name] = view::layout = new layout
    @embedView layout.constructor.name, key
    args.unshift ".#{key}-view"
    view = @views[key] = new view args...
    view

  fixContainerHeight: ->
    $(window.document).on 'resize', (e) ->
      $('#main').css( height: $(window).height() )
    $(window.document).triggerHandler 'resize'
