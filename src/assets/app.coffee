$ = (selector, el) ->
  (el or document).querySelector selector

class MineApp
  READY: 'ready'
  STARTED: 'started'
  STOPPED: 'stopped'

  constructor: ->
    @core = new MineCore
    @elLeft = $ '#mine-left'
    @elTimer = $ '#mine-timer'
    @elLevel = $ '#mine-level'
    @elRestart = $ '#mine-restart'
    @elMsg = $ '#mine-msg'
    @elGame = $ '#mine-game'
    @status = (
      # state: [READY | STARTED | STOPPED]
      state: @STOPPED
      timer: null
      time: 0
    )
    do @bindEvents
    do @reset

  bindEvents: ->
    @core.listen 'open', @onOpen
    @core.listen 'mark', @onMark
    @core.listen 'spark', @onSpark
    @core.listen 'end', @onEnd
    @elRestart.addEventListener 'click', @onRestart, false
    @elGame.addEventListener 'click', @onClick, false
    @elGame.addEventListener 'contextmenu', @onClick, false
    @elLevel.addEventListener 'change', @onSetLevel, false

  reset: ->
    total = @core.data.width
    html = []
    for i in [0 ... @core.data.height]
      for j in [0 ... @core.data.width]
        html.push '<span class="mine-close"></span>'
      html.push '<br>'
    @elGame.innerHTML = html.join ''
    @els = Array::slice.call @elGame.querySelectorAll 'span'
    do @stopTimer
    do @showTime
    @status.state = @READY
    @elLeft.textContent = @status.mines = @core.data.mines

  tick: =>
    @showTime @status.time + 1

  stopTimer: ->
    if @status.timer
      clearInterval @status.timer
      @status.timer = null

  onRestart: =>
    do @reset
    @elMsg.textContent = '游戏准备好了，你还等什么！'

  onSetLevel: (e) =>
    @core.setLevel e.target.value
    do @reset
    @elMsg.textContent = '游戏准备好了，你还等什么！'

  onClick: (e) =>
    do e.preventDefault
    return if @status.state is @STOPPED
    index = @els.indexOf e.target
    return unless ~index
    if @status.state is @READY
      @core.init index
      @status.timer = setInterval @tick, 1000
      @elMsg.textContent = '加油喔，要小心喔～'
      @status.state = @STARTED
    unless e.button
      @core.checkOpen index
    else
      @core.mark index

  onOpen: (e) =>
    el = @els[e.index]
    cell = @core.cells[e.index]
    el.textContent = if cell.mine then 'X' else cell.number or ''
    el.className = 'mine-open'

  onMark: (e) =>
    el = @els[e.index]
    el.classList.toggle 'mine-marked'
    if @core.cells[e.index].marked
      @status.mines -= 1
    else
      @status.mines += 1
    @elLeft.textContent = @status.mines

  onSpark: (e) =>
    toggle = (add) =>
      for i in e.indexes
        el = @els[i]
        el.classList[if add then 'add' else 'remove'] 'mine-spark'
    toggle true
    setTimeout toggle, 200

  onEnd: (e) =>
    if e.index == null
      @elMsg.textContent = '恭喜你扫雷成功！'
    else
      for cell, i in @core.cells
        el = @els[i]
        if cell.mine
          el.classList.add 'mine-marked'
          el.classList.add 'mine-exploded' if i is e.index
        else if cell.marked
          el.classList.remove 'mine-marked'
          el.classList.add 'mine-wrong'
      @elMsg.textContent = if e.index < 0 then '扫雷失败！' else '你踩雷了！'
    do @stopTimer
    @status.state = @STOPPED

  showTime: (time = 0) ->
    @elTimer.textContent = @status.time = time

app = new MineApp
