module DBHelpers
  module_function
  def load_seeds
    Progress.create(
      [
        {name: Progress.UNASSIGNED},
        {name: Progress.NO_RESPONSE},
        {name: Progress.REJECTED},
        {name: Progress.DRAFT_PENDING},
        {name: Progress.WITH_POD},
        {name: Progress.POD_QUERY},
        {name: Progress.POD_CLEARED},
        {name: Progress.WITH_MINISTER},
        {name: Progress.MINISTERIAL_QUERY},
        {name: Progress.MINISTER_CLEARED},
        {name: Progress.ANSWERED},
        {name: Progress.TRANSFERRED_OUT}
      ])
  end
end
