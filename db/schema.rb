# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_16_133636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_officers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "deleted", default: false
    t.string "phone"
    t.integer "deputy_director_id"
    t.integer "press_desk_id"
    t.string "group_email"
    t.index ["email", "deputy_director_id"], name: "index_action_officers_on_email_and_deputy_director_id", unique: true
  end

  create_table "action_officers_pqs", id: :serial, force: :cascade do |t|
    t.integer "pq_id", null: false
    t.integer "action_officer_id", null: false
    t.text "reason"
    t.string "reason_option"
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.integer "reminder_accept", default: 0
    t.integer "reminder_draft", default: 0
    t.string "response", default: "awaiting"
  end

  create_table "archives", force: :cascade do |t|
    t.string "prefix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prefix"], name: "index_archives_on_prefix", unique: true
  end

  create_table "deputy_directors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "division_id"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "directorates", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "divisions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "directorate_id"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "early_bird_members", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "deleted"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "early_bird_organisers", force: :cascade do |t|
    t.date "date_from"
    t.date "date_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.string "mailer"
    t.string "method"
    t.text "params"
    t.text "from"
    t.text "to"
    t.text "cc"
    t.text "reply_to"
    t.datetime "send_attempted_at", precision: nil
    t.datetime "sent_at", precision: nil
    t.integer "num_send_attempts", default: 0
    t.string "status", default: "new"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "import_logs", id: :serial, force: :cascade do |t|
    t.string "log_type"
    t.text "msg"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "minister_contacts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "minister_id"
    t.boolean "deleted", default: false
  end

  create_table "ministers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "member_id"
  end

  create_table "ogds", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "acronym"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pqa_import_runs", id: :serial, force: :cascade do |t|
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.string "status"
    t.integer "num_created"
    t.integer "num_updated"
    t.text "error_messages"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pqs", id: :serial, force: :cascade do |t|
    t.integer "house_id"
    t.integer "raising_member_id"
    t.datetime "tabled_date", precision: nil
    t.datetime "response_due", precision: nil
    t.text "question"
    t.string "answer"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uin"
    t.string "member_name"
    t.string "member_constituency"
    t.string "house_name"
    t.date "date_for_answer"
    t.boolean "registered_interest"
    t.datetime "internal_deadline", precision: nil
    t.string "question_type"
    t.integer "minister_id"
    t.integer "policy_minister_id"
    t.integer "progress_id"
    t.datetime "draft_answer_received", precision: nil
    t.datetime "holding_reply", precision: nil
    t.string "preview_url"
    t.datetime "pod_waiting", precision: nil
    t.datetime "pod_clearance", precision: nil
    t.boolean "transferred"
    t.string "question_status"
    t.datetime "sent_to_policy_minister", precision: nil
    t.datetime "cleared_by_policy_minister", precision: nil
    t.datetime "sent_to_answering_minister", precision: nil
    t.datetime "cleared_by_answering_minister", precision: nil
    t.datetime "answer_submitted", precision: nil
    t.string "final_response_info_released"
    t.integer "transfer_out_ogd_id"
    t.datetime "transfer_out_date", precision: nil
    t.integer "directorate_id"
    t.integer "original_division_id"
    t.integer "transfer_in_ogd_id"
    t.datetime "transfer_in_date", precision: nil
    t.string "state", default: "unassigned"
    t.integer "state_weight", default: 0
    t.boolean "archived", default: false
    t.index "date_part('day'::text, (date_for_answer)::timestamp without time zone)", name: "days_from_date_for_answer"
    t.index ["date_for_answer"], name: "index_pqs_on_date_for_answer"
    t.index ["internal_deadline"], name: "index_pqs_on_internal_deadline"
    t.index ["minister_id"], name: "index_pqs_on_minister_id"
    t.index ["state"], name: "index_pqs_on_state"
    t.index ["state_weight"], name: "index_pqs_on_state_weight"
    t.index ["uin"], name: "index_pqs_on_uin", unique: true
    t.index ["updated_at"], name: "index_pqs_on_updated_at"
  end

  create_table "press_desks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "press_officers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "press_desk_id"
    t.boolean "deleted", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "progresses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "progress_order"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.string "path"
    t.string "token_digest"
    t.datetime "expire", precision: nil
    t.string "entity"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "acknowledged"
    t.datetime "ack_time", precision: nil
    t.index ["entity"], name: "index_tokens_on_entity", unique: true
  end

  create_table "trim_links", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.integer "size"
    t.binary "data"
    t.integer "pq_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "deleted", default: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "roles"
    t.boolean "deleted", default: false
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at", precision: nil
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
