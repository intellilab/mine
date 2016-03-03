class MineCore
  DEFAULT_LEVEL: 1

  constructor: ->
    @setLevel @DEFAULT_LEVEL
    @events = {}

  levels:
    1:
      width: 10
      height: 10
      mines: 10
    2:
      width: 16
      height: 16
      mines: 40
    3:
      width: 30
      height: 16
      mines: 99

  setLevel: (level) ->
    data = @levels[level]
    return @setLevel @DEFAULT_LEVEL unless data
    @data = Object.assign(
      level: level
      closed: data.width * data.height - data.mines
    , data)

  init: (index) ->
    @cells = []
    mines = @data.mines
    total = @data.width * @data.height
    # There should not be mines in the first clicked cell and its surroundings
    surroundings = @getSurroundings index
    surroundings.push index
    for i in surroundings
      @cells[i] = (
        mine: 0
        number: 0
        open: false
        marked: false
      )
    _total = total - surroundings.length
    offset = 0
    for i in [0 ... _total]
      x = do Math.random <= mines / (_total - i)
      x = x & 1
      mines -= x
      while @cells[i + offset]
        offset += 1
      @cells[i + offset] = (
        mine: x
        number: 0
        open: false
        marked: false
      )
    for cell, i in @cells
      continue unless cell.mine
      for j in @getSurroundings i
        @cells[j].number += 1

  emit: (data) ->
    cbs = @events[data.type]
    cbs.forEach (cb) -> cb data

  listen: (type, cb) ->
    events = @events[type]
    unless events
      events = @events[type] = []
    events.push cb

  mark: (index) ->
    cell = @cells[index]
    return if not cell or cell.open
    cell.marked = not cell.marked
    @emit(
      type: 'mark'
      index: index
    )

  open: (index) ->
    cell = @cells[index]
    return if cell.open or cell.marked
    cell.open = true
    @data.closed -= 1
    @emit(
      type: 'open'
      index: index
    )
    @spread index if not cell.number
    do @end unless @data.closed

  checkOpen: (index) ->
    cell = @cells[index]
    return if not cell or cell.marked
    return @end index if cell.mine
    return @checkSpread index if cell.open
    @open index

  getSurroundings: (index) ->
    indexes = []
    width = @data.width
    total = @data.width * @data.height
    if index % width
      indexes.push index - width - 1, index - 1, index + width - 1
    indexes.push index - width, index + width
    if (index + 1) % width
      indexes.push index - width + 1, index + 1, index + width + 1
    indexes.filter (index) -> 0 <= index < total

  spread: (index) ->
    surroundings = @getSurroundings index
    for i in surroundings
      @open i

  checkSpread: (index) ->
    allOpen = true
    allMarked = true
    incorrect = false
    for i in @getSurroundings index
      cell = @cells[i]
      allOpen = allOpen and cell.open
      allMarked = allMarked and (not cell.mine or cell.marked)
      incorrect = incorrect or not cell.mine and cell.marked
    return @end -1 if incorrect
    return @spark index if not allMarked
    @spread index if not allOpen

  spark: (index) ->
    surroundings = @getSurroundings index
    surroundings = surroundings.filter (i) =>
      cell = @cells[i]
      not cell.open and not cell.marked
    @emit(
      type: 'spark'
      indexes: surroundings
    )

  end: (index) ->
    # index is -1: incorrect mark
    # index is nonzero: clicked on mine
    # index is null: win
    @emit(
      type: 'end'
      index: index
    )
