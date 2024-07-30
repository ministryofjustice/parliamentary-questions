require "rails_helper"

describe "routes", type: :routing do
  dashboard_path    = "/dashboard"
  dummy_path        = "/gobbledygook"
  in_progress_path  = "/dashboard/in_progress"

  it "routes to the expected controller action" do
    expect(get: dashboard_path).to route_to(controller: "dashboard", action: "index")
    expect(get: in_progress_path).to route_to(controller: "dashboard", action: "in_progress")
  end

  it "routes unknown routes to the page_not_found action" do
    expect(get: dummy_path).to route_to(:controller => "application", action: "page_not_found", "path" => "gobbledygook")
  end
end
