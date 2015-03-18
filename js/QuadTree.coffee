class QuadTree
  constructor: (bounds, pointQuad, maxDepth, maxChildren) ->
    if pointQuad
      node = new Node bounds, 0, maxDepth, maxChildren
    else
      node = new BoundsNode bounds, 0, maxDepth, maxChildren

    @root = node

  insert: (item) ->
    if item instanceof Array
      for i in item
        @root.insert i
    else
      @root.insert item

  clear: ->
    do @root.clear

  retrieve: (item) ->
    @root.retrieve(item).slice(0)

class Node
  constructor: (bounds, depth = 0, maxDepth = 4, maxChildren = 4) ->
    @_bounds = bounds
    @children = []
    @nodes = []
    @_maxChildren = maxChildren
    @_maxDepth = maxDepth
    @_depth = depth

    Node.TOP_LEFT = 0
    Node.TOP_RIGHT = 1
    Node.BOTTOM_LEFT = 2
    Node.BOTTOM_RIGHT = 3

    insert: (item) ->
      if @nodes.length
        index = @_findIndex item

        @nodes[index].insert item

        return

      @children.push item

      if !(@_depth >= @_maxDepth) and @children.length > @_maxChildren
        do @subdivide

        for i in [0..@children.length]
          @insert @children[i]

        @children.length = 0

    retrieve: (item) ->
      if @nodes.length
        index = @_findIndex item
        return @nodes[index].retrieve item

      return @children

    _findIndex: (item) ->
      left = !(item.x > @_bounds.x + @_bounds.width / 2)
      top = !(item.y > @_bounds.y + @_bounds.height / 2)

      index = Node.TOP_LEFT
      if left
        if !top
          index = Node.BOTTOM_LEFT
      else
        if top
          index = Node.TOP_RIGHT
        else
          index = Node.BOTTOM_RIGHT

      return index

    subdivide: ->
      depth = @_depth + 1
      boundsX = @_bounds.x
      boundsY = @_bounds.y

      bwh = (@_bounds.width / 2) or 0
      bhh = (@_bounds.height / 2) or 0

      boundsX_bwh = boundsX + bwh
      boundsY_bhh = boundsY + bhh

      @nodes[Node.TOP_LEFT] = new Node({
        x: boundsX
        y: boundsY
        width: bwh
        height: bhh
      }, depth, @_maxDepth, @_maxChildren)

      @nodes[Node.TOP_RIGHT] = new Node({
        x: boundsX_bwh
        y: boundsY
        width: bwh
        height: bhh
      }, depth, @_maxDepth, @_maxChildren)

      @nodes[Node.BOTTOM_LEFT] = new Node({
        x: boundsX
        y: boundsY_bhh
        width: bwh
        height: bhh
      }, depth, @_maxDepth, @_maxChildren)

      @nodes[Node.BOTTOM_RIGHT] = new Node({
        x: boundsX_bwh
        y: boundsY_bhh
        width: bwh
        height: bhh
      }, depth, @_maxDepth, @_maxChildren)

    clear: ->
      @children.length = 0

      for i in [0..@nodes.length]
        do @nodes[i].clear

      @nodes.length = 0

class BoundsNode
  constructor: (bounds, depth, maxChildren, maxDepth) ->
    Node.call @, bounds, depth, maxChildren, maxDepth
    @_stuckChildren = []

  BoundsNode.prototype = new Node()
  @_out = []

  insert: (item) ->
    if @nodes.length
      index = @_findIndex item
      node = @nodes[index]

      if item.x >= node._bounds.x and item.x + item.width <= node._bounds.x + node._bounds.width and item.y >= node._bounds.y and item.y + item.height <= node._bounds.y + node._bounds.height
        @nodes[index].insert item
      else
        @_stuckChildren.push item

      return

    @children.push item

    if !(@_depth >= @_maxDepth) and @children.length > @_maxChildren
      do @subdivide

      for i in [0..@children.length]
        @insert @children[i]

      @children.length = 0

  getChildren: ->
    return @children.concat @_stuckChildren

  retrieve: (item) ->
    out = @_out
    out.length = 0
    if @nodes.length
      index = @_findIndex item
      node = @nodes[index]

      if item.x >= node._bounds.x and item.x + item.width <= node._bounds.x + node._bounds.width and item.y >= node._bounds.y and item.y + item.height <= node._bounds.y + node._bounds.height
        out.push.apply out, @nodes[index].retrieve item
      else
        if item.x <= @nodes[Node.TOP_RIGHT]._bounds.x
          if item.y <= @nodes[Node.BOTTOM_LEFT]._bounds.y
            out.push.apply out, @nodes[Node.TOP_LEFT].getAllContent()

          if item.y + item.height > @nodes[Node.BOTTOM_LEFT]._bounds.y
            out.push.apply out, @nodes[Node.BOTTOM_LEFT].getAllContent()

        if item.x + item.width > this.nodes[Node.TOP_RIGHT]._bounds.x
          if item.y <= this.nodes[Node.BOTTOM_RIGHT]._bounds.y
            out.push.apply out, this.nodes[Node.TOP_RIGHT].getAllContent()

          if item.y + item.height > this.nodes[Node.BOTTOM_RIGHT]._bounds.y
            out.push.apply out, this.nodes[Node.BOTTOM_RIGHT].getAllContent()

    out.push.apply out, @_stuckChildren
    out.push.apply out, @children

    return out

  getAllContent: ->
    out = @_out

    if @nodes.length
      for i in [0..@nodes.length]
        do @nodes[i].getAllContent

    out.push.apply out, @_stuckChildren
    out.push.apply out, @children

    return out

  clear: ->
    @_stuckChildren.length = 0
    @children.length = 0

    return if not @nodes.length

    for i in [0..@nodes.length]
      do @nodes[i].clear

    @nodes.length = 0