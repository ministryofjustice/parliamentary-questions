class RenamePodProgressRecords < ActiveRecord::Migration
  def up
    ['Pod Query', 'Pod Cleared'].each do |name|
      progress = Progress.where(name: name).first
      if progress
        progress.update(name: name.gsub(/Pod/,'POD'))
      else
        warn "db:migrate: cannot find progress named: #{name}"
      end
    end
  end

  def down
  end
end
