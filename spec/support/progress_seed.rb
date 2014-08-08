def progress_seed
  let!(:unassigned) { create(:progress, name: Progress.UNASSIGNED) }
  let!(:accepted) { create(:progress, name: Progress.ACCEPTED) }
  let!(:no_response) { create(:progress, name: Progress.NO_RESPONSE) }
  let!(:rejected) { create(:progress, name: Progress.REJECTED) }
  let!(:draft_pending) { create(:progress, name: Progress.DRAFT_PENDING) }
  let!(:with_pod) { create(:progress, name: Progress.WITH_POD) }
  let!(:pod_query) { create(:progress, name: Progress.POD_QUERY) }
  let!(:pod_cleared) { create(:progress, name: Progress.POD_CLEARED) }
  let!(:with_minister) { create(:progress, name: Progress.WITH_MINISTER) }
  let!(:ministerial_query) { create(:progress, name: Progress.MINISTERIAL_QUERY) }
  let!(:minister_cleared) { create(:progress, name: Progress.MINISTER_CLEARED) }
  let!(:answered) { create(:progress, name: Progress.ANSWERED) }
  let!(:transferred_out) { create(:progress, name: Progress.TRANSFERRED_OUT) }
end