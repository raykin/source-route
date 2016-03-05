# experimental
module SourceRoute
  # is it valuable to transfer trace chain to complex tree object
  # and then covert it to hash then to json
  class CallTraceNode
    attr_accessor :node, :children

    def initialize(trace)
      @node = trace
    end
  end

  class CallTraceTree
    # data format looks like
    # [rootnode1, rootnode2, rootnode3, ...]
    # for rootnode1
    # rootnode1.children return
    # [node1, node2, node3, ...]
    # and again and again
    attr_accessor :data

    def initialize(root)
      @data = []
      @data.insert_node if room
      # @data = {node: root, children: []}
    end

    def look_up(node_id)

    end

    def insert_children(children)

    end

    def transform_from(chain)

    end

    def insert_node(trace)
      if trace.parent_id

      else
        @data.push(CallTraceNode.new(trace))
      end
    end
  end

  # delegate to Array
  # data format as
  # [{nodeid: 0, children: [{nodeid: 1, children: [3, 4]} ...]},
  #  {nodeid: 5, children: [ ...]},
  #  ...
  # ]
  class CallTreeData
    attr_accessor :data

    def initialize(root = nil)
      @data = []
      @data.push(root) if root
    end

    # root node format should be {nodeid: 5, children: [6, 7, 8, 9]}
    #
    def insert_root(root_node)
      @data.push(root_node.as_tree)
    end

    def insert_node(node)
      locate(node).map! do |origin|
        origin == node.order_id ? node.as_tree : origin
      end
    end

    def locate(node)
      query = @data
      node.parent_ids.each do |pid|
        query = query.find do |ele|
          ele[:nodeid] == pid if ele.is_a? Hash
        end.fetch(:children)
      end
      query
    end

  end # END CallTreeData
end
