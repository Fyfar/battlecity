# ==============================================
# GUI
# ==============================================

class GUI
  constructor: ->
    @cellSize = 44
    @paper = Snap 16 * @cellSize, 15 * @cellSize
    @tree = new QuadTree(0, {x: 0, y: 0, width: 16 * @cellSize, height: 15 * @cellSize})

    do @_bindEvents
    do @_init

  _init: ->
    @paper.rect 0, 0, 16 * @cellSize, 15 * @cellSize
      .attr
        fill: '#ccc'

    @paper.rect @cellSize, @cellSize, @size = 13 * @cellSize, @size
      .attr
        fill: '#000'

  drawLevel: (level) ->
    for i in [0...level.length]
      for j in [0...level[0].length]
        if level[i][j] is 0 then continue

        x = j * @cellSize / 2 + @cellSize
        y = i * @cellSize / 2 + @cellSize

        if level[i][j] is 1
            brick = new Brick(x, y, @cellSize, @paper)
        else if level[i][j]
            brick = new HardBrick(x, y, @cellSize, @paper)

        brick.draw()
        @tree.insert(brick)

    new Player @paper, @cellSize, 'Player1', @tree
      .drawTank()

  _bindEvents: ->
    window.addEventListener 'resize', =>
      @paper.attr
        width: window.innerHeight
        height: window.innerHeight


# ==============================================
# Brick
# ==============================================

class Brick
  constructor: (x, y, cellSize, paper) ->
    @x = x
    @y = y
    @width = @height = cellSize / 2
    @paper = paper

  draw: ->
    brick = @paper.g()

    # fill color
    brick.add(@paper.rect @x, @y, @width, @height
      .attr fill: '#ffa500')

    # add shadow to brick
    brick.add(@paper.rect @x, @y, @width, @height / 8
      .attr fill: '#cd8500')
    brick.add(@paper.rect @x, @y + @width / 2, @width, @height / 8
      .attr fill: '#cd8500')
    brick.add(@paper.rect @x + @width / 2, @y, @width / 8, @height / 2
      .attr fill: '#cd8500')
    brick.add(@paper.rect @x + @width / 8, @y + @width / 2, @width / 8, @height / 2
      .attr fill: '#cd8500')

    # add cement to brick
    brick.add(@paper.rect @x, @y + @width / 2 - @width / 8, @width, @height / 8
      .attr fill: '#d3d3d3')
    brick.add(@paper.rect @x, @y + @width - @width / 8, @width, @height / 8
      .attr fill: '#d3d3d3')
    brick.add(@paper.rect @x + @width / 2 - @width / 8, @y, @width / 8, @height / 2
      .attr fill: '#d3d3d3')
    brick.add(@paper.rect @x, @y + @width / 2 - @width / 8, @width / 8, @height / 2
      .attr fill: '#d3d3d3')

    return brick

class HardBrick extends Brick
  draw: ->
    brick = @paper.g()

    # draw brick
    brick.add(@paper.rect @x, @y, @width, @height
      .attr fill: '#ccc')

    # add shadow
    path = 'M' + @x + ', ' + (@y + @height) +
      ' L' + (@x + @width) + ', ' + (@y + @height) +
      ', ' + (@x + @width) + ', ' + @y + ' Z';
    brick.add(@paper.path path
      .attr fill: '#909090')

    # draw center square
    brick.add(@paper.rect @x + @width / 4, @y + @width / 4, @width / 2, @height / 2
      .attr fill: '#eee')

    return brick


# ==============================================
# Tank
# ==============================================

class Tank
  constructor: (paper, cellSize, name, tree) ->
    @area = paper.svg cellSize, cellSize, cellSize - 1, cellSize - 1
    @paper = paper
    @name = name
    @cellSize = cellSize
    @coords = x: @cellSize / 2, y: @cellSize / 2
    @tank = @area.g()
    @tank.coords = {x: +@area.attr('x'), y: +@area.attr('y'), width: @cellSize - 3, height: @cellSize - 3}
    @direction = 2
    @tree = tree
    @mapSize = min: @cellSize, max: 13 * @cellSize
    @bricks = []
    do @_bindEvents

  update: ->
    @tank.coords.x = +@area.attr('x')
    @tank.coords.y = +@area.attr('y')

  _checkCollision: (obj1, obj2) ->
    x1 = obj1.x
    y1 = obj1.y
    width1 = obj1.width
    height1 = obj1.height

    x2 = obj2.x
    y2 = obj2.y
    width2 = obj2.width
    height2 = obj2.height

    # skip elements
    switch @direction
      when 1 then return false if x2 >= x1 + width1
      when 2 then return false if y2 >= y1 + height1
      when 3 then return false if x2 + width2 <= x1
      when 4 then return false if y2 + height2 <= y1

    # collision
    ((x1 + width1 >= x2) and (x1 <= x2 + width2)) and ((y1 + height1 >= y2) and (y1 <= y2 + height2))

