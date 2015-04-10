class QuadTree
  constructor: (pLevel, svg, maxObjects = 15, maxLevels = 5) ->
    @level = pLevel
    @bounds = svg
    @_maxObjects = maxObjects
    @_maxLevels = maxLevels
    @objects = []
    @nodes = []

  clear: ->
    @objects.length = 0

    for node in @nodes
      if node isnt null
        node.clear()
        node = null

  _split: ->
    subWidth = @bounds.width / 2
    subHeight = @bounds.height / 2
    x = @bounds.x
    y = @bounds.y

    @nodes[0] = new QuadTree(@level + 1, {x: x + subWidth, y: y, width: subWidth, height: subHeight})
    @nodes[1] = new QuadTree(@level + 1, {x: x, y: y, width: subWidth, height: subHeight})
    @nodes[2] = new QuadTree(@level + 1, {x: x, y: y + subHeight, width: subWidth, height: subHeight})
    @nodes[3] = new QuadTree(@level + 1, {x: x + subWidth, y: y + subHeight, width: subWidth, height: subHeight})

  _getIndex: (rect) ->
    index = -1
    verticalMidpoint = @bounds.x + (@bounds.width / 2)
    horizontalMidpoint = @bounds.y + (@bounds.height / 2)

    topQuadrant = rect.y < horizontalMidpoint and rect.y + rect.height < horizontalMidpoint;
    bottomQuadrant = rect.y > horizontalMidpoint

    if rect.x < verticalMidpoint and rect.x + rect.width < verticalMidpoint
      if topQuadrant then index = 1
      else if bottomQuadrant then index = 2
    else if rect.x > verticalMidpoint
      if topQuadrant then index = 0
      else if bottomQuadrant then index = 3

    return index

  insert: (rect) ->
    if @nodes[0] isnt undefined
      index = @_getIndex rect

      if index isnt -1
        @nodes[index].insert rect

    @objects.push rect

    if @objects.length > @_maxObjects && @level < @_maxLevels
      if @nodes[0] is undefined then @_split()

      i = 0
      while i < @objects.length
        index = @_getIndex(@objects[i])
        if index isnt -1
          @nodes[index].insert(@objects[i])
          @objects.splice(i, 1)
        else
          i++

  retrieve: (list, rect) ->
    index = @_getIndex(rect)
    if index isnt -1 and @nodes[0] isnt undefined
      @nodes[index].retrieve(list, rect)

    list.push.apply(list, @objects)
    return list

  window.QuadTree = QuadTree