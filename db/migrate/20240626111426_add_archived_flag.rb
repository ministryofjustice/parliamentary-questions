class AddArchivedFlag < ActiveRecord::Migration[7.1]
  def change
    add_column :pqs, :archived, :boolean, default: false

    # Set previously archived PQs as archived
    Pq.where("uin SIMILAR TO '(#|[ESCAPE *]|$|^|~|£|a|b)%'").update_all("archived = true")
  end
end
