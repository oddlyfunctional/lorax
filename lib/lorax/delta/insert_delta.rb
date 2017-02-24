module Lorax
  class InsertDelta < Delta
    attr_accessor :node, :xpath, :position

    def initialize(node, xpath, position)
      @node     = node
      @xpath    = xpath
      @position = position
    end

    def apply!(document)
      # TODO: patch nokogiri to make inserting node copies efficient
      parent = document.at_xpath(node.parent.path)
      raise NodeNotFoundError, xpath unless parent

      new_node = Nokogiri::XML("<ins></ins>").child
      new_node.add_child(node.dup)
      insert_node(new_node, parent, node.parent.children.index(node))
    end

    def descriptor
      [:insert, {:xpath => xpath, :position => position, :content => node.to_s}]
    end

    def to_s
      response = []
      response << "---"
      response << "+++ #{node.path}"
      response << context_before(node)
      response << node.to_html.gsub(/^/,'+ ').strip
      response << context_after(node)
      response.join("\n")
    end
  end
end
