class RemoveProgress < ActiveRecord::Migration[5.0]
  def up
    change_table :pqs, bulk: true do |t|
      t.string  :state,        default: 'unassigned'
      t.integer :state_weight, default: 0
    end

    Pq.find_in_batches.each do |pq, _|
      state = progress2state(pq.progress && pq.progress.name)
      pq.update(state: state)
    end
  end

  def down; end

  private

  def progress2state(progress_name)
    case progress_name
    when Progress.UNASSIGNED
      'unassigned'
    when Progress.REJECTED
      'rejected'
    when Progress.NO_RESPONSE
      'no_response'
    when Progress.DRAFT_PENDING
      'draft_pending'
    when Progress.WITH_POD
      'with_pod'
    when Progress.WITH_MINISTER
      'with_minister'
    when Progress.MINISTER_CLEARED
      'minister_cleared'
    when Progress.ANSWERED
      'answered'
    when Progress.TRANSFERRED_OUT
      'transferred_out'
    else
      raise ArgumentError, "db:migrate: Unknown progress name #{progress_name}"
    end
  end
end
