Feature: A question can be commissioned

  Scenario: A checked by finance question can be commissioned after providing required ministers, action officers and dates
    Given I there is a checked by finance question
    When I open the dashboard with that question
    And I assign ministers, action officers and choose the dates
    Then the question should be commissioned