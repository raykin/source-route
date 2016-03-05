require 'test_helper'

class MockNode
  attr_accessor :parent_ids, :direct_child_order_ids, :order_id

  def as_tree
    {nodeid: order_id, children: direct_child_order_ids}
  end
end

module SourceRoute
  class CallTraceTreeTest < Minitest::Test

    def setup
      @tree = CallTreeData.new(nodeid: 0, children: [2, 3, 4])
    end

    def create_node3
      node = MockNode.new
      node.parent_ids = [0]
      node.order_id = 3
      node.direct_child_order_ids = [7, 8, 9]
      node
    end

    def create_node7
      node = MockNode.new
      node.order_id = 7
      node.parent_ids = [0, 3]
      node.direct_child_order_ids = [11, 12, 15]
      node
    end

    def test_insert_node_into_trace_tree
      assert_equal [{nodeid: 0, children: [2,3,4]}], @tree.data
      node = create_node3
      @tree.insert_node(node)
      assert_equal [{nodeid: 0, children: [2, {nodeid: 3, children: [7, 8, 9]}, 4]}], @tree.data
    end

    def test_insert_node_into_child_node
      @tree.insert_node(create_node3)
      @tree.insert_node(create_node7)
      assert_equal([{nodeid: 0, children: [2,
                                           {nodeid: 3, children: [
                                              {nodeid: 7, children: [11, 12, 15]}, 8, 9
                                            ]}, 4
                                          ]}
                   ], @tree.data)
    end
  end
end
