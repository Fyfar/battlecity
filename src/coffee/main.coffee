# ==============================================
# Node
# ==============================================

class Node
    constructor: (@key, @value, @left, @right) ->


# ==============================================
# BSTree
# ==============================================

class Tree
    @_root = null

    constructor: ->

    add: (key, value) ->
        node = new Node key, value, null, null
        current = null

        if not @_root
            @_root = node
        else
            current = @_root

            while true
                if key < current.key
                    if current.left is null
                        current.left = node
                        break
                    else
                        current = current.left
                else if key > current.key
                    if current.right is null
                        current.right = node
                        break
                    else
                        current = current.right
                else
                    if Array.isArray current.value
                        current.value.push value
                    else
                        current.value = [value, current.value]

                    break

    traverse: (callback) ->
        inOrder = (node) ->
            if node
                if node.left isnt null
                    inOrder node.left

                callback.call @, node

                if node.right isnt null
                    inOrder node.right

        inOrder @_root

    contains: (key) ->
        found = false
        current = @_root

        while not found and current
            if key < current.key
                current = current.left
            else if key > current.key
                current = current.right
            else
                found = true

        return found

    removeValue: (key, value) ->
        found = false
        current = @_root

        while not found and current
            if key < current.key
                current = current.left
            else if key > current.key
                current = current.right
            else
                found = true
                if Array.isArray current.value
                    indexValue = current.value.indexOf value
                    current.value.splice indexValue, 1
                else @remove key

        return found

    greaterThan: (key) ->
        nodes = []

        @traverse (node) ->
            if key <= node.key
                if Array.isArray node.value
                    nodes = nodes.concat node.value
                else
                    nodes.push node.value

        return nodes

    lessThan: (key) ->
        nodes = []

        @traverse (node) ->
            if key >= node.key
                nodes.push node

        return nodes

    subTree: (fromKey, toKey) ->
        tree = new Tree

        @traverse (node) ->
            if node.key >= fromKey and node.key <= toKey
                tree.add node.key, node.value

        return tree

    remove: (key) ->
        found = false
        parent = null
        current = @_root
        childCount = null
        replacement = null
        replacementParent = null

        while not found and current
            if key < current.key
                parent = current
                current = current.left
            else if key > current.key
                parent = current
                current = current.right
            else
                found = true

        if found
            childCount = (if current.left isnt null then 1 else 0) + (if current.right isnt null then 1 else 0)

            if current is @_root
                switch childCount
                    when 0
                        @_root = null
                        break
                    when 1
                        @_root = if current.right is null then current.left else current.right
                        break
                    when 2
                        replacement = @_root.left

                        while replacement.right isnt null
                            replacementParent = replacement
                            replacement = replacement.right

                        if replacementParent isnt null
                            replacementParent.right = replacement.left

                            replacement.right = @_root.right
                            replacement.left = @_root.left
                        else
                            replacement.right = @_root.right

                        @_root = replacement

            else
                switch childCount
                    when 0
                        if current.key < parent.key
                            parent.left = null
                        else
                            parent.right = null
                        break
                    when 1
                        if current.key < parent.key
                            parent.left = if current.left is null then current.right else current.left
                        else
                            parent.right = if current.left is null then current.right else current.left
                        break
                    when 2
                        replacement = current.left
                        replacementParent = current

                        while replacement.right isnt null
                            replacementParent = replacement
                            replacement = replacement.right

                        replacementParent.right = replacement.left

                        replacement.right = current.right
                        replacement.left = current.left

                        if current.key < parent.key
                            parent.left = replacement
                        else
                            parent.right = replacement

    size: ->
        length = 0

        @traverse (node) ->
            length++

        length

    toArray: ->
        nodes = []

        @traverse (node) ->
            if Array.isArray node.value
                nodes = nodes.concat node.value
            else
                nodes.push node.value

        nodes

    toString: ->
        @toArray().toString()


# ==============================================
# Configuration
# ==============================================

