module Lorax
  class MatchSet
    attr_accessor :signature1, :signature2

    def initialize(doc1, doc2, dependency_injection={})
      @document1  = doc1
      @document2  = doc2
      @signature1 = dependency_injection[:match_set_signature1] || Lorax::Signature.new(@document1.root)
      @signature2 = dependency_injection[:match_set_signature2] || Lorax::Signature.new(@document2.root)
      @matches    = {}
    end

    def match(node)
      @matches[node]
    end

    def matches
      puts "MIKE: #{__FILE__}:#{__LINE__} REMOVE ME THIS IS FOR DEBUGGING ONLY"
      @matches.values.uniq.collect {|m| [m.pair.first.path, m.pair.last.path, m.perfect?]}.sort
    end

    def add(match)
      match.pair.each { |node| @matches[node] = match }
    end

    def to_delta_set
      DeltaSetGenerator.generate_delta_set(self)
    end
  end
end
