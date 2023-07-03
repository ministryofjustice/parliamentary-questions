require "spec_helper"

describe "routes", type: :routing do
  it "routes to the expected controller action" do
    expect(get: "/dashboard").to route_to(controller: "dashboard", action: "index")
    expect(get: "/dashboard/in_progress").to route_to(controller: "dashboard", action: "in_progress")
  end

  it "routes unknown routes to the page_not_found action" do
    expect(get: "/gobbledygook").to route_to(:controller => "application", action: "page_not_found", "path" => "gobbledygook")
  end
end
