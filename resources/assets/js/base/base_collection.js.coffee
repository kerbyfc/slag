###*
 * @namespace Slag
###
Slag.register class Collection extends Backbone.Collection

  # audit: true

  include:
    has_entity: true
    events: true
    url_params: true

  defaults:
    out_of_stock: true
    condition: null
    common: false
    url: false
    all: false
    include: false
    root: ''
    meta:
      current_page: 1
      per_page: 25
      total_page: 1

  overrides: {}

  constructor: (options = {}) ->

    super()

    @pages = []

    unless _.isString options.url
      options.url = app.api + @getEntityName()

    @options = _.defaults options, _.extend({}, @defaults, @overrides)

    # console.log  "OPTS", @options

    if @isPartial()
      @models = @options.common.models
      @_byId = @options.common._byId

  isPartial: ->
    @options.common isnt false

  setModel: (model = @options.model) =>

    model = model.replace(/s$/, 'Model')

    unless _.has Slag.Models, model
      throw new Error "Implied that the #{@getEntityName()}Collection will be used with #{model}, which is not exists"

    @model = Slag.Models[model]

    this

  parse: (res, options) =>

    options = _.clone options

    @options.meta = res.meta || false

    unless @options.meta
      @isFгllyLoaded = true

    if res[@options.root]
      res = res[@options.root]

    res

  url: (params = {}, options = {}) =>
    affixes = []

    # console.log  "URL", arguments
    # console.log  @options

    options = _.extend {}, _.clone(@options), options

    url = options.url

    if _(params).size()
      affixes.push @params(params)

    if options.all
      affixes.push 'all=true'

    if options.out_of_stock and not affixes.join('').match(/ids\[\]\=/)?
      if ids = (_.map @pluck('id'), (id) => "not_ids[]=#{id}").join('&')
        affixes.push ids

    if affixes.length
      url += (if url.match(/\?/)? then '&' else '?') + affixes.join '&'

    url

  fetch: (params = {}, options = {}) ->

    options = _.clone options

    # console.log  "FETCH", arguments

    # если параметры переданы в опциях - вытаскиваем
    # но перезаписываем явно переданными параметрами
    if _.has options, 'params'
      params = _.extend {}, options.params, params

    # используем опции по умолчанию
    # если таковые не были переданы явно
    options = _.defaults options,
      remove: false
      include: @options.include
      silent: false
      all: false
      out_of_stock: @options.out_of_stock

    # урл получаем на основе сформированных опций
    options.url = @url(params, options)

    # есть установка подгружать
    # связанные модели сразу
    if options.include
      success = options.success
      options.success = (_this, models) =>
        @related options.include, @parse(models), done: success, fail: options.error

    super options

  related: (entity, from, options = {}) ->

    unless _.isArray from

      if _.isOptions ids
        options = ids

      from = @getModels()

    # получаем имя свойства, хранящего айдишники моделей
    prop = app.utils.singular(entity) + '_ids'

    # и собираем эти айдишники среди всех моделей
    ids =  _.flatten(_.map from, (m) -> m[prop] || m.get?(prop))

    app.storage.get entity, _.uniq(ids), options

  isFullyLoaded: ->
    if @options.meta
      return @options.meta.total_page <= @pages.length
    false

  getModels: (options = {}) ->
    models = if @isPartial() and @options.condition?
      @filter @options.condition
    else
      @models
    if options._
      _(models)
    else
      models

  isOwn: (model, id = model.id || model) ->

    unless @isPartial()
      true

    else if @own? and _.has(@own, id)
      true

    else if @options.condition? and @options.condition(model)
      true

    else
      false

  more: (options = {}, params = {}) =>

    options = _.clone options

    # если параметры переданы в опциях - вытаскиваем
    # но перезаписываем явно переданными параметрами
    if _.has options, 'params'
      params = _.extend {}, options.params, params

    if @options.meta and @pages.length < @options.meta.total_page

      @options.meta.current_page = if @options.out_of_stock
        1

      else if Math.max(@pages) < @options.meta.current_page
        Math.max(@pages) + 1

      else if Math.min(@pages) > 1
        Math.min(@pages)-1

      else
        @options.meta.current_page + 1

      @pages = _.union @pages, @options.meta.current_page

      params = _.extend
        page: @options.meta.current_page
      , params

      @fetch params, options

    else

      false

  create: (model, options = {}) ->

    options = _.clone options

    # всегда ждем ответ от сервера
    options.wait = true
    options.silent = false

    unless (model = this._prepareModel model, options)
      return false

    unless options.wait
      this.add model, options

    collection = this
    success = options.success

    options.success = (resp) ->

      if options.wait
        collection.add model, options

      if success
        success model, resp, options

    # возвращаем не модель, а обещание
    # а результат model.save => model.sync => dfd
    model.save(null, options).promise()

