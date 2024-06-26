module PqState
  # For all nodes in a state transition graph, validates that there
  # exists a path leading to the final state.
  #
  # Note:
  #
  # While independent from the PQ state-machine logic itself,
  # this class provides a mechanism to verify that a given state transitions
  # graph is structurally sound and has not 'dead-ends'.
  #
  class Validator
    def initialize(transitions, final_states)
      @transitions    = transitions
      @final_states   = final_states
      @max_iterations = @transitions.size * 3
    end

    def check_consistent_state_graph!
      dead_ends =
        remove_cyclic_transitions(@transitions).select do |t|
          has_dead_end?(t.state_from)
        end
      raise InconsistentStateGraph.new(@final_states, dead_ends) unless dead_ends.empty?
    end

  private

    def has_dead_end?(state_from, visited = [])
      t = @transitions.find { |pq| pq.state_from == state_from }
      t = next_transition(t) if t && is_cyclic_link?(visited, t)

      return true unless t

      case [@final_states.include?(t.state_to), visited.size < @max_iterations]
      when [true, true]
        false
      when [false, true]
        has_dead_end?(t.state_to, visited + [t])
      else
        true
      end
    end

    def next_transition(transition)
      @transitions.find do |pq|
        pq != transition && pq.state_from == transition.state_to && pq.state_to != transition.state_from
      end
    end

    # Discards cyclic links from the supplied transitions list
    #
    # Given a transition graph like:
    #
    #     [a -> b, b -> c, c -> d, c -> b, d -> e]
    #                              ^^^
    #                               Cyclic link
    #
    # It will return:
    #
    #     [a -> b, b -> c, c -> d, d -> e]
    #
    def remove_cyclic_transitions(transitions)
      transitions.reduce([]) do |acc, t|
        if is_cyclic_link?(acc, t)
          acc
        else
          acc << t
        end
      end
    end

    def is_cyclic_link?(transitions, second_transition)
      transitions.any? { |t| t.to_pair.reverse == second_transition.to_pair }
    end

    class InconsistentStateGraph < StandardError
      def initialize(final_states, dead_ends) # rubocop:disable Lint/MissingSuper
        @final_states = final_states
        @dead_ends    = dead_ends
      end

      def message
        "The following transitions do not progress to either of the final states (i.e. #{@final_states.join(', ')}): #{list_dead_ends}"
      end

    private

      def list_dead_ends
        @dead_ends.map { |t| "#{t.state_from} -> #{t.state_to}" }.join(", ")
      end
    end
  end
end
