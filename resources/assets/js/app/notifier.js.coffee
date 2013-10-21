Slag.register class Notifier

  stack:
    info: []
    success: []
    error: []

  queue: {}

  timeout: 300

  info: humane.spawn
    addnCls: 'humane-jackedup-info'
    timeout: 3000

  success: humane.spawn
    addnCls: 'humane-jackedup-success'
    timeout: 2000

  error: humane.spawn
    addnCls: 'humane-jackedup-error'
    clickToClose: true
    waitForMove: true
    timeout: 5000
    timeoutAfterMove: 5000

  constructor: ->
    Slag.on 'App.info App.error App.success', (args, app, method) =>
      msg = _.first args
      if @isValid msg
        @shedule method, msg

  # минималистическая проверка для строк и массивов
  isValid: (msg) ->
    msg.toString()

  shedule: (method, msg) ->
    @fill method, msg
    @cleanup method
    @queue[method] = (setTimeout =>
      @invoke(method)
    , @timeout)

  cleanup: (method) ->
    if @queue[method]?
      clearTimeout @queue[method]
      @queue[method] = null

  inc: (method, index) ->
    msg = @stack[method][index]
    times = msg.match /[\d]+[\s]+times/i
    @stack[method][index] = if times?
      msg.slice(0, _.indexOf msg, times.index) + (1 + parseInt times[0]) + " times"
    else
      msg + " 2 times"

  fill: (method, msg) ->
    exists = _.indexOf msg, @stack[method]
    if exists >= 0
      @inc method, exists
    else
      @stack[method].push msg

  invoke: (method) ->
    console.log " >> ", method, @stack[method]
    @[method](@stack[method]) if @stack[method].length
    @stack[method] = []

