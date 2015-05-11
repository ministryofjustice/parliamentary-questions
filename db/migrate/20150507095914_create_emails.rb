class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string    :mailer
      t.string    :method
      t.text      :params
      t.text      :from
      t.text      :to
      t.text      :cc
      t.text      :reply_to
      t.datetime  :send_attempted_at
      t.datetime  :sent_at
      t.integer   :num_send_attempts, default: 0
      t.string    :status, default: 'new'

      t.timestamps
    end
  end
end
