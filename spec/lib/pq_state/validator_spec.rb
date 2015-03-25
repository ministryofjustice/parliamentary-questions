require 'spec_helper'

describe PQState::Validator do
  def t(from, to)
    PQState::Transition.new(from, to, proc { |_| true })
  end

  describe "#check_consistent_state_graph!" do
    # Invalid Graph with dead-end c
    #
    # a -> b -> c
    #      b -> d -> e
    #
    context "when the transition graph has dead ends" do
      it "raises an InconsistentStateGraph error" do
        validator = PQState::Validator.new([
          t('a', 'b'),
          t('b', 'c'), # <= dead end!
          t('b', 'd'),
          t('d', 'e'),
        ], ['e'])

        expect {
          validator.check_consistent_state_graph!
        }.to raise_error(PQState::Validator::InconsistentStateGraph, /b -> c/)
      end
    end

    context "when the transition graph moves backward without dead ends" do
      # Valid Graph resambling the one of PQ Tracker
      #
      #                                                -> x
      # a -> b -> c -> d -> e -> f -> g -> h -> i -> l -> m -> x
      #      b <- c         e      -> g    h      -> l
      #
      it "raises no error" do
        transitions = [
          t('a', 'b'),
          t('b', 'c'),
          t('b', 'd'),
          t('c', 'b'),
          t('d', 'e'),
          t('e', 'f'),
          t('f', 'g'),
          t('e', 'g'),
          t('g', 'h'),
          t('h', 'i'),
          t('i', 'l'),
          t('h', 'l'),
          t('l', 'm')
        ]

        x_transitions = [
          'a', 'b', 'd', 'e', 'g', 'h', 'l', 'm'
        ].product(['x']).map { |from, to| t(from, to) }

        PQState::Validator.new(
          transitions + x_transitions,
          ['m', 'x']
        ).check_consistent_state_graph!
      end
    end
  end
end
