###*
 * @namespace Slag
 * @uses  Slag.Collection
 * @uses  Slag.Listener
###
Slag.register class Storage

  listeners: []

  listeners_count: 3

  # хранилище коллекций
  collections: {}

  # audit: true

  # методы получения данных их коллекции
  obtaining_methods:
    number:   'getById'
    array:    'getByIds'
    object:   'getWhere'
    function: 'getFilteredBy'

  callbacks:
    done: null
    fail: null

  ###*
   * Общий метод получения данных коллекций и моделей
   * используйте ключи done & fail в качестве коллбеков!
   * @param  {String} name    имя коллекции
   * @param  {String|Number|Object|Function|Array} [param=null] параметр
   * @param  {Object} [options={}] опции
  ###
  get: (name, param = null, options = {}) ->

    # done & fail - это коллбэки, которые выполняются в обработчиках storage
    # потому как у нас должна оставаться возможность передать
    # в опциях коллбеки success и error
    callbacks = _.pick options, 'done', 'fail'

    # если передали функцию вместо опций
    # то по умолчанию это done
    if _.isFunction options
      callbacks = done: options

    # пустой объект опций по умолчанию
    unless _.isObject options
      options = {}

    # недостающие коллбеки -> null
    callbacks = _.defaults callbacks, @callbacks

    params = [options, callbacks.done, callbacks.fail]

    # целевая коллекция
    if collection = @getCollection name, options

      # если параметры не переданы - вернем коллекцию
      # app.source.get('playlists').get ...
      unless param?
        return collection

      # чтобы правильно определить метод
      # нужно учесть также что это может быть число в виде строки 'id'
      if _.isString(param) and param.match(/^\d+$/)
        param = parseInt param

      # если все таки строка
      if _.isString param

        # к примеру app.storage.get('playlists', 'more', opts)
        obtaining_method = param

      else
        # узнаем тип параметра по имени конструктора класса объекта
        type = param.constructor.name.toLowerCase()

        # и получаем метод, который вернет нам нужные данные
        obtaining_method = @obtaining_methods[type]

        params.unshift param

      # неверный параметр
      unless !!obtaining_method
        throw new Error "Wrong second parameter type. Only #{_.map(_.keys(@obtaining_methods), (i) -> app.utils.capitalize i).join(', ')} are supported. #{app.utils.capitalize type} given"

      unless @[obtaining_method]
        throw new Error "Storage hasn't `#{obtaining_method}` obtaining method. Check arguments."

      params.unshift collection

      # возвращаем результат вызова
      @[obtaining_method] params...


  getByIds: (collection, ids, options, done = null, fail = null) ->

    available = collection.filter (m) -> m.id in ids
    ids = _.difference ids, (_.pluck available, 'id')

    if ids.length

      params = ['all=true'].concat _.map(ids, (id) -> "ids[]=#{id}")

      options = _.extend {}, options,
        success: ->
          loaded = collection.filter (m) -> m.id in ids
          done? ( _.union available, loaded )
        error: fail

      dfd = collection.fetch params, options

    else
      done? available
      available

  getById: (collection, id, options, done = null, fail = null) ->
    obj = collection.get id

    if obj isnt undefined
      done? collection.get(id)
      collection.get(id)

    else
      obj = collection.fetch "ids[]=#{id}",
        out_of_stock: false
        success: ->
          done? collection.get(id)
        error: fail
      obj

  # TODO посмотри, все ли верно!
  more: (collection, options, done = null, fail = null) ->

    if _.isString(collection)
      collection = @getCollection collection

    options = _.extend {}, options,
      success: ->
        done? collection.getModels() # TODO - не все, только новые!
      error: fail

    # app.log  "STORAGE MORE", options

    req = collection.more options

  getWhere: (collection, condition = {}) ->
    collection.where condition

  getFilteredBy: (collection, filter) ->
    collection.filter filter

  find: (collection, filter) ->
    @getCollection(collection).find filter

  getCollection: (selector, options = {}) ->

    options = _.clone options

    # ищем вхождение подстроки,
    # определяющей "частичность" коллекции
    partial = selector.indexOf('(')

    # взять Playlists если передано
    #  active_playlists
    #   или
    #  playlists

    entity = if partial > 0
      selector.slice( 0, partial )
    else
      partial = -2 # for slice( -2 + 1, -1 )
      selector

    entity = app.utils.capitalize app.utils.plural(entity)

    # app.log ("PARTIAL", partial)

    key = if partial > 0
      "partial:" + selector
    else
      entity

    # app.log ("KEY", key)

    collection = unless @collections[key]

      unless _.has Slag.Collections, "#{entity}Collection"
        throw new Error "Collection '#{entity}Collection' was not found"

      _.extend options,
        model: entity
        root: entity.toLowerCase()

      if partial > 0
        options.common = @getCollection entity

      options.url ?= app.api + options.root + selector.slice(++partial, -1)

      # app.log (options.url)

      @collections[key] = new Slag.Collections["#{entity}Collection"](options).setModel()

    else
      @collections[key]

    # app.log  "collection", collection

    collection

  factory: (entity, args...) ->

    entity = app.utils.capitalize entity
    plural = app.utils.plural entity
    singular = app.utils.singular entity

    unless _.has Slag.Collections, "#{plural}Collection"
      collection = Slag.factory "Collection", fname: plural + 'Collection'

    unless _.has Slag.Models, "#{singular}Model"
      model = Slag.factory "Model", fname: singular + 'Model'

    args.unshift plural

    unless args.length > 1
      @getCollection args...
    else
      @get args...


 Slag.Collections ?= {}