# ==============================================
# Player
# ==============================================

class Player extends Tank
  moveLeft: ->
    @tank.attr transform: 'r-90, ' + @coords.x + ', ' + @coords.y
    @direction = 1

    if @area.attr('x') > @mapSize.min
      do @update

      @bricks.length = 0
      @tree.retrieve(@bricks, @tank.coords)

      for brick in @bricks
        unless !@_checkCollision(brick, @tank.coords)
          return

      @area.attr x: '-= 4'

  moveRight: ->
    if @direction isnt 3
      @tank.attr transform: 'r90, ' + @coords.x + ', ' + @coords.y
      @direction = 3

    if @area.attr('x') < @mapSize.max
      do @update

      @bricks.length = 0
      @tree.retrieve(@bricks, @tank.coords)

      for brick in @bricks
        unless !@_checkCollision(brick, @tank.coords)
          return

      @area.attr x: '+= 4'

  moveUp: ->
    @tank.attr transform: 'r0, ' + @coords.x + ', ' + @coords.y
    @direction = 2

    if @area.attr('y') > @mapSize.min
      do @update

      @bricks.length = 0
      @tree.retrieve(@bricks, @tank.coords)

      for brick in @bricks
        unless !@_checkCollision(brick, @tank.coords)
          return

      @area.attr y: '-= 4'

  moveDown: ->
    @tank.attr transform: 'r180, ' + @coords.x + ', ' + @coords.y
    @direction = 4

    if @area.attr('y') < @mapSize.max
      do @update

      @bricks.length = 0
      @tree.retrieve(@bricks, @tank.coords)

      for brick in @bricks
        unless !@_checkCollision(brick, @tank.coords)
          return

      @area.attr y: '+= 4'

  shot: ->
    bullet = @paper.circle +@area.attr('x') + @coords.x - 2, +@area.attr('y') + @coords.y, 2
    bullet.attr fill: '#fff'

    switch @direction
      when 1 then bullet.animate cx: @cellSize, 1000, mina.linear, @_checkForKill
      when 2 then bullet.animate cy: @cellSize, 1000, mina.linear, @_checkForKill
      when 3 then bullet.animate cx: 14 * @cellSize, 1000, mina.linear, @_checkForKill
      when 4 then bullet.animate cy: 14 * @cellSize, 1000, mina.linear, @_checkForKill

  _checkForKill: ->
    @.remove()

  drawTank: ->
      leftTrack = @_drawTrack 0, 0, 'left'
      body = @_drawTankBody 20, 25
      rightTrack = @_drawTrack 30, 0, 'right'

      @tank.add leftTrack, body, rightTrack

  _drawTrack: (x, y, way) ->
    track = @area.g()
    main = @area.rect x, y + @cellSize / 8, 10, @cellSize
    main.attr fill: '#ccc'

    track.add main

    if way is 'right'
      x += 5

    for i in [2 + y...y + @cellSize] by @cellSize / 8
      trackLine = @area.rect x, i + @cellSize / 8, 5, 1
      trackLine.attr fill: '#0000b2'

      track.add trackLine

    return track

  _drawTankBody: (x, y) ->
    main = @area.ellipse x, y, 14, 18
    main.attr fill: '#ccc'

    top = @area.ellipse x, y, 9, 13
    top.attr fill: '#e2e2e2'

    gun = @area.rect x - 1, y - 23, 2, 11
    gun.attr fill: '#e2e2e2'

    redPoint = @area.rect x - 1, y - 25, 2, 2
    redPoint.attr fill: '#b20000'

    @area.g main, top, gun, redPoint

  _bindEvents: ->
    press = []
    document.addEventListener 'keypress', (e) =>
      switch e.keyCode
        when 97 then do @moveLeft
        when 100 then do @moveRight
        when 119 then do @moveUp
        when 115 then do @moveDown
        when 32
          if press['32'] == null
            do @shot
            press['32'] = true

    document.addEventListener 'keyup', (e) =>
      if e.keyCode is 32
        press['32'] = null


gui = new GUI

level1 = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1],
  [2, 2, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 2, 2],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
]

gui.drawLevel level1