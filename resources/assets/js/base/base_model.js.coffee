###*
 * Переписанные методы:
 *   у модели есть 2 метода наполнения данными:
 *     - change - вызывает Backbone.Model.set, который в свое время тригерит change событие
 *     - set - вызывает Backbone.Model.set всегда с параметром silent:true - событие не тригерится
 *   метод save только для сохранения, не принимает атрибутов, только колбэки
 *
 * Работа с данными:
 *
 *   можно сетить вложенные атрибуты:
 *     - change 'attrs.name': 'Kerby'
 *     - set 'attrs.name': 'Kerby'
 *   также можно и доставать вложенные атрибуты: get 'attrs.name'
 *   метод map формирует массив литеральных путей до каждого элемента ['attrs', 'attrs.name', 'attrs.age']
 *   метод toHash возвращает хеш путь => значение
 *
 *
 * Работа с апи:
 *   2 коллбэка successCallback, errorCallback отрабатывают всегда, дабы информировать о результатах работы с апи
 *   добавлен коллбэк onInvalid, обрабатывающий ситуацию непрохождения данных модели через валидатор
 *   разные коды ошибок, обрабатываются отдельно
 *
 *  # TODO invalid callback
 *
 * @namespace Slag
###
Slag.register class Model extends Backbone.Model

  include:
    events: true
    has_entity: true
    url_params: true

  options:
    base_url: null

  # вложенные сущности
  # обычно <сущьность>[s]: <сучность>_ids (можно забить на 's')
  # panel[s]: panel_ids  - где panel[s] - имя сущности
  # для работы с app.storage
  mapping: {}

  constructor: (attrs = {}, options = {}) ->

    @root ?= @getEntityName()

    # не присваевыем url модели если в нем есть GET-параметры
    if _.has options, 'url'
      delete options.url

    # модель всегда создается втихую, чтобы не тригерить событие change
    # change тригерим только при вызове change
    super attrs, ( _.extend {}, options, silent: true )

    @options.base_url = app.api + @root + 's'

    @on 'error', @onError
    @on 'invalid', @onInvalid

  parse: (res, options) =>
    if res[@root]?
      res = res[@root]
    res

  url: (params, url = @options.base_url) =>
    if @id
      url += "/#{@id}"
    if _(params).size()
      url += "?" + @params params
    url

  save: (options = null, opts = null) ->

    attrs = null

    # по умолчанию первым парметром передаются атрибуты
    # если 2 параметра переданы - значит это стучится Backbone
    # обманываем
    if opts?
      attrs = options
      options = opts

    options ?= {}

    # на всякий случай
    unless options.url
      options.url = @url options.params

    # оборачиваем колбэки
    _.extend options, @callbacks(options)

    super attrs, options

  get: (path, obj = null) ->

    # при использовании путей, может придти к примеру ".attr"
    path = path.substring 1 if _.isString path and path[0] is '.'

    # в массив
    path = path.split "." if _.isString path

    unless _.isString(path) or _.isArray(path)
      return undefined

    # если корневой эл-ент - берем стандартным гетом, если нет - тащим свойство объекта
    obj = unless obj? then Backbone.Model.prototype.get.call this, path.shift() else obj[path.shift()]

    # если путь пуст - дошли до целевого свойства, нет идем глубже
    if path.length then @get path, obj else obj

  setByPath: (path, val, options) ->

    if path.length

      # в массив
      path = path.split "." if _.isString path

      # объекты всегда возвращаются по ссылке
      target = @get path.slice(0, -1)

      if _.isUndefined(target) and ( parent = _.clone(path).slice(0, -1) ) and parent.length

        last = _.last(parent)
        num = parseInt path.slice(-1)

        holder = if _.isNaN(num) or num < 0 then {} else []

        if parent.length is 1

          root = @get(last)

          if root is undefined
            Backbone.Model.prototype.set.call this, last, holder, silent: true

          target = @get last

        else

          @setByPath parent, holder, options
          target = @get parent

      if _.isArray(target) or _.isObject(target)

        target[path.slice(-1)] = val

        @trigger "change:#{path.join('.')}", this, val, options

      else
        throw new Error "Cant set property #{path} of #{@constructor.name}"

    this

  path: (parent, child) ->
    if parent.length then "#{parent}.#{child}" else child

  map: (obj = @toJSON(), max_depth = 3, depth = 1, parent = '', bk = []) ->

    # проверим аргумент
    if _.isNaN parseInt(max_depth)
      max_depth = 3

    # если строка - берем атрибут модели
    if _.isString obj
      obj = @get obj

    for key, val of obj
      key = @path parent, key
      bk = if (_.isObject(val) or _.isArray(val)) and depth < max_depth
        _.union bk, @map(val, max_depth, ++depth, key)
      else bk
      bk.push key

    bk

  toHASH: (obj, depth = 3, hash = {}) ->
    hash[key] = @get key for key in @map obj, depth
    hash

  set: (key, val = {}, options = {}) ->

    # если передали массив атрибутов,
    # очевидно что следующий необязательный аргумент - опции
    options = val if _.isObject key

    if _.isObject options
      # всегда втихую
      _.extend options, silent: true

    # основной метод
    @change key, val, options

  change: (key, val = {}, options = {}, attrs = {}) ->

    if _.isObject key
      options = val
      attrs = key

    else
      attrs[key] = val

    roots = []

    for key, val of attrs when (dot = _.indexOf key, '.') and dot >= 0

      # удаляем путь, Backbone не умеет их сетить
      delete attrs[key]

      # сетим по пути
      @setByPath key, val, options
      # меням ключ на корень пути
      key = key.substring 0, dot

      roots.push key

      attrs[key] = @get key

    unless options.silent
      for root in _.uniq roots
        @trigger "change:#{root}", this, @get(root), options

    # передаем всегда в виде массива, даже если атрибут 1
    Backbone.Model.prototype.set.call this, attrs, options

  unset: (attr, options) ->
    Backbone.Model.prototype.set.call this, attr, undefined, ( _.extend {}, options, unset: true )

  callbacks: (options, callbacks = {}) ->
    @["#{type}Callback"]( (options[type] || null), options ) for type in ['success', 'error']

  related: (entities, done, fail) =>

    # обещания загрузки по каждой сущьности
    promises = []

    # по умолчанию работаем с массиво сущьностей
    unless _.isArray entities
      entities = [entities]

    # можно запросить подгрузку нескольких связанных сущьностей
    for entity in entities

      # проверяем присутствие явно-указанной связи
      unless prop = @mapping[entity] || @mapping[app.utils.plural entity]
        prop = app.utils.singular(entity) + "_ids"

      # наполняем массив обещаний
      promises.push( app.storage.get entity, @get(prop) )

    # ждем подгрузки всех желаемых связанных сущьностей
    $.when(promises...).then (models) =>
      done? arguments...
    , fail

    # flatten нужен для случаев когда мы уверены
    # что related модели подгружены и мы получим
    # не dfd-объекты, а сразу модели
    _.flatten promises

  successCallback: (callback, options) ->
    J (model, attrs, req) ->
      app.success "Данные #{model.constructor.name} сохранены"
      # ждем получения связанных моделей если указано каких
      # в опции "include"
      if options.include
        @related include, => callback?(model, attrs, req)
      else
        callback?(model, attrs, req)

  errorCallback: (callback, options) ->
    J (model, attrs, req) ->
      app.info "Данные #{model.constructor.name} НЕ сохранены"
      callback?(model, attrs, req)

  _onApiError: (res) =>
    app.error Error "Ошибка сервера: #{res.responseText.slice(0, 120)}... Обратитесь к разработчикам"

  onError: (model, res) =>
    unless @["on#{res.status}"]?
      @_onApiError(res)
    @["on#{res.status}"]?(res)

  on404: (res) =>
    if res.responseText is "{}"
      return app.info "Данные #{@constructor.name} не найдены по идентификатору"

  on422: (res) =>
    console.log "HERE"
    if _.isString res.responseText
      res = JSON.parse res.responseText
    errors = res.errors || res
    for i, err of errors
      app.error "Модель #{@constructor.name}: #{i} #{err}"




