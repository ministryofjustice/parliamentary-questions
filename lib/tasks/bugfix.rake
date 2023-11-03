namespace :bugfix do
  desc "Checks all PQs and checks they only have one active accepted AO and reports those that do not"
  task check_aos: :environment do
    Pq.all.each do |pq|
      next if pq.valid?

      puts "PQ #{pq.uin}"
      pq.errors.each do |key, msg|
        puts "  Key: #{key}: #{msg}"
      end
    end
  end

  desc "fix PQs with multiple action accepted AOs"
  task ao_fix: :environment do
    uins_to_fix = {
      "907383" => "Michelle English",
      "HL3918" => "Siobhan Mahoney",
    }

    uins_to_fix.each do |uin_to_fix, ao_name|
      pq = Pq.uin uin_to_fix
      aos = pq.action_officers.all_active_accepted
      aos.each do |ao|
        next if ao.name == ao_name

        aopq = ActionOfficersPq.where("pq_id = ? AND action_officer_id = ?", pq.id, ao.id).first
        aopq.response = :rejected
        aopq.save!
        puts "Marked AO #{ao.name} for PQ #{pq.id}:#{pq.uin} as rejected"
      end
    end
  end

  desc "Remove Follow up created in error"
  task delete_25231_IWW: :environment do
    pq = Pq.find_by(uin: "25231-IWW")
    ActionOfficersPq.where("pq_id = ?", pq.id).map(&:destroy)
    puts "Deleted AO Link(s)"

    Pq.where("uin like '25231-IWW'").map(&:destroy)
    puts "Deleted UIN"

    pq_original = Pq.find_by(uin: "25231")
    pq_original.i_will_write = FALSE
    pq_original.save!
    puts "Saved Original UIN as non IWW"
  end

  desc "Prefix uins for previous session"
  task prefix_uins: :environment do
    puts "Number of non-prefixed uins #{
    Pq.where.not("uin SIMILAR TO '(#|[ESCAPE *]|$|^|~|£|a)%'").count} "
    Pq.where.not("uin SIMILAR TO '(#|[ESCAPE *]|$|^|~|£|a)%'").update_all("uin='b'||uin")
    puts "Number of uins with £ prefix #{Pq.where('uin like ?', 'b%').count} "
    puts "Post-update: Number of non-prefixed uins #{Pq.where.not("uin SIMILAR TO '(#|[ESCAPE *]|$|^|~|£|a|b)%'").count} "
  end
end
