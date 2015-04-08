module PQState
  class Transition
    attr_reader :state_from, :state_to

    def initialize(state_from, state_to, block)
      @state_from = state_from
      @state_to   = state_to
      @block      = block
    end

    def valid?(pq)
      @block.call(pq)
    end

    def to_pair
      [state_from, state_to]
    end

    def to_s
      "#{state_from} -> #{state_to}"
    end

    def self.factory(state_froms, state_tos, &block)
      state_froms.product(state_tos).map do | from, to|
        new(from, to, block)
      end
    end
  end
end
