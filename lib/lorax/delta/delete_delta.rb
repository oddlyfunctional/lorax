module Lorax
  class DeleteDelta < Delta
    attr_accessor :node, :xpath, :position

    def initialize(node, xpath, position)
      @node = node
      @xpath = xpath
      @position = position
    end

    def apply!(document)
      target = document.at_xpath(node.path)
      parent = document.at_xpath(xpath)

      raise NodeNotFoundError, node.path unless target
      raise NodeNotFoundError, xpath unless parent

      target.unlink

      new_node = Nokogiri::XML("<del></del>").child
      new_node.add_child(node.dup)
      insert_node(new_node, parent, position)
    end

    def descriptor
      [:delete, {:xpath => node.path, :content => node.to_s}]
    end

    def to_s
      response = []
      response << "--- #{node.path}"
      response << "+++"
      response << context_before(node)
      response << node.to_html.gsub(/^/,'- ').strip
      response << context_after(node)
      response.join("\n")
    end
  end
end
