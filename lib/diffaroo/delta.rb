module Diffaroo
  class Delta
    class NodeNotFoundError < RuntimeError ; end

    def apply!(document)
      raise NotImplementedError, self.class.to_s
    end

    def inspect
      "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{descriptor.inspect}>"
    end

    private

    def insert_node(node, parent, position)
      children = parent.children
      if children.empty? || position >= children.length
        parent << node.dup
      else
        children[position].add_previous_sibling(node.dup)
      end
    end
  end
end

require "diffaroo/delta/insert_delta"
require "diffaroo/delta/modify_delta"
require "diffaroo/delta/delete_delta"
