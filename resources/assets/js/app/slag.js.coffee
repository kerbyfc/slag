###*
 * ***Ядро приложения***
 *
 * - Регистрация классов
 * - Обработка вызовов
 * - Создание новых классов
 *
 * Не инициализируется, должен быть объявлен(подключен) первым
 *
 * @uses Slag.Mixins
 * @uses [Backbone.Events](http://backbonejs.org/#Events-catalog)
###
class Slag extends Backbone.Events

  ###*
   * Корневой путь к методам апи
   * @property api
   * @type {String}
   * @static
  ###
  @api = '/api/frontend/v2/'

  ###*
   * Путь к шаблонам eco
   * @type {String}
  ###
  @templates = "app/templates"

  ###*
   * Флаг, указывающий, нужно ли логировать все события приложения
   * @type {Boolean}
  ###
  @audit = false

  ###*
   * Токен безопасности (csrf)
   * @type {String}
   * @static
  ###
  @token ?= $('meta[name="csrf-token"]').attr('content')

  ###*
   * Возможность группировать логи ( зависит от браузера )
   * @property groupLogs
   * @type {Boolean}
   * @static
  ###
  @groupLogs = _.isFunction console.groupCollapsed

  ###*
   * Имя последней группы логов - помогает различить какие методы
   * вызываются лишний раз и методы
   * которые вызываются рекурсивно
   * + меньше заграмождаем консоль
   * @type {String}
   * @property lastLogGroup
   * @static
  ###
  @lastLogGroup = ""

  @tplCompiler = new (require('./haml-coffee'))
        escapeHtml: true
        escapeAttributes: true
        cleanValue: true
        uglify: false
        extendScope: true
        format: "html5"

  ###*
   * Вывод в консоль отладочной информации о вызове метода
   * в группе, имеющей название Class.method.
   * Если вызов рекурсиный - логи будут в одной группе
   * Если имели место вызовы console.log, то отладочная информация
   * будет там
   * @method logMethodCall
   * @param  {String}      method Имя метода/группы
   * @param  {Object}      call   Вызов
   * @static
  ###
  @logMethodCall = (method, call) ->
    unless Slag.lastLogGroup is method
      console.groupEnd Slag.lastLogGroup
      Slag.lastLogGroup = method
      console.groupCollapsed method
    console.log call

  ###*
   * Ссылки на все классы приложения
   * @property classes
   * @static
   * @type {Object}
  ###
  @classes = {}

  Jacket.config.show_trace = true
  Jacket.protected_methods = ['on', 'bind', '$']

  ###*
   * Коллбек, обрабатывающий вызовы всех методов каждого из классов
   * Slag, которые были переданы методу [Slag.register](#Slag_register)
   * Выполняет функцию логирования мета-информации о вызовах,
   * вызывает обработчики
   * @method callback
   * @param  {Object}   call Мета-объект вызова
   * @uses   Slag.logMethodCall
   * @static
  ###
  @callback = (call) ->

    log = call.scope.audit isnt undefined or Slag.audit is true

    if call.caller.match(/trigger$/)?
      call.args[0] = "#{call.caller.slice(0, -7)}#{call.args[0]}"
      Slag.logMethodCall "#{call.args[0]}", call if log
      Slag.trigger(call.args...)

    else

      Slag.logMethodCall call.caller, call if log

      # имея экземпляр класса Navigator мы можем обрабатывать
      # события путем Bordeuax.on 'Navigator.method'
      # следующие строки позволяют обрабатывать события отработки методов
      # через ссылку app.navigator.on 'method'
      if _.isObject(call.scope._events) and _.has(call.scope._events, call.method)
        Slag.trigger.apply call.scope, [call.method].concat(call.result)

      Slag.trigger call.caller, call.result, call.scope, call.method

  ###*
   * Регистратор классов
   * Данные метод создает объект, хранящий все переданные аргументы,
   * и сохраняет его в [Slag.classes](#Slag_classes),
   * который в будущем используется для инициализации классов или
   * для создании новых классов на базе исходных
   *
   * @method register
   *
   * @param {Class} module Класс
   * @param {Object} [extentions] Расширения
   * @param {RegExp|Boolean} [target_methods] Методы, которые будут обернуты Jacket-ом
   * @param {Array|Boolean} [protected_methods] Массив имен методов, которые не будет обернуты Jacket-ом
   * @param {Function} [callback] Обратный вызов для каждого метода класса
   *
   * @example
   *   Slag.register class MySuperClass extends MyBasicClass
   *   &nbsp; ...
   *
   * @type {Class}
   * @return {Class} Класс
   * @static
  ###
  @register = (module, extentions = {}, target_methods = /^([^\_])/, protected_methods = false, callback = Slag.callback) ->

    extention = Slag.mixin extentions, module

    cfg =
      fname: module.name
      origin: module
      extentions: extentions
      protected_methods: protected_methods
      target_methods: /^([^\_])/
      callback: callback

    Slag.classes[module.name] = cfg

    Slag.define J module.name, module, extentions, target_methods, protected_methods, callback

  ###*
   * Метод, позволяющий создать новый класс на лету
   * @method factory
   *
   * @param  {String} class_name Имя класса (ключ Slag.classes)
   * @param  {Object} [overrides] Переопределения настроек
   * @param  {Array} [args...] Аргументы
   *
   * @return {Class} Новый класс
   * @type {Class}
   * @static
  ###
  @factory = (class_name, overrides = {}, args...) ->

    unless _.has Slag.classes, class_name
      throw new Error "#{class_name} factory wasn't found"

    cfg = _.extend {}, Slag.classes[class_name], overrides
    module = Slag.define J cfg.fname, cfg.origin, cfg.extentions, cfg.target_methods, cfg.protected_methods, cfg.callback

    if args.length
      new module args...
    else
      module

  ###*
   * Определяет тип модуля и в зависимости от типа, кладет модуль
   * в соответствующий скоуп
   *
   * @example
   *   Slag.define(PlaylistModel) # Slag.Models.PlaylistModel
   *
   * @method define
   *
   * @param  {Class} module Класс
   *
   * @type {Class}
   * @return {Class} Класс
   * @static
  ###
  @define = (module) ->

    type = module.name.match(Slag.entities)

    if type? and _.last(type) isnt module.name
      (Slag["#{type.pop()}s"] ?= {})[module.name] = module

    else
      Slag[module.name] = module

    module

  ###*
   * Расширение класса миксинами, которые прописаны в свойстве ```include```
   * @method mixin
   *
   * @param  {Object} extention Расширение класса
   * @param  {Class} module Класс
   *
   * @return {Object} Расширение класса с миксинами
   * @static
  ###
  @mixin = (extention, module) ->

    if _.isObject module::include
      for mixin, flag of module::include
        _.extend extention, Slag.Mixins[mixin](module) if flag

    extention

  ###*
   * Методы компиляции eco шаблона
   * @method template
   * @param  {String} template  путь, относительно директории [Slag.templates](#Slag_templates)
   * @param  {Object} values... данные
   * @return {String}           скомпилированный шаблон
   * @static
  ###
  @template = J 'Slag.template', (template, values...) ->

    if (Slag.JST ?= {})[template] is undefined

      res = $.ajax
        url: "/templates/#{template}",
        async: false

      if res.status is 500
        throw new Error "Template #{template} is broken"

      Slag.tplCompiler.parse(res.responseText)
      Slag.JST[template] = new Function(CoffeeScript.compile(Slag.tplCompiler.precompile(), {bare: true}))

    tpl = Slag.JST[template]

    if tpl is undefined
      throw new Error "Template #{template} wasn't found"

    if values.length and values isnt undefined
      tpl.call _.extend(values...)
    else
      (scope) ->
        tpl.call scope

  ###*
   * Регулярка сущностей приложения
   * Нужна для выделения сущности (Модель, Виджет, Коллекция и т.д.) из имени класса
   * Используется в миксине [Slag.Mixins.has_entity](Slag.Mixins.html#Slag_Mixins_has_entity)
   * @property entities
   * @type {RegExp}
   * @static
  ###
  @entities = /(Model|View|Widget|Collection|Layout|Content|Brick|Input)$/g

_.extend Slag, Backbone.Events

window.Slag = Slag

