import prelude

class Tetris
  (options) ->
    @colors = options.colors
    @num-rows = 18
    @num-cols = 10
    @grid = [[0 for i from 1 to @num-cols] for j from 1 to @num-rows]
    @cur-piece = @random-piece!
    @piece-pos = { r: 0, c: @num-cols/2 - 1 }
  start: ->
    try
      @canvas = document.querySelector ".tetris canvas" .get-context "2d"
      set-interval @step, 1000
      @bind-keys!
      @draw!
    catch e
      throw "Tetris: disabled (no canvas#tetris element)"
  pieces:
      [[1 1]
       [1 1]]
      [[0 0 1]
       [1 1 1]]
      [[1 0 0]
       [1 1 1]]
      [[1 1 0]
       [0 1 1]]
      [[0 1 1]
       [1 1 0]]
      [[0 1 0]
       [1 1 1]]
      [[1 1 1 1]]
  step: ~>
    @piece-pos.r += 1
    if @is-colliding!
      @move-up!
      @glue-piece!
    @draw!
  bind-keys: ->
    $ document .keydown (e) ~>
      switch e.which
        | 37 => @move-left!
        | 39 => @move-right!
        | 40 => @move-down!
        | 32 => @drop!
        | 38 => @cur-piece = @rotate-right @cur-piece
        |  _ => no-key = true
      unless no-key
        e.prevent-default!
        @draw!
  move-right: -> if @move { dc: +1 } => @piece-pos = that
  move-left:  -> if @move { dc: -1 } => @piece-pos = that
  move-down:  -> if @move { dr: +1 } => @piece-pos = that
  move-up:    -> if @move { dr: -1 } => @piece-pos = that /* Not bound to a key */
  move: ({ dr || 0, dc || 0 }, { r, c } = @piece-pos) ->
    new-pos = { r: r + dr, c: c + dc }
    if @on-board(new-pos) && ! @is-colliding new-pos
      new-pos
    else false
  on-board: ({ r, c }) ->
    width = @cur-piece[0].length
    height = @cur-piece.length
    max-row = @num-rows - height
    max-col = @num-cols - width
    r >= 0 && r <= max-row && c >= 0 && c <= max-col
  drop: ->
    while @move-down! then;
    /* Loop until return value is false */
    @glue-piece!
  clear-rows: ->
    rows-to-clear = []
    for row, r in @grid
      if and-list row
        rows-to-clear.push r
    rows-to-clear
      |> each @clear-row
  clear-row: (r) ~>
    @grid.splice r, 1
    @grid.unshift [0 for r from 1 to @num-cols]
  is-colliding: (pos ? @piece-pos)->
    | pos.r + @cur-piece.length > @num-rows
      then true
    | _ then
      for row, r in @cur-piece
        for val, c in row
          return true if val && @grid[r + pos.r][c + pos.c]
  glue-piece: ->
    for row, r in @cur-piece
      for val, c in row
       @grid[r + @piece-pos.r][c + @piece-pos.c] ||= val
    @clear-rows!
    @new-piece!
    @check-lose!
  new-piece: ->
    @cur-piece = @random-piece!
    @piece-pos = { r: 0, c: Math.floor (@num-cols - @cur-piece[0].length)/2 }
  random-piece: ->
    return @pieces[Math.floor(Math.random! * @pieces.length)]
  rotate-left: (piece) ->
    max-row = piece.length - 1
    max-col = piece[0].length - 1
    return [[piece[r][c] for r from 0 to max-row] for c from max-col to 0 by -1]
  rotate-right: (piece) ->
    max-row = piece.length - 1
    max-col = piece[0].length - 1
    while piece.length + @piece-pos.c > @num-cols
      @move-left!
    return [[piece[r][c] for r from max-row to 0 by -1] for c from 0 to max-col]
  draw: ~>
    @canvas.clear-rect(0,0,@canvas.width,@canvas.width)
    @draw-grid!
    @draw-prediction!
    @draw-piece!
  draw-square: ({r, c}, color) ->
    @canvas.fill-style = color
    @canvas.fill-rect(c*20, r*20, 20, 20)
  draw-grid: ->
    for row, r in @grid
      for val, c in row
        color = switch
          | @grid[r][c]  => @colors.wall
          | !@grid[r][c] => @colors.background
        @draw-square({ r: r, c: c }, color)
  draw-piece: (pos ? @piece-pos, piece ? @cur-piece, piece-color) ->
    for row, dr in piece
      for col, dc in row
        r = dr + pos.r
        c = dc + pos.c
        color = switch
          | piece[dr][dc]  => piece-color ? @colors.piece
          | !piece[dr][dc] => "transparent"
        @draw-square({r: r, c: c}, color)
  draw-prediction: ->
    pos = ^^@piece-pos
    while @move { dr: +1 }, pos
      pos = that
    @draw-piece pos, @cur-piece, @colors.prediction
  check-lose: ->
    if @is-lost!
      console.log("You lose :(")
  is-lost: ->
    @piece-pos.r == 0 && @is-colliding!

$ ->
  t = new Tetris do
    colors:
      background: 'black'
      piece: '#080'
      prediction: '#800'
      wall: '#F00'
  try
    t.start!
  catch e
    console.log e
