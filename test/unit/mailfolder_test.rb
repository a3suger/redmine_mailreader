require File.dirname(__FILE__) + '/../test_helper'

class MailfolderTest < ActiveSupport::TestCase
  fixtures :mailfolders

  # Replace this with your real tests.
  def test_db
    assert_equal mailfolders(:one),Mailfolder.find(1)
  end
end
