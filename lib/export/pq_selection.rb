module Export
  class PqSelection < Base
    private
    def pqs
        pqs_array = Array.new
        @pqs_list.split(',').map { |p|
          if Pq.find_by(uin: p).nil?
            puts 'Failed to validate ' || p
            errors.add(p, "False PQ UIN")
            return false
          else
            puts 'Validated ' || p
            x = Pq.find_by(uin: p)
            puts x
            pqs_array.push(x)
          end
        }
        pqs_array

    end
  end
end