class Configuration
    @cellSize: 44

    @mapSize: 13 * @cellSize

    @gameSize:
        width: 16 * @cellSize
        height: 14 * @cellSize

    @playerSize: 40
    @enemySize: 40

    @collisionAreaCache: @cellSize + 40
    @nearestBlocks: @cellSize * 3

    @moveTick: 20
    @bulletTick: 20

    @moveLength: 3
    @bulletStep: 5

    @_directions:
        UP: 1,
        DOWN: 2,
        LEFT: 3,
        RIGHT: 4

    @shotButton: 'F'

    @defaultShotDelay: 700


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
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'LT', 'RT', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'LB', 'RB', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
]


# ==============================================
# Drawer
# ==============================================

class Drawer
    paper = null
    player = null
    enemies = []

    drawPlayer: (x, y) ->
        player = paper.svg(x, y, Configuration.playerSize, Configuration.playerSize)

        drawTankBody = (x, y) ->
            body = player.g()

            main = player.ellipse x, y, 14, 18
            main.attr fill: '#ccc'

            top = player.ellipse x, y, 9, 13
            top.attr fill: '#e2e2e2'

            gun = player.rect x - 1, y - 23, 2, 11
            gun.attr fill: '#e2e2e2'

            redPoint = player.rect x - 1, y - 25, 2, 2
            redPoint.attr fill: '#b20000'

            body.add main, top, gun, redPoint

            return body

        drawTrack = (x, y, way) ->
            track = player.g()

            width = +player.attr('width') / 4
            height = +player.attr('height') - 5

            main = player.rect x, y + Configuration.cellSize / 8, width, height
            main.attr fill: '#ccc'

            track.add main

            if way is 'right'
              x += 5

            startY = y + Configuration.cellSize / 8

            for yCoord in [2 + startY...startY + height] by Configuration.cellSize / 8
              trackLine = player.rect x, yCoord, 5, 1
              trackLine.attr fill: '#0000b2'

              track.add trackLine

            return track

        leftTrack = drawTrack 0, 0, 'left'
        body = drawTankBody 0 + (Configuration.playerSize / 2), 0 + (Configuration.playerSize / 2) + 3
        rightTrack = drawTrack 0 + Configuration.playerSize - 10, 0, 'right'

        {
            tankSvg: player,
            tankGroup: player.g leftTrack, body, rightTrack
        }

    drawEnemy: (x, y) ->
        enemy = paper.svg(x, y, Configuration.enemySize, Configuration.enemySize)

        drawTankBody = (x, y) ->
            body = enemy.g()

            main = enemy.ellipse x, y, 14, 18
            main.attr fill: '#ccc'

            top = enemy.ellipse x, y, 9, 13
            top.attr fill: '#e2e2e2'

            gun = enemy.rect x - 1, y - 23, 2, 11
            gun.attr fill: '#e2e2e2'

            redPoint = enemy.rect x - 1, y - 25, 2, 2
            redPoint.attr fill: '#b20000'

            body.add main, top, gun, redPoint

            return body

        drawTrack = (x, y, way) ->
            track = enemy.g()

            width = +enemy.attr('width') / 4
            height = +enemy.attr('height') - 5

            main = enemy.rect x, y + Configuration.cellSize / 8, width, height
            main.attr fill: '#ccc'

            track.add main

            if way is 'right'
              x += 5

            startY = y + Configuration.cellSize / 8

            for yCoord in [2 + startY...startY + height] by Configuration.cellSize / 8
              trackLine = enemy.rect x, yCoord, 5, 1
              trackLine.attr fill: '#0000b2'

              track.add trackLine

            return track

        leftTrack = drawTrack 0, 0, 'left'
        body = drawTankBody 0 + (Configuration.enemySize / 2), 0 + (Configuration.enemySize / 2) + 3
        rightTrack = drawTrack 0 + Configuration.enemySize - 10, 0, 'right'

        enemyObject = {
            tankSvg: enemy,
            tankGroup: enemy.g leftTrack, body, rightTrack
        }

        enemies.push enemyObject
        return enemyObject

    initGame: ->
        paper = Snap Configuration.gameSize.width, Configuration.gameSize.height

        paper.rect 0, 0, +paper.attr('width'), +paper.attr('height')
            .attr
                fill: '#ccc'

        paper = paper.svg(Configuration.cellSize, 20, Configuration.mapSize, Configuration.mapSize)

        paper.rect 0, 0, +paper.attr('width'), +paper.attr('height')
            .attr
                fill: '#000'

        paper

    drawLevel: (level) ->
        bricks = []
        for i in [0...level.length]
            for j in [0...level[0].length]
                if level[i][j] is 0 then continue

                x = j * Configuration.cellSize / 2
                y = i * Configuration.cellSize / 2

                brick = null
                if level[i][j] is 1
                    brick = new Brick x, y, paper
                else if level[i][j] is 2
                    brick = new HardBrick x, y, paper
                else if level[i][j] in ['LT', 'RT', 'LB', 'RB']
                    brick = new WinnerFlag x, y, paper, level[i][j]

                bricks.push brick

        bricks

    createBullet: (direction) ->
        bulletCoords = 
            1:
                x: +player.attr('x') + +player.attr('width') / 2
                y: +player.attr('y')
            2:
                x: +player.attr('x') + +player.attr('width') / 2
                y: +player.attr('y') + +player.attr('height')
            3:
                x: +player.attr('x')
                y: +player.attr('y') + +player.attr('height') / 2
            4:
                x: +player.attr('x') + +player.attr('width')
                y: +player.attr('y') + +player.attr('height') / 2

        bullet = paper.circle bulletCoords[direction].x, bulletCoords[direction].y, 3
        bullet.attr fill: '#fff'

        bullet

