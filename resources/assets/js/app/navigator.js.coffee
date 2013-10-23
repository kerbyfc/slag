###*
 * ***Навигатор***
 *
 * - отвечает за роутинг
 * - перерисовывает менюху и "хлебные крохи"
 * - фиксит размеры "подложки"
 *
 * @namespace Slag
###
Slag.register class Navigator extends Backbone.Router

  el: '.navbar-fixed-top .navigator'
  breadcrumbs: '#breadcrumbs > ul'

  include:
    el_prop: true
    events: true

  current: null

  ###*
   * Наполняем менюху. Создаем роуты
   * @return {Navigator}
  ###
  initialize: ->

    @setEl()
    @breadcrumbs = $ @breadcrumbs

    super

    _.defer =>

      for entity in ['layout', 'view']
        @register entity, item  for name, item of Slag["#{app.utils.capitalize entity}s"]

      @on 'route', @updateMenu

      @handleClicks()

      Backbone.history.start()

    @

  handleClicks: ->
    @$el.on 'click', (e) ->
      unless app.isUp
        e.preventDefault()
        false
    unless app.isUp
      @disable()

  disable: ->
    $('.navbar-collapse').css
      opacity: 0.2

  enable: ->
    opacity: 1

  ###*
   * зарегистрировать лейаут или вьюху
   * - зарегить роут если это вью
   * - создать элемент менюхи в баре
   * @param  {String} type  view/layout
   * @param  {Layout/View} item  класс
   * @param  {String} route = null роут
   * @param  {String} title = null тайтл для роута
   * @return {Array} [type, item]
  ###
  register: (type, item, route = null, title = null, icon = null) =>

    el = null

    data =
      title: title || item::menu_title
      icon: icon || item::menu_icon
      layout: item::layout
      selector: item.name

    if type is 'layout'

      if item::menu_title

        el = $( Slag.template 'menu/layout',  data )
        @$el.append el

    else

      # вью имеет 1 роут
      if item::route isnt undefined
        route = item::route

      # либо item::route либо route из параметров
      if route?

        app.log "HERE", route, item.name

        data.url = "#" + @removeOptionalParts route

        @route route, {name: item.name, state: @extractStaticArgs route}

        # теперь забираем роут в виде регулярки из Backbone
        data.route = _.first(Backbone.history.handlers).route

        if item::menu_title and item::hide_menu_item is undefined

          el = $( Slag.template 'menu/view', data )

          # если вью привязана к лейауту -> в менюху лейаута
          if item::layout
            @$el.find(".#{item::layout} > ul").append el

          # иначе в бар
          else
            @$el.append el

      # если вью имеет несколько роутов
      # регим их по очереди, передаваю данному методу роут и тайтл
      else if item::routes

        for route, title of item::routes
          @register 'view', item, route, title, item::menu_icons?[title]

        # presenter следит за выполнением этого метода
        # null - для фильтрации вызова, запускающего цикл регистрации роутов вьюхи
        return null

    if el?
      el.data data

    @trigger 'register', {type: type, class: item}

    {type: type, class: item}

  ###*
   * парсим роут - все "/" -> "-", удаляем "()", ":"
   * @param  {String} route
   * @return {String}
  ###
  stringifyRoute: (route) ->
    @removeOptionalParts(route).replace(/\//g, '-').replace(/[^\w|-]/g, '')

  url: ->
    Backbone.history.fragment

  ###*
   * отрезать все необязательные аргументы от роута
   * @param  {String} route
   * @return {String}
  ###
  removeOptionalParts: (route, i = route.indexOf '(/:') ->
    if i < 0
      route
    else
      route.substring(0, i)

  extractStaticArgs: (route) ->
    (route.match(/(\/)+([\w\_]+)/g) || []).join().substr(1).split('/')

  ###*
   * Обновить активную вкладку при навигации
   * @param  {String} routeName
   * @return {Navigator}
  ###
  updateMenu: (view, params) ->

    @current = null

    # снимаем выделение
    @$('.active').removeClass('active')

    # чистим крошки
    @breadcrumbs.empty()
    @appendBreadcrumb 'Slag', '#', icon: 'glass'

    # если вьюха из Slag.Views
    if viewClass = Slag.Views[view.name]

      # если просто указано какой класс подсветить
      # просто подсвечиваем
      if viewClass::highlight
        el = @$(" > .#{ viewClass::highlight}").addClass 'active'
        @appendBreadcrumb( _.extend el.data(), active: true )

      else

        layout = viewClass::layout

        name = if _.isObject layout
          layout.constructor.name
        else if _.isString layout
          layout
        else
          viewClass.name

        # если основной лейаут
        # - подсвечиваем имя вью в панеле
        if name is 'IndexLayout'
          name = viewClass.name

        if name
          viewClass = @$(" > .#{name}").addClass 'active'

        @updateBreadcrumbs viewClass

        if @current?
          @title @current.title, @current.icon

    return [view, params]

  updateBreadcrumbs: (view, options = {}) ->

    if view.hasClass 'dropdown'

      # вью имеет лейаут
      @appendBreadcrumb( _.extend view.data(), active: true )

      @updateBreadcrumbs $(li) for li in view.find('li')

    else

      if _.isObject view.data()

        if view.data('route')?.test @url()
          @current = view.data()
          view.addClass('active')

        @appendBreadcrumb _.extend view.data(), active: view.hasClass('active')

  # ###*
  #  * Добавить "хлебную крошку"
  #  * @param  {String|Object} title|options
  #  * @param  {String} url = ''
  #  * @param  {Object} options = {}
  #  * @return {Object}
  # ###
  appendBreadcrumb: ->
    @breadcrumbs.append @makeBreadcrumb(arguments...)

  makeBreadcrumb: (title, url = '', options = {}) ->
    options = title if _.isObject title
    data = _.defaults options, title: title, url: url, separator: true, active: false, icon: false, className: ''
    el = $ Slag.template( 'menu/breadcrumb', data )
    @breadcrumbs.append el
    el.data data
    el

  title: (title, icon = '', slice = null) ->
    $('.title').html( Slag.template 'menu/title', title: title, icon: icon )
    if slice?
      $(breadcrumb).remove() for breadcrumb in @breadcrumbs.children().slice(slice)
    last = @breadcrumbs.find('li:last-child')
    unless last.data('separator')
      last.remove()
    @appendBreadcrumb title: title, separator: false, active: true, icon: icon, className: 'title'
