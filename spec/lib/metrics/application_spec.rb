require "spec_helper"

describe Metrics::Application do
  subject(:application) { described_class.new }

  let(:version) { 1.0 }
  let(:date)    { Time.zone.today }
  let(:tag)     { 2          }
  let(:id)      { "fhjsvbk"  }
  let(:info) do
    {
      version_number: version,
      build_date: date,
      build_tag: tag,
      commit_id: id,
    }
  end

  it "#collect! - updates the app info fields with deployment info" do
    allow(Deployment).to receive(:info).and_return(info)

    application.collect!

    expect(application.version).to eq version
    expect(application.build_date).to eq date
    expect(application.build_tag).to eq tag
    expect(application.git_sha).to eq id
  end
end
