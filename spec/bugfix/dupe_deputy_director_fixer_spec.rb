require 'spec_helper'

describe DupeDeputyDirectorFixer do

  
  let!(:dd1_old)       { FactoryGirl.create :deputy_director, name: 'Old DD 1' }
  let!(:dd2_old)       { FactoryGirl.create :deputy_director, name: 'Old DD 2' }
  let!(:dd3_old)       { FactoryGirl.create :deputy_director, name: 'Old DD 3' }
  let!(:dd1_new)       { FactoryGirl.create :deputy_director, name: 'New DD 1' }
  let!(:dd2_new)       { FactoryGirl.create :deputy_director, name: 'New DD 2' }
  let!(:dd3_new)       { FactoryGirl.create :deputy_director, name: 'New DD 3' }

  let!(:ao1)           { FactoryGirl.create :action_officer, deputy_director: dd1_old, name: 'Action officer 1'}
  let!(:ao2)           { FactoryGirl.create :action_officer, deputy_director: dd1_new, name: 'Action officer 2'}
  let!(:ao3)           { FactoryGirl.create :action_officer, deputy_director: dd2_old, name: 'Action officer 3'}

  let(:dupes)         { { dd1_old.id => dd1_new.id, dd2_old.id => dd2_new.id, dd3_old.id => dd3_new.id } }

  let(:fixer)         { DupeDeputyDirectorFixer.new(dupes) }

  it 'should change all the deputy director ids on all action officers referring to old dds' do
    fixer.dedupe!
    ao1.reload
    ao2.reload
    ao3.reload
    expect(ao1.deputy_director_id).to eq dd1_new.id
    expect(ao2.deputy_director_id).to eq dd1_new.id
    expect(ao3.deputy_director_id).to eq dd2_new.id
  end

  it 'should report on the changes its made' do
    fixer.dedupe!
    expect(fixer.instance_variable_get(:@reports)).to eq(
      [
        "AO:#{ao1.id} #{ao1.name} has changed DD from #{dd1_old.id}:#{dd1_old.name} to #{dd1_new.id}:#{dd1_new.name}.",
        "AO:#{ao3.id} #{ao3.name} has changed DD from #{dd2_old.id}:#{dd2_old.name} to #{dd2_new.id}:#{dd2_new.name}."
      ])
  end

  
end
