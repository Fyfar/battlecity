// Generated by CoffeeScript 1.9.1
(function() {
  var BoundsNode, Node, QuadTree;

  QuadTree = (function() {
    function QuadTree(bounds, pointQuad, maxDepth, maxChildren) {
      var node;
      if (pointQuad) {
        node = new Node(bounds, 0, maxDepth, maxChildren);
      } else {
        node = new BoundsNode(bounds, 0, maxDepth, maxChildren);
      }
      this.root = node;
    }

    QuadTree.prototype.insert = function(item) {
      var i, j, len, results;
      if (item instanceof Array) {
        results = [];
        for (j = 0, len = item.length; j < len; j++) {
          i = item[j];
          results.push(this.root.insert(i));
        }
        return results;
      } else {
        return this.root.insert(item);
      }
    };

    QuadTree.prototype.clear = function() {
      return this.root.clear();
    };

    QuadTree.prototype.retrieve = function(item) {
      return this.root.retrieve(item).slice(0);
    };

    return QuadTree;

  })();

  Node = (function() {
    function Node(bounds, depth, maxDepth, maxChildren) {
      if (depth == null) {
        depth = 0;
      }
      if (maxDepth == null) {
        maxDepth = 4;
      }
      if (maxChildren == null) {
        maxChildren = 4;
      }
      this._bounds = bounds;
      this.children = [];
      this.nodes = [];
      this._maxChildren = maxChildren;
      this._maxDepth = maxDepth;
      this._depth = depth;
      Node.TOP_LEFT = 0;
      Node.TOP_RIGHT = 1;
      Node.BOTTOM_LEFT = 2;
      Node.BOTTOM_RIGHT = 3;
      ({
        insert: function(item) {
          var i, index, j, ref;
          if (this.nodes.length) {
            index = this._findIndex(item);
            this.nodes[index].insert(item);
            return;
          }
          this.children.push(item);
          if (!(this._depth >= this._maxDepth) && this.children.length > this._maxChildren) {
            this.subdivide();
            for (i = j = 0, ref = this.children.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
              this.insert(this.children[i]);
            }
            return this.children.length = 0;
          }
        },
        retrieve: function(item) {
          var index;
          if (this.nodes.length) {
            index = this._findIndex(item);
            return this.nodes[index].retrieve(item);
          }
          return this.children;
        },
        _findIndex: function(item) {
          var index, left, top;
          left = !(item.x > this._bounds.x + this._bounds.width / 2);
          top = !(item.y > this._bounds.y + this._bounds.height / 2);
          index = Node.TOP_LEFT;
          if (left) {
            if (!top) {
              index = Node.BOTTOM_LEFT;
            }
          } else {
            if (top) {
              index = Node.TOP_RIGHT;
            } else {
              index = Node.BOTTOM_RIGHT;
            }
          }
          return index;
        },
        subdivide: function() {
          var bhh, boundsX, boundsX_bwh, boundsY, boundsY_bhh, bwh;
          depth = this._depth + 1;
          boundsX = this._bounds.x;
          boundsY = this._bounds.y;
          bwh = (this._bounds.width / 2) || 0;
          bhh = (this._bounds.height / 2) || 0;
          boundsX_bwh = boundsX + bwh;
          boundsY_bhh = boundsY + bhh;
          this.nodes[Node.TOP_LEFT] = new Node({
            x: boundsX,
            y: boundsY,
            width: bwh,
            height: bhh
          }, depth, this._maxDepth, this._maxChildren);
          this.nodes[Node.TOP_RIGHT] = new Node({
            x: boundsX_bwh,
            y: boundsY,
            width: bwh,
            height: bhh
          }, depth, this._maxDepth, this._maxChildren);
          this.nodes[Node.BOTTOM_LEFT] = new Node({
            x: boundsX,
            y: boundsY_bhh,
            width: bwh,
            height: bhh
          }, depth, this._maxDepth, this._maxChildren);
          return this.nodes[Node.BOTTOM_RIGHT] = new Node({
            x: boundsX_bwh,
            y: boundsY_bhh,
            width: bwh,
            height: bhh
          }, depth, this._maxDepth, this._maxChildren);
        },
        clear: function() {
          var i, j, ref;
          this.children.length = 0;
          for (i = j = 0, ref = this.nodes.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
            this.nodes[i].clear();
          }
          return this.nodes.length = 0;
        }
      });
    }

    return Node;

  })();

  BoundsNode = (function() {
    function BoundsNode(bounds, depth, maxChildren, maxDepth) {
      Node.call(this, bounds, depth, maxChildren, maxDepth);
      this._stuckChildren = [];
    }

    BoundsNode.prototype = new Node();

    BoundsNode._out = [];

    BoundsNode.prototype.insert = function(item) {
      var i, index, j, node, ref;
      if (this.nodes.length) {
        index = this._findIndex(item);
        node = this.nodes[index];
        if (item.x >= node._bounds.x && item.x + item.width <= node._bounds.x + node._bounds.width && item.y >= node._bounds.y && item.y + item.height <= node._bounds.y + node._bounds.height) {
          this.nodes[index].insert(item);
        } else {
          this._stuckChildren.push(item);
        }
        return;
      }
      this.children.push(item);
      if (!(this._depth >= this._maxDepth) && this.children.length > this._maxChildren) {
        this.subdivide();
        for (i = j = 0, ref = this.children.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          this.insert(this.children[i]);
        }
        return this.children.length = 0;
      }
    };

    BoundsNode.prototype.getChildren = function() {
      return this.children.concat(this._stuckChildren);
    };

    BoundsNode.prototype.retrieve = function(item) {
      var index, node, out;
      out = this._out;
      out.length = 0;
      if (this.nodes.length) {
        index = this._findIndex(item);
        node = this.nodes[index];
        if (item.x >= node._bounds.x && item.x + item.width <= node._bounds.x + node._bounds.width && item.y >= node._bounds.y && item.y + item.height <= node._bounds.y + node._bounds.height) {
          out.push.apply(out, this.nodes[index].retrieve(item));
        } else {
          if (item.x <= this.nodes[Node.TOP_RIGHT]._bounds.x) {
            if (item.y <= this.nodes[Node.BOTTOM_LEFT]._bounds.y) {
              out.push.apply(out, this.nodes[Node.TOP_LEFT].getAllContent());
            }
            if (item.y + item.height > this.nodes[Node.BOTTOM_LEFT]._bounds.y) {
              out.push.apply(out, this.nodes[Node.BOTTOM_LEFT].getAllContent());
            }
          }
          if (item.x + item.width > this.nodes[Node.TOP_RIGHT]._bounds.x) {
            if (item.y <= this.nodes[Node.BOTTOM_RIGHT]._bounds.y) {
              out.push.apply(out, this.nodes[Node.TOP_RIGHT].getAllContent());
            }
            if (item.y + item.height > this.nodes[Node.BOTTOM_RIGHT]._bounds.y) {
              out.push.apply(out, this.nodes[Node.BOTTOM_RIGHT].getAllContent());
            }
          }
        }
      }
      out.push.apply(out, this._stuckChildren);
      out.push.apply(out, this.children);
      return out;
    };

    BoundsNode.prototype.getAllContent = function() {
      var i, j, out, ref;
      out = this._out;
      if (this.nodes.length) {
        for (i = j = 0, ref = this.nodes.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          this.nodes[i].getAllContent();
        }
      }
      out.push.apply(out, this._stuckChildren);
      out.push.apply(out, this.children);
      return out;
    };

    BoundsNode.prototype.clear = function() {
      var i, j, ref;
      this._stuckChildren.length = 0;
      this.children.length = 0;
      if (!this.nodes.length) {
        return;
      }
      for (i = j = 0, ref = this.nodes.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        this.nodes[i].clear();
      }
      return this.nodes.length = 0;
    };

    return BoundsNode;

  })();

}).call(this);

//# sourceMappingURL=QuadTree.js.map