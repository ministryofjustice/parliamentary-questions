Feature: Assigned action officer can accept or reject the assignment

  Scenario: Action officer accepts the assigned question
    Given There is a not responded question
    When the action officer accepts it
    Then the question should be accepted

  Scenario: Action officer rejects the assigned question
    Given There is a not responded question
    When the action officer rejects it
    Then the question should be rejected