# ==============================================
# GUI
# ==============================================

class GUI
    xTree = new Tree
    yTree = new Tree
    drawer = new Drawer()

    constructor: ->
        @paper = drawer.initGame()

        do @_bindEvents

    startGame: ->
        bricks = drawer.drawLevel(level1)

        for index, brick of bricks
            xTree.add brick.coords.x, brick
            yTree.add brick.coords.y, brick

        new Player drawer, xTree, yTree
        new Enemy drawer, xTree, yTree

    _bindEvents: ->
        window.addEventListener 'resize', =>
            @paper.attr
                width: window.innerHeight
                height: window.innerHeight


# ==============================================
# Brick
# ==============================================

class Brick
    constructor: (@x, @y, @paper) ->
        @width = @height = Configuration.cellSize / 2

        @svg = do @draw
        @coords = @svg.getBBox()

        @destructible = true

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

    isDestructible: ->
        return @destructible

    destroy: ->
        do @svg.remove


# ==============================================
# HardBrick
# ==============================================

class HardBrick extends Brick
    constructor: (@x, @y, @paper)->
        super(@x, @y, @paper)

        @destructible = false

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

        brick


class WinnerFlag extends Brick
    _flagPartToLoad =
        'LT': 'img/flag-0-0.svg',
        'RT': 'img/flag-0-1.svg',
        'LB': 'img/flag-1-0.svg',
        'RB': 'img/flag-1-1.svg'

    _scaleFactor =
        'LT':
            x: 0.009, y: -0.0105,
        'RT':
            x: 0.009, y: -0.0105,
        'LB':
            x: 0.012, y: -0.0103,
        'RB':
            x: 0.0117, y: -0.0103

    constructor: (@x, @y, @paper, @part) ->
        super @x, @y, @paper

    draw: ->
        flag = @paper.g @paper.rect @x, @y, Configuration.cellSize / 2, Configuration.cellSize / 2
        Snap.load _flagPartToLoad[@part], (f) =>
            g = f.selectAll('g')

            @y = @y + Configuration.cellSize / 2

            if @part in ['LB', 'RB']
                @y += 2.5

            if @part is 'LB'
                @x = @x - 7

            transformFunc = "t#{@x},#{@y}s#{_scaleFactor[@part].x},#{_scaleFactor[@part].y}"

            g.attr
                fill: 'red'
                transform: transformFunc

            flag.add g
            flag.select('rect').remove()
        flag

    destroy: ->
        alert 'Lose!'


# ==============================================
# Weapon
# ==============================================

class Weapon
    constructor: (@tank) ->
        @lastShot = Date.now()
        @shotDelay = Configuration.defaultShotDelay

    shot: (callback) =>
        @tank.shot callback

    shotAvailable: =>
        Date.now() - @lastShot >= @shotDelay


# ==============================================
# Tank
# ==============================================

