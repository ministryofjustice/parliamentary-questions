def progress_seed
  let!(:accepted) { create(:progress, name: Progress.ALLOCATED_ACCEPTED) }
  let!(:pending) { create(:progress, name: Progress.ALLOCATED_PENDING) }
  let!(:unallocated) { create(:progress, name: Progress.UNALLOCATED) }
  let!(:rejected) { create(:progress, name: Progress.REJECTED) }
  let!(:transfer) { create(:progress, name: Progress.TRANSFER) }
  let!(:draft_pending) { create(:progress, name: Progress.DRAFT_PENDING) }
  let!(:pod_waiting) { create(:progress, name: Progress.POD_WAITING) }
  let!(:pod_query) { create(:progress, name: Progress.POD_QUERY) }
  let!(:pod_cleared) { create(:progress, name: Progress.POD_CLEARED) }
  let!(:minister_waiting) { create(:progress, name: Progress.MINISTER_WAITING) }
  let!(:minister_query) { create(:progress, name: Progress.MINISTER_QUERY) }
  let!(:minister_cleared) { create(:progress, name: Progress.MINISTER_CLEARED) }
  let!(:answered) { create(:progress, name: Progress.ANSWERED) }
  let!(:transferred_out) { create(:progress, name: Progress.TRANSFERRED_OUT) }
end