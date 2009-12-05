require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::Hash do
  def xml(&block)
    Nokogiri::XML::Builder.new(&block).doc
  end

  def assert_node_hash_equal(node1, node2)
    Diffaroo::Hash.node_hash(node1).should == Diffaroo::Hash.node_hash(node2)
  end

  def assert_node_hash_not_equal(node1, node2)
    Diffaroo::Hash.node_hash(node1).should_not == Diffaroo::Hash.node_hash(node2)
  end

  describe ".node_hash" do
    context "API" do
      it "raises an error if passed a non-Node" do
        proc { Diffaroo::Hash.node_hash(nil) }.should raise_error(ArgumentError)
      end

      it "raises an error if passed a non-text, non-element" do
        doc = xml { root { a1("foo" => "bar") } }
        attr = doc.at_css("a1").attributes.first.last
        proc { Diffaroo::Hash.node_hash(attr) }.should raise_error(ArgumentError) 
      end
    end

    context "XML" do
      context "identical text nodes" do
        it "hashes equally" do
          doc = xml { root {
              span "hello"
              span "hello"
            } }
          assert_node_hash_equal(*doc.css("span").collect { |n| n.children.first })
        end
      end

      context "different text nodes" do
        it "hashes differently" do
          doc = xml { root {
              span "hello"
              span "goodbye"
            } }
          assert_node_hash_not_equal(*doc.css("span").collect { |n| n.children.first })
        end
      end

      context "elements with same name (with no attributes and no content)" do
        it "hashes equally" do
          doc = xml { root { a1 ; a1 } }
          assert_node_hash_equal(*doc.css("a1"))
        end
      end

      context "elements with different names" do
        it "hashes differently" do
          doc = xml { root { a1 ; a2 } }
          assert_node_hash_not_equal doc.at_css("a1"), doc.at_css("a2")
        end
      end

      context "same elements in different docs" do
        it "hashes equally" do
          doc1 = xml { root { a1 } }
          doc2 = xml { root { a1 } }
          assert_node_hash_equal doc1.at_css("a1"), doc2.at_css("a1")
        end
      end

      context "elements with same name and content (with no attributes)" do
        context "and content is the same" do
          it "hashes equally" do
            doc = xml { root {
                a1 "hello"
                a1 "hello"
              } }
            assert_node_hash_equal(*doc.css("a1"))
          end
        end

        context "and content is not the same" do
          it "hashes equally" do
            doc = xml { root {
                a1 "hello"
                a1 "goodbye"
              } }
            assert_node_hash_not_equal(*doc.css("a1"))
          end
        end
      end

      context "elements with same name and children (with no attributes)" do
        context "and children are in the same order" do
          it "hashes equally" do
            doc = xml { root {
                a1 { b1 ; b2 }
                a1 { b1 ; b2 }
              } }
            assert_node_hash_equal(*doc.css("a1"))
          end
        end

        context "and children are not in the same order" do
          it "hashes differently" do
            doc = xml { root {
                a1 { b1 ; b2 }
                a1 { b2 ; b1 }
              } }
            assert_node_hash_not_equal(*doc.css("a1"))
          end
        end
      end

      context "elements with same name and same attributes (with no content)" do
        it "hashes equally" do
          doc = xml { root {
              a1("foo" => "bar", "bazz" => "quux")
              a1("foo" => "bar", "bazz" => "quux")
            } }
          assert_node_hash_equal(*doc.css("a1"))
        end
      end

      context "elements with same name and different attributes (with no content)" do
        it "hashes differently" do
          doc = xml { root {
              a1("foo" => "bar", "bazz" => "quux")
              a1("foo" => "123", "bazz" => "456")
            } }
          assert_node_hash_not_equal(*doc.css("a1"))
        end
      end

      context "attributes reverse-engineered to be similar" do
        it "hashes differently" do
          doc = xml { root {
              a1("foo" => "bar#{Diffaroo::Hash::SEP}quux")
              a1("foo#{Diffaroo::Hash::SEP}bar" => "quux")
            } }
          assert_node_hash_not_equal(*doc.css("a1"))
        end
      end
    end

    context "HTML" do
      it "write some HTML tests"
    end
  end

  describe ".document_hash" do
    it "hashes each node only once" do
      doc = xml { root {
          a1 {
            b1 {
              c1 "hello"
            }
          }
        } }
      node = doc.at_css "c1"
      mock.proxy(Diffaroo::Hash).node_hash(anything).times(5)
      Diffaroo::Hash.document_hash(doc)
    end
  end
end