class Tank
    constructor: (@drawer, x, y, enemy = false) ->
        tank = null

        if enemy
            tank = @drawer.drawEnemy x, y
        else
            tank = @drawer.drawPlayer x, y

        @tankSvg = tank.tankSvg
        @tankGroup = tank.tankGroup

        do @turnUp

        @tankCenter = +@tankSvg.attr('width') / 2

    moveUp: =>
        do @turnUp

        @tankSvg.attr y: '-=' + Configuration.moveLength

    moveDown: =>
        do @turnDown

        @tankSvg.attr y: '+=' + Configuration.moveLength

    moveLeft: =>
        do @turnLeft

        @tankSvg.attr x: '-=' + Configuration.moveLength

    moveRight: =>
        do @turnRight

        @tankSvg.attr x: '+=' + Configuration.moveLength

    turnUp: =>
        if @_direction isnt Configuration._directions.UP
            @_direction = Configuration._directions.UP

            rotateFunction = "r0,#{@tankCenter},#{@tankCenter}"
            @tankGroup.transform rotateFunction

    turnDown: =>
        if @_direction isnt Configuration._directions.DOWN
            @_direction = Configuration._directions.DOWN

            rotateFunction = "r180,#{@tankCenter},#{@tankCenter}"
            @tankGroup.transform rotateFunction

    turnLeft: =>
        if @_direction isnt Configuration._directions.LEFT
            @_direction = Configuration._directions.LEFT

            rotateFunction = "r-90,#{@tankCenter},#{@tankCenter}"
            @tankGroup.transform rotateFunction

    turnRight: =>
        if @_direction isnt Configuration._directions.RIGHT
            @_direction = Configuration._directions.RIGHT

            rotateFunction = "r90,#{@tankCenter},#{@tankCenter}"
            @tankGroup.transform rotateFunction

    shot: (callback) =>
        direction = @_direction
        bullet = @drawer.createBullet direction

        bulletInterval = setInterval () =>
            if direction is Configuration._directions.UP
                bullet.attr cy: '-= ' + Configuration.bulletStep
            else if direction is Configuration._directions.DOWN
                bullet.attr cy: '+= ' + Configuration.bulletStep
            else if direction is Configuration._directions.LEFT
                bullet.attr cx: '-= ' + Configuration.bulletStep
            else if direction is Configuration._directions.RIGHT
                bullet.attr cx: '+= ' + Configuration.bulletStep

            if callback? and callback(bullet) or @_outOfMap(bullet, direction)
                do bullet.remove
                clearInterval bulletInterval

        , Configuration.bulletTick

    _outOfMap: (bullet, direction) =>
        if direction is Configuration._directions.UP
            +bullet.attr('cy') < 0
        else if direction is Configuration._directions.DOWN
            +bullet.attr('cy') > Configuration.mapSize
        else if direction is Configuration._directions.LEFT
            +bullet.attr('cx') < 0
        else if direction is Configuration._directions.RIGHT
            +bullet.attr('cx') > Configuration.mapSize

    getDirection: =>
        @_direction

    destroy: =>
        do @tankSvg.remove


# ==============================================
# Enemy
# ==============================================

