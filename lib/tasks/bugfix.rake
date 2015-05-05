namespace :bugfix do
  desc 'Checks all PQs and checks they only have one active accepted AO and reports those that do not'
  task :check_aos => :environment do
    Pq.all.each do |pq|
      unless pq.valid?
        puts "PQ #{pq.uin}"
        pq.errors.each do |key, msg|
          puts "  Key: #{key}: #{msg}"
        end
      end
    end
  end


  desc 'fix PQs with multiple action accepted AOs'
  task :ao_fix => :environment do
    uins_to_fix = {
      '907383' => 'Michelle English',
      'HL3918' => 'Siobhan Mahoney'
    }

    uins_to_fix.each do |uin_to_fix, ao_name|
      pq = Pq.uin uin_to_fix
      aos = pq.action_officers.all_active_accepted
      aos.each do |ao|
        unless ao.name == ao_name
          aopq = ActionOfficersPq.where("pq_id = ? AND action_officer_id = ?", pq.id, ao.id).first
          aopq.response = :rejected
          aopq.save!
          puts "Marked AO #{ao.name} for PQ #{pq.id}:#{pq.uin} as rejected"
        end
      end
    end
  end
end