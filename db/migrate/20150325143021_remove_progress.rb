class RemoveProgress < ActiveRecord::Migration
  def up
    add_column(:pqs, :state, :string, default: 'unassigned')
    add_column(:pqs, :state_weight, :integer, default: 0)

    Pq.find_in_batches.each do |pq, _|
      state = progress2state(pq.progress && pq.progress.name)
      pq.update(state: state)
    end
  end

  def down
  end

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
    when Progress.POD_QUERY
      'pod_query'
    when Progress.WITH_POD
      'with_pod'
    when Progress.WITH_MINISTER
      'with_minister'
    when Progress.MINISTERIAL_QUERY
      'ministerial_query'
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