class Enemy
    constructor: (drawer, @xTree, @yTree) ->
        @tank = new Tank drawer, 0, 0, true

        @coords = {x: 0, y: 0}

        #do @_parseLevel

        document.addEventListener 'keydown', (e) =>
            keyName = String.fromCharCode e.charCode or e.keyCode
            if keyName is 'N'
                do @move


    _parseLevel: =>
        for i in [0...@level.length]
            for j in [0...@level[0].length]
                if @level[i][j] isnt 0 then continue

                x = j * Configuration.cellSize / 2
                y = i * Configuration.cellSize / 2

                xTree.add x, {x: x, y: y}
                yTree.add y, {x: x, y: y}

    move: =>
        moves = [
            @_moveDown,
            @_moveUp,
            @_moveLeft,
            @_moveRight
        ]

        cellCount = Math.floor(Math.random() * (Configuration.mapSize / Configuration.cellSize - 1)) + 1

        ###moveMethod = moves[ Math.floor(Math.random() * moves.length) ]
        moveMethod cellCount###
        console.log 'Cell count: ' + cellCount
        @_moveDown cellCount

    _moveDown: (cellCount) =>
        bricks = @xTree.subTree(@coords.x, @coords.x + Configuration.enemySize - 1).toArray()
        bricks.sort (a, b) ->
            a.coords.y - b.coords.y

        for index, element of @xTree.toArray()
            element.svg.attr stroke: ''

        for index, element of bricks
            element.svg.attr stroke: 'red'

        if bricks.length > 0
            newY = if bricks[0].coords.y > cellCount * Configuration.cellSize then cellCount * Configuration.cellSize else bricks[0].coords.y
        else
            newY = cellCount * Configuration.cellSize

        console.log 'Y: ' + newY

        id = setInterval () =>
            @coords.y += Configuration.moveLength
            if @coords.y + Configuration.enemySize >= newY or @coords.y + Configuration.enemySize >= Configuration.mapSize
                clearInterval id
                @coords.y -= Configuration.moveLength
                return

            do @tank.moveDown
        , Configuration.moveTick

    _moveUp: =>
        bricks = @xTree.subTree(@coords.x - 5, @coords.x + Configuration.cellSize - 1).toArray()
        bricks.sort (a, b) ->
            -(a.coords.y - b.coords.y)

        for index, element of @xTree.toArray()
            element.svg.attr stroke: ''

        for index, element of bricks
            element.svg.attr stroke: 'red'

        newCell = @coords.y - Configuration.cellSize
        if bricks.length > 0
            newY = if newCell <= bricks[0].coords.y then bricks[0].coords.y else newCell
        else
            newY = newCell

        console.log 'Up: ' + newY

        id = setInterval () =>
            @coords.y -= Configuration.moveLength
            if @coords.y <= newY or @coords.y <= 0
                clearInterval id
                @coords.y += Configuration.moveLength
                return

            do @tank.moveUp
        , Configuration.moveTick

    _moveLeft: =>
        bricks = @yTree.subTree(@coords.y - 5, @coords.y + Configuration.cellSize - 1).toArray()
        bricks.sort (a, b) ->
            -(a.coords.x - b.coords.x)

        for index, element of @xTree.toArray()
            element.svg.attr stroke: ''

        for index, element of bricks
            element.svg.attr stroke: 'red'

        newCell = @coords.x - Configuration.cellSize
        if bricks.length > 0
            newX = if newCell <= bricks[0].coords.x then bricks[0].coords.x else newCell
        else
            newX = newCell

        console.log 'Left: ' + newX

        id = setInterval () =>
            @coords.x -= Configuration.moveLength
            if @coords.x <= newX or @coords.x <= 0
                clearInterval id
                @coords.x += Configuration.moveLength
                return

            do @tank.moveLeft
        , Configuration.moveTick

    _moveRight: =>
        bricks = @yTree.subTree(@coords.y - 5, @coords.y + Configuration.cellSize - 1).toArray()
        bricks.sort (a, b) ->
            a.coords.x - b.coords.x

        for index, element of @xTree.toArray()
            element.svg.attr stroke: ''

        for index, element of bricks
            element.svg.attr stroke: 'red'

        newCell = @coords.x + Configuration.enemySize + Configuration.cellSize
        if bricks.length > 0
            newX = if newCell >= bricks[0].coords.x then bricks[0].coords.x else newCell
        else
            newX = newCell

        console.log 'Right: ' + newX

        id = setInterval () =>
            @coords.x += Configuration.moveLength
            if @coords.x + Configuration.enemySize >= newX or @coords.x + Configuration.enemySize >= Configuration.mapSize
                clearInterval id
                @coords.x -= Configuration.moveLength
                return

            do @tank.moveRight
        , Configuration.moveTick



# ==============================================
# Player
# ==============================================

