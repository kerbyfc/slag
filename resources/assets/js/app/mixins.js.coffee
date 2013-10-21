###*
 * Миксины
 * @namespace Slag
###
Slag.register class Mixins

  ###*
   * Миксин событий
   * Добавляет/изменяет метод trigger, чтобы
   * событие не ускользнуло от Bordeuax.
   * @see Slag.callback
   * @method events
   * @param  {Class} module Класс
   * @return {Object} Миксин
   * @static
  ###
  @events = (module) ->
    trigger: J "#{module.name}.trigger", Backbone.Events.trigger, Slag.callback

  ###*
   * Миксин для классов, наследуемых от Backbone.View
   * @method el_prop
   * @param  {Class} module Класс
   * @return {Object} Миксин
   * @static
  ###
  @el_prop = (module) ->

    setEl: (@el = @el) ->
      if @el.is?
        @$el = @el
        @el = @$el.selector
      else
        @$el = $(@el)
      @$ = (selector) =>
        $(selector, @$el)

  ###*
   * Миксин для классов, имеющих в своем названии название сущности
   *
   * @example
   *    class UserModel
   *    &nbsp;&nbsp;include:
   *    &nbsp;&nbsp;&nbsp;&nbsp;el_prop
   *
   * @method has_entity
   * @param  {Class} module Класс
   * @return {Object} Миксин
   * @static
  ###
  @has_entity = (module) ->

    getEntityName: (from = @constructor.name) ->
      from.replace(Slag.entities, '').toLowerCase()

  ###*
   * [url_params description]
   * @method url_params
   * @param  {Class} module Класс
   * @return {Object} Миксин
   * @static
  ###
  @url_params = (module) ->

    params: (params = {}, pairs = []) ->

      if _.isArray params
        params.join('&')

      else if _.isObject params
        for opt, val of params
          pairs.push if val? then "#{opt}=#{val}" else opt
        pairs.join('&')

      else
        params

  ###*
   * [loader description]
   * @method loader
   * @param  {Class} module Класс
   * @return {Object} Миксин
   * @static
  ###
  @loader = (module) ->

    ###*
     * Хранилище статусов загрузки
     * @type {Array}
    ###
    loadingStates: []

    ###*
     * css свойства лоудера
     * здесь только в целях документирования
     * @type {Object}
    ###
    # loadmask_css: {}

    ###*
     * Проявить/скрыть лоудер или вернуть статус загрузки
     * для конкретного элемента - чаще всего для this.el
     * @param  {String} el    = this.el  элемент, внутри которого отобразится лоудер
     * @param  {[type]} state = null статус
     * @return {Boolean} статус
    ###
    loading: (el = @el, state = null) ->

      # в большенстве случаев будет
      # использоваться так: @loading(true/false) и все
      # но можно и @loading '.component', true/false
      if _.isBoolean el
        state = el
        el = @el

      # получаем
      unless state?
        @loadingStates[el]
      else

        mask = if $(el).hasClass('loadmask')
          $(el)
        else
          unless $(el).find('.loadmask').length
            $("<div class='loadmask'></div>").appendTo el
          else
            $(el).find('.loadmask')

        if state # - true

          # настраиваем стиль
          if @loadmask_css?
            mask.css @loadmask_css

          mask.show()

        else # - false
          mask.hide()

        # сетим
        @loadingStates[el] = state

  ###*
   * [sheduler description]
   * @param  {Class} module Класс
   * @return {Object} Миксин
   * @static
  ###
  @sheduler = ->

    queue: []
    processing_queue: false
    task_timeout: null

    shedule: (method, args...) ->

      if @[method]?
        @queue.push
          method: method
          args: args
          scope: this
        @invoke()

    invoke: ->
      if not @processing_queue and (call = @queue.shift())
        @processing_queue = call
        @[call.method].apply(call.scope, call.args)

      @task_timeout = setTimeout =>
        @resolve()
      , 1000

    resolve: (result) ->

      if @processing_queue

        method = @processing_queue.method
        @processing_queue = false

        clearTimeout @task_timeout
        @task_timeout = null

        @invoke()

      if method
        @trigger "resolve:#{method}", result, this

      return result
