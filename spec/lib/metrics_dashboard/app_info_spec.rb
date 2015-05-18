require 'spec_helper'

describe MetricsDashboard::AppInfo do
  let(:version) { 1.0        }
  let(:date)    { Date.today }
  let(:tag)     { 2          }
  let(:id)      { 'fhjsvbk'  }
  let(:info)    { 
    {
      version_number: version,
      build_date:     date,
      build_tag:      tag,
      commit_id:      id
    }
   }

  it '#gather_metrics - updates the app info fields with deployment info' do
    allow(Deployment).to receive(:info).and_return(info)

    subject.gather_metrics

    expect(subject.version).to eq version
    expect(subject.build_date).to eq date
    expect(subject.build_tag).to eq tag
    expect(subject.git_sha).to eq id
  end
end