class Player
    moveButtons = {}
    timer = null
    collisionArea = []
    lastPosition = null
    lastBreakElement = null

    constructor: (drawer, @xTree, @yTree) ->
        @tank = new Tank drawer, Configuration.cellSize * 4, Configuration.mapSize - Configuration.cellSize
        @weapon = new Weapon @tank

        @coords = {x: +@tank.tankSvg.attr('x'), y: +@tank.tankSvg.attr('y'), width: +@tank.tankSvg.attr('width'), height: +@tank.tankSvg.attr('height')}
        lastPosition = $.extend({}, @coords)

        moveButtons = {
            'W': () => @move @moveUp,
            'S': () => @move @moveDown,
            'A': () => @move @moveLeft,
            'D': () => @move @moveRight
        }

        do @_bindEvents
        @_getCollisionArea(true)

    _bindEvents: ->
        document.addEventListener 'keydown', (e) =>
            keyName = String.fromCharCode e.charCode or e.keyCode
            moveMethod = moveButtons[keyName]
            if moveMethod? and not timer?
                do moveMethod

        document.addEventListener 'keyup', (e) =>
            keyName = String.fromCharCode e.charCode or e.keyCode
            moveMethod = moveButtons[keyName]
            if moveMethod? and timer?
                clearInterval timer
                timer = null

            if keyName is Configuration.shotButton and @weapon.shotAvailable()
                @weapon.lastShot = Date.now()
                do @shot

    move: (method) ->
        timer = setInterval method, Configuration.moveTick

    moveLeft: =>
        @coords.x -= Configuration.moveLength
        if @coords.x >= 0
            if not do @_checkCollision
                do @tank.moveLeft
            else
                @coords.x += Configuration.moveLength
        else
            @coords.x += Configuration.moveLength

    moveRight: =>
        @coords.x += Configuration.moveLength
        if @coords.x <= Configuration.mapSize - Configuration.playerSize
            if not do @_checkCollision
                do @tank.moveRight
            else
                @coords.x -= Configuration.moveLength
        else
            @coords.x -= Configuration.moveLength

    moveUp: =>
        @coords.y -= Configuration.moveLength
        if @coords.y >= 0
            if not do @_checkCollision
                do @tank.moveUp
            else
                @coords.y += Configuration.moveLength
        else
            @coords.y += Configuration.moveLength

    moveDown: =>
        @coords.y += Configuration.moveLength
        if @coords.y <= Configuration.mapSize - Configuration.playerSize
            if not do @_checkCollision
                do @tank.moveDown
            else
                @coords.y -= Configuration.moveLength
        else
            @coords.y -= Configuration.moveLength

    shot: =>
        bricks = []
        if @tank.getDirection() is Configuration._directions.UP or @tank.getDirection() is Configuration._directions.DOWN
            bricks = @xTree.subTree(@coords.x - 5, @coords.x + Configuration.cellSize - 1).toArray()
        else
            bricks = @yTree.subTree(@coords.y - 5, @coords.y + Configuration.cellSize - 1).toArray()

        checkForKill = (bullet) =>
            bulletCoords = @_bulletToSquare bullet
            for index, element of bricks
                if @_check bulletCoords, element.coords
                    if element.isDestructible()
                        if lastBreakElement is element
                            return false

                        lastBreakElement = element

                        @xTree.removeValue element.coords.x, element
                        @yTree.removeValue element.coords.y, element

                        do element.destroy

                        @_getCollisionArea(true)

                    return true

        @weapon.shot checkForKill

    _bulletToSquare: (bullet) ->
        {x: +bullet.attr('cx'), y: +bullet.attr('cy'), width: +bullet.attr('r') * 2, height: +bullet.attr('r') * 2}

    _checkCollision: ->
        for index, element of @_getCollisionArea()
            if @_check @coords, element.coords
                return yes

    _check: (first, second) ->
        return first.x < second.x + second.width and first.x + first.width > second.x and
            first.y < second.y + second.height and first.y + first.height > second.y

    _getCollisionArea: (init = false) ->
        intersection = (xArray, yArray) ->
            arrays = [xArray, yArray]

            intersectArray = arrays.shift().filter (item) ->
                arrays.every (array) ->
                    array.some (secondItem) ->
                        (item.coords.x is secondItem.coords.x) and (item.coords.y is secondItem.coords.y)

            intersectArray

        if Math.abs(@coords.x - lastPosition.x) >= Configuration.collisionAreaCache or
        Math.abs(@coords.y - lastPosition.y) >= Configuration.collisionAreaCache or 
        init

            lastPosition = $.extend({}, @coords)

            xSubTree = @xTree.subTree((@coords.x - Configuration.nearestBlocks), (@coords.x + Configuration.nearestBlocks)).toArray()
            ySubTree = @yTree.subTree((@coords.y - Configuration.nearestBlocks), (@coords.y + Configuration.nearestBlocks)).toArray()

            collisionArea = intersection xSubTree, ySubTree

        collisionArea


gui = new GUI
do gui.startGame