class TrimLink < ActiveRecord::Base
	def display_name
		filename.sub! File.extname(filename),''
	end
end
