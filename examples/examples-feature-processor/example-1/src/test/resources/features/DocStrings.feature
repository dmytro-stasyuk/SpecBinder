Feature: DocStrings

  This example demonstrates how Gherkin doc strings are converted to String parameters.

  Scenario: Creating a blog post
    Given I am a content editor
    When I create a post with content:
      """
      This is the first paragraph of my blog post.
      It contains multiple lines of text.

      This is the second paragraph.
      """
    Then the post should be saved successfully

  Scenario: Sending an email
    When I send an email with body:
      """
      Dear Customer,

      Thank you for your purchase.

      Best regards,
      Support Team
      """
    Then the email should be sent
