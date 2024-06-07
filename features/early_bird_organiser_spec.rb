require "feature_helper"

describe "Early bird organisers can be set", suspend_cleaner: true do
  include Features::PqHelpers

  let(:date_from) { Time.zone.today + 2 }
  let(:date_to) { Time.zone.today + 5 }
  let(:date_from_new) { Time.zone.today + 5 }
  let(:date_to_new) { Time.zone.today + 10 }

  let(:date_from_field) { "early_bird_organiser[date_from]" }
  let(:date_to_field) { "early_bird_organiser[date_to]" }

  let(:success_text) { "You have successfully scheduled the early bird to be turned off between #{date_from} and #{date_to}" }
  let(:success_text_two) { "You have successfully scheduled the early bird to be turned off between #{date_from_new} and #{date_to_new}" }
  let(:current_early_bird_status_text) { "The early bird is currently turned off between #{date_from} and #{date_to}." }
  let(:current_early_bird_status_text_two) { "The early bird is currently turned off between #{date_from_new} and #{date_to_new}." }

  before do
    DbHelpers.load_feature_fixtures
  end

  after do
    DatabaseCleaner.clean
  end

  it "An admin can create set early birds not to run between two dates" do
    create_pq_session
    click_link "Settings"
    click_link_or_button "Organise early bird email"
    fill_in date_from_field, with: date_from
    fill_in date_to_field, with: date_to
    click_link_or_button "Save and continue"

    expect(page).to have_text(success_text)
    expect(EarlyBirdOrganiser.last.date_from).to eq(date_from)
    expect(EarlyBirdOrganiser.last.date_to).to eq(date_to)
  end

  it "When an early bird has been set, there is a message explaining this on the organiser page" do
    create_pq_session
    click_link "Settings"
    click_link_or_button "Organise early bird email"
    fill_in date_from_field, with: date_from
    fill_in date_to_field, with: date_to
    click_link_or_button "Save and continue"

    click_link_or_button "Organise early bird email"
    expect(page).to have_text(current_early_bird_status_text)
  end

  it "An early bird can be overwritten by entering new dates" do
    create_pq_session
    click_link "Settings"
    click_link_or_button "Organise early bird email"
    fill_in date_from_field, with: date_from
    fill_in date_to_field, with: date_to
    click_link_or_button "Save and continue"

    expect(page).to have_text(success_text)
    click_link_or_button "Organise early bird email"
    fill_in date_from_field, with: date_from_new
    fill_in date_to_field, with: date_to_new
    click_link_or_button "Save and continue"

    expect(page).to have_text(success_text_two)

    click_link_or_button "Organise early bird email"
    expect(page).to have_text(current_early_bird_status_text_two)
    expect(EarlyBirdOrganiser.last.date_from).to eq(date_from_new)
    expect(EarlyBirdOrganiser.last.date_to).to eq(date_to_new)
  end
end
