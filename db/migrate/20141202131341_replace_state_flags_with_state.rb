class ReplaceStateFlagsWithState < ActiveRecord::Migration
  PROGRESSES = [
    nil,
    :unassigned,
    :no_response,
    :rejected,
    :draft_pending,
    :with_pod,
    :pod_query,
    :pod_cleared,
    :with_minister,
    :ministerial_query,
    :minister_cleared,
    :answered,
    :transferred_out
  ]

  def state_index(state)
    QuestionStateMachine::STATES.index(state)
  end

  def flag_to_state(flag, state = nil)
    execute("UPDATE pqs SET state=#{state_index(state || flag)} WHERE #{flag} = true")
  end

  def progress_to_state(progress, state)
    progress = PROGRESSES.index(progress)
    execute("UPDATE pqs SET state=#{state_index(state)} WHERE progress_id = #{progress}")
  end

  def up
    add_column :pqs, :state, :integer

    # Order is important
    progress_to_state :unassigned, :with_finance
    flag_to_state :seen_by_finance, :uncommissioned
    progress_to_state :no_response, :with_officers
    progress_to_state :rejected, :rejected
    progress_to_state :draft_pending, :draft_pending
    progress_to_state :with_pod, :with_pod
    progress_to_state :pod_query, :with_pod
    progress_to_state :pod_cleared, :pod_cleared
    progress_to_state :with_minister, :with_answering_minister
    progress_to_state :ministerial_query, :with_answering_minister
    progress_to_state :answered, :answered
    progress_to_state :transferred_out, :transferred_out

    execute("UPDATE pqs SET state=#{state_index(:cleared)}
      WHERE (cleared_by_policy_minister IS NOT NULL OR policy_minister_id IS NULL)
      AND cleared_by_answering_minister IS NOT NULL")

    execute("UPDATE pqs SET state=#{state_index(:with_answering_minister)}
      WHERE (cleared_by_policy_minister IS NOT NULL OR policy_minister_id IS NULL)
      AND cleared_by_answering_minister IS NULL")

    change_table :pqs do |t|
      # replaced with state
      t.remove :seen_by_finance
      t.remove :progress_id

      # no longer needed
      t.remove :i_will_write_estimate
      t.remove :transferred
      t.remove :pod_waiting
      t.remove :pod_query_flag
      t.remove :answering_minister_query
      t.remove :policy_minister_query

      # question.question looks ugly
      t.rename :question, :text
    end

    drop_table :progresses
  end
end
