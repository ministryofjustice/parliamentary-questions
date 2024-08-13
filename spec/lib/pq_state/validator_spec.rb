require "rails_helper"

describe PqState::Validator do
  def t(from, to)
    PqState::Transition.new(from, to, proc { |_| true })
  end

  describe "#check_consistent_state_graph!" do
    # Invalid Graph with dead-end c
    #
    # a -> b -> c
    #      b -> d -> e
    #
    context "when the transition graph has dead ends" do
      it "raises an InconsistentStateGraph error" do
        validator = described_class.new([
          t("a", "b"),
          # <= dead end!
          t("b", "c"),
          t("b", "d"),
          t("d", "e"),
        ],
                                        %w[e])

        expect {
          validator.check_consistent_state_graph!
        }.to raise_error(PqState::Validator::InconsistentStateGraph, /b -> c/)
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
          t("a", "b"),
          t("b", "c"),
          t("b", "d"),
          t("c", "b"),
          t("d", "e"),
          t("e", "f"),
          t("f", "g"),
          t("e", "g"),
          t("g", "h"),
          t("h", "i"),
          t("i", "l"),
          t("h", "l"),
          t("l", "m"),
        ]

        x_transitions =
          %w[
            a b d e g h l m
          ].product(%w[x]).map { |from, to| t(from, to) }

        expect {
          described_class.new(
            transitions + x_transitions,
            %w[m x],
          ).check_consistent_state_graph!
        }.not_to raise_error
      end
    end
  end
end
