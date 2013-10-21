###*
 * Лейаут страницы плейлистов
 * Когда показываем списки плейлистов - организует отображение истории поиска плейлистов
 * для каждой категории (активные/все/неактивные/проигрываемые)
 * @namespace Slag.Layouts
###
Slag.register class PlaylistsLayout extends Slag.Layout

  menu_title: 'Плейлисты'
  menu_icon: 'list'

  events:
    'click .do-search': 'pushTag'
    'mousedown .tm-tag-remove': 'removeTag'

  ###*
   * Рендерим шиблон
   * создаем ссылку на эл. ввода поискового запроса
   * инитим плагин tagsManager (jquery)
   * подписываемся на события обновления виджетов коллекций (те что во вьюхах лейаута)
   * @return {PlaylistsLayout}
  ###
  initialize: ->

    @render()

    @contents = new Slag.Widgets.ContentTypesWidget @$ '.content-types-holder'

    @search = @$('.playlists-search')

    @search.tagsManager
      validator: @validateTag
      backspace: false
      tagsContainer: '.search-history'

    Slag.on 'PlaylistsCollectionWidget.render', @updateTag

    # включим автоматическую конвертация объектов в json для куков
    $.cookie.json = true

    if tags = $.cookie 'pls-tags'
      @search.tagsManager('pushTag', @formTagBody id, title) for id, title of tags

    this

  ###*
   * Выяснить, нужно ли добавлять тег
   * @param  {String} query поисковый запрос
   * @return {Boolean}      флаг валидности
  ###
  validateTag: (query) =>

    return false unless query

    # теги у нас содержат html, ссылки с href
    # если найден href - значит это тег - добавляем
    if query.match(/href/)?
      true

    # если не найден, значет мы передали просто строку
    # в этом случае ничего не добавляем
    # добавлять будет вьюха, когда она откроется после перехода
    else
      # собственно переходим и возвращае false чтобы не добавлять сейчас тег
      app.navigator.navigate @url(query), true
      false

  ###*
   * Сформировать урл для навигации по тегам
   * @param  {String} idOrFilter (started / started-blah)
   * @return {String} урл
  ###
  url: (idOrFilter) ->
    if idOrFilter.indexOf('-') < 0
      "#{app.navigator.url().split('/').slice(0, 2).concat(decodeURIComponent(idOrFilter)).join('/')}"
    else
      "playlists/#{(decodeURIComponent(idOrFilter).replace('-', '/'))}"

  ###*
   * Добавить тег поиска
   * @param  {String} filter парамет поиска
   * @param  {String} id = null идентификатор таблицы результатов
   * @return {PlaylistsLayout}
  ###
  pushTag: (filter, id = null) =>

    return unless filter

    # если id не передан - то filter это событие клика на кнопку
    unless id?

      if val = @search.val()
        app.navigator.navigate @url(val), true

    # если передан - это явный вызов
    else

      app.log id, filter

      # если тег не был взят из куков
      if @rememberTag id, filter
        # в этом случае формируем и добавляем тег
        @search.tagsManager 'pushTag', @formTagBody id, filter

    this

  ###*
   * получить dom объект тега по его id
   * @param  {String} id идентификатор
   * @return {Object} jquery объект
  ###
  getTag: (id) =>
    @$(".scrumb-id-#{id}").closest('.tm-tag')

  ###*
   * Сформировать html тега
   * @param  {String} id     идентификтор
   * @param  {String} filter поисковый запрос
   * @return {String}        html
  ###
  formTagBody: (id, filter) ->
    Slag.template 'search/tag'
      filter: filter
      id: id
      url: @url(id)

  ###*
   * Сохранить тег в куках
   * @param  {String} id     идентификатор
   * @param  {String} filter поисковый запрос
   * @return {String} идентификатор
  ###
  rememberTag: (id, filter) ->
    tags = $.cookie('pls-tags') || {}
    return false if _.has tags, id
    tags[id] = filter
    app.log tags
    $.cookie 'pls-tags', tags
    id

  ###*
   * Удалить тег из куков
   * @param  {String} id идентификатор тега
   * @return {String} идентификатор тега
  ###
  forgеtTag: (id) ->
    $.cookie 'pls-tags', (_.omit ($.cookie('pls-tags') || {}), id)
    id

  ###*
   * Обновить тег поиска, раскрасить и проставить число найденных прейлистов
   * @param  {Object} models модели виджет-коллекции
   * @param  {Slag} widget виджет-коллекция плейлистов
   * @return {Object} jQuery объект
  ###
  updateTag: (models, widget) =>
    if _.isArray models
      @getTag(widget.id).find('.m_count').text models.length

  ###*
   * Снять выделение с тегов
   * @return {Object} jquery объект
  ###
  unselectTags: =>
    @$('.tm-tag-success').removeClass('tm-tag-success tm-tag-success').addClass('tm-tag-info')

  ###*
   * Выделить тег по id
   * @param  {String} id идентификатор
   * @return {Object} jquery объект
  ###
  selectTag: (id) =>
    @getTag(id).removeClass('tm-tag-info').addClass('tm-tag-success')

  ###*
   * Удалить тег
   * @param  {Event} e событие клика
   * @return {String} id удаленного тега
  ###
  removeTag: (e) =>
    @forgеtTag $(e.currentTarget).prev().find('a').data('id')


