module Lorax
  class ModifyDelta < Delta
    attr_accessor :node1, :xpath1, :position1, :node2, :xpath2

    def initialize(node1, node2)
      @node1 = node1
      @node2 = node2
    end

    def apply!(doc)
      target1 = doc.at_xpath(node1.path)
      parent1 = doc.at_xpath(node1.parent.path)
      raise NodeNotFoundError, node1.path unless target1
      raise NodeNotFoundError, xpath unless parent1

      target1.unlink

      parent2 = doc.at_xpath(node2.parent.path)
      raise NodeNotFoundError, xpath unless parent2

      new_node1 = Nokogiri::XML("<del></del>").child
      new_node1.add_child(node1.dup)

      new_node2 = Nokogiri::XML("<ins></ins>").child
      new_node2.add_child(node2.dup)

      insert_node(new_node1, parent1, node1.parent.children.index(node1))
      insert_node(new_node2, parent2, node2.parent.children.index(node2))
    end

    def descriptor
      if node1.text? || node1.type == Nokogiri::XML::Node::CDATA_SECTION_NODE
        [:modify, {:old => {:xpath => node1.path, :content => node1.to_s},
                   :new => {:xpath => node2.path, :content => node2.to_s}}]
      else
        [:modify, {:old => {:xpath => node1.path, :name => node1.name, :attributes => node1.attributes.map{|k,v| [k, v.value]}},
                   :new => {:xpath => node2.path, :name => node2.name, :attributes => node2.attributes.map{|k,v| [k, v.value]}}}]
      end
    end

    def to_s
      response = []
      response << "--- #{node1.path}"
      response << "+++ #{node2.path}"
      response << context_before(node2)

      response << node1.to_html.gsub(/^/,'- ').strip
      response << node2.to_html.gsub(/^/,'+ ').strip

      response << context_after(node2)
      response.join("\n")
    end

    private

    def attributes_hash(node)
      # lame.
      node.attributes.inject({}) { |hash, attr| hash[attr.first] = attr.last.value ; hash }
    end
  end
end
