###*
 * Представление списка плейлистов
 * Оперирует более мелкими представлениями коллекций PlaylistsCollectionWidget,
 * скрывает/проявляет их в зависимости от переданных параметров в #open
 * @namespace Slag.Views
###
Slag.register class PlaylistsView extends Slag.View

  layout: 'PlaylistsLayout'

  # audit: true

  # роуты
  # создаются отдельные инстансы для каждого роута
  # (необязательные параметры не учитываются)
  routes:
    'playlists/started(/:filter)': 'Проигрываемые'
    'playlists/active(/:filter)': 'Активные'
    'playlists/not_active(/:filter)': 'Неактивные'
    'playlists/all(/:filter)': 'Все'

  # иконки менюхи и крошек
  menu_icons:
    'Все': 'globe',
    'Проигрываемые': 'play-circle',
    'Активные': 'ok-circle',
    'Неактивные': 'remove-circle'

  ###*
   * Храним объекты PlaylistsCollectionWidget здесь
   * @type {Object}
  ###
  widgets: {}

  ###*
   * Соглашение, используемое при выборке АКТИВНЫХ моделей
   * частичной (partial) коллекцией плейлистов
   * @param  {PlaylistModel} model модель плейлиста
   * @return {Boolean}
  ###
  active: (model) ->
    model.get('active') is true

  ###*
   * Соглашение, используемое при выборке НЕАКТИВНЫХ моделей
   * частичной (partial) коллекцией плейлистов
   * @param  {PlaylistModel} model модель плейлиста
   * @return {Boolean}
  ###
  not_active: (model) ->
    !model.get('active')

  ###*
   * Соглашение, используемое при выборке ПРОИГРЫВАЕМЫХ моделей
   * частичной (partial) коллекцией плейлистов
   * @param  {PlaylistModel} model модель плейлиста
   * @return {Boolean}
  ###
  started: (model) ->
    !!(model.get 'started_at')

  ###*
   * вернутся все модели коллекции
   * @type {Boolean}
  ###
  all: -> true

  ###*
   * Проверить, попадает ли плейлист под поисковый запрос
   * @param  {PlaylistModel} model Плейлист
   * @param  {String} filter Поисковый запрос
   * @return {Boolean} 
  ###
  eq: (model, filter) =>
    model.id is parseInt(filter) or "#{model.get('title')}".toLowerCase().indexOf(filter.toLowerCase()) >= 0

  ###*
   * рендерим
   * Создаем через факторию новый класс
   * виджета-коллекции PlaylistsCollectionWidget
   * @param  {String} el     селектор DOM-елемента
   * @param  {String} type   тип (активные/неакт...)
   * @param  {String} filter = '' Параметр поиска
   * @return {PlaylistsView}
  ###
  initialize: (el, type, filter = '') ->
    super

    @render
      type: type

    @current = null

    unless Slag.Widgets.PlaylistsCollectionWidget

      # создать новый класс
      Slag.factory 'CollectionWidget',
        fname: 'PlaylistsCollectionWidget'
        protected_methods: ['handleScroll']

    this

  ###*
   * Формируем ключ тип-запрос
   * для этого ключа создаем виджет и выводим его
   * @param  {String} type   тип
   * @param  {String} filter = '' Параметр поиска
   * @return {PlaylistsView}
  ###
  open: (type, filter = '') =>

    # ключ
    id = "#{type}-#{filter}"

    # ничего не делаем если виджет
    # по текущему ключу уже отображен
    return if @current is id

    # снимаем выделение с тегов
    @layout.unselectTags()

    params = []

    unless type is 'all'
      params.push "only_#{type}=true"

    if filter

      # если есть поисковый запрос
      # добавляем в историю поисковых запросов
      unless @widgets[id]
        @layout.pushTag filter, id

      app.navigator.title filter, app.navigator.current.icon

      params.push "q=#{filter}"

    # параметры для partial-коллекции
    params = params.join("&")

    app.log params

    collection = if params

      condition = unless filter
        @[type]
      else
        (model) =>
          @[type](model) and @eq(model, filter)

      # о partial-коллекциях читать в base_collection.coffee
      app.storage.getCollection "playlists(?#{params})", condition: condition
    else
      # параметров нет - (id = all-[all])
      # используем цельную коллекцию
      app.storage.get 'playlists'

    app.log "RESULT", collection

    # прячем если есть что
    @widgets[@current].hide() if @current?

    # пробуем тащить из кеша
    unless @widgets[id]

      @$el.append Slag.template 'views/playlists', id: id

      # создаем новый виджет и кладем в кеш
      @widgets[id] = new Slag.Widgets.PlaylistsCollectionWidget
        el: ".#{id}-playlists-collection-widget"
        collection: collection
        id: id

      @widgets[id].on 'render', =>
        @widgets[id].$el.find('.badge').tooltip html: true

    # Показываем
    @widgets[id].show()
    @widgets[id].render()

    @current = id

    # выделяем поисковый тег
    @layout.selectTag @current

    this






