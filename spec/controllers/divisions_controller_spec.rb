require 'spec_helper'
require "#{Rails.root}/spec/support/features/session_helpers"

describe DivisionsController, type: :controller do

#   describe 'Get index' do
#     it 'lists the Divisions sorted alphabetically by active then inactive states' do
#       create_directorates_for_divisions
#       create_divisions
#       expect(PQUserFilter).to receive(:before).and_return(true)
#       expect(controller).to receive(:authenticate_user!).and_return(true)
#       get :index
#       expect(response.status).to eq(200)
#       puts @divisions = Division.active_list
#                                .joins(:directorate)
#                                .order(deleted: :asc)
#                                .order(Arel.sql('lower(directorates.name)'))
#                                .order(Arel.sql('lower(divisions.name)'))
#       expect(assigns(:divisions).map(&:name)).to eq expected_order_of_divisions
#
#     end
#   end
# end
#
# def create_directorates_for_divisions
#   FactoryBot.create(:directorate, name: 'Directorate A')
#   FactoryBot.create(:directorate, name: 'Directorate B')
# end
#
# def create_divisions
#   FactoryBot.create(:division, name: 'Division A',  directorate_id: '1', updated_at: DateTime.now.to_datetime,  deleted: false)
#   FactoryBot.create(:division, name: 'Division B',  directorate_id: '2', updated_at: DateTime.now.to_datetime,  deleted: true)
#   FactoryBot.create(:division, name: 'Division C',  directorate_id: '1', updated_at: 1.day.ago.to_datetime,     deleted: false)
#   FactoryBot.create(:division, name: 'Division D',  directorate_id: '2', updated_at: 1.day.ago.to_datetime,     deleted: true)
#   FactoryBot.create(:division, name: 'Division E',  directorate_id: '1', updated_at: 2.days.ago.to_datetime,    deleted: false)
#   FactoryBot.create(:division, name: 'Division F',  directorate_id: '2', updated_at: 2.days.ago.to_datetime,    deleted: true)
#   FactoryBot.create(:division, name: 'Division G',  directorate_id: '1', updated_at: DateTime.now.to_datetime,  deleted: false)
#   FactoryBot.create(:division, name: 'Division H',  directorate_id: '2', updated_at: DateTime.now.to_datetime,  deleted: true)
#   FactoryBot.create(:division, name: 'Division I',  directorate_id: '1', updated_at: 1.day.ago.to_datetime,     deleted: false)
#   FactoryBot.create(:division, name: 'Division J',  directorate_id: '2', updated_at: 1.day.ago.to_datetime,     deleted: true)
#   FactoryBot.create(:division, name: 'Division K',  directorate_id: '1', updated_at: 2.days.ago.to_datetime,    deleted: false)
#   FactoryBot.create(:division, name: 'Division L',  directorate_id: '2', updated_at: 2.days.ago.to_datetime,    deleted: true)
#   puts 'Becca Rocks'
# end
#
# def expected_order_of_divisions
#   [
#     'Division A',
#     'Division C',
#     'Division E',
#     'Division G',
#     'Division I',
#     'Division K',
#     'Division B',
#     'Division D',
#     'Division H',
#     'Division J'
#   ]
end
