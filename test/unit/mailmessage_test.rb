require 'test/unit'

require '../../../../../config/environment'
require 'active_support/test_case'


ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => ':memory:')

require '../../db/migrate/20110718152211_create_mailfolders'

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    CreateMailfolders.up 
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end


class MailmessageTest < ActiveSupport::TestCase

  def setup
	  setup_db
	  @mailfolder = Mailfolder.new(:name => "name",
				      :mailid => "mailid",
				      :server => "server",
				      :port   => 111)
	  @mailfolder.save!

	  @one   = @mailfolder.mailmessages.create(
				 :from => "from_1",
				 :uid  => "uid_1",
				 :subject => "subject_1", 
				 :messageid => "messageid_1", 
				 :msgancestors => [] );
	  @two   = @mailfolder.mailmessages.create(
				 :mailfolder => @mailfolder, 
				 :from => "from_2",
				 :uid  => "uid_2",
				 :subject => "subject_2", 
				 :messageid => "messageid_2", 
				 :msgancestors => ['messageid_1'] );
	  @three = @mailfolder.mailmessages.create(
				 :mailfolder => @mailfolder, 
				 :from => "from_3",
				 :uid  => "uid_3",
				 :subject => "subject_3", 
				 :messageid => "messageid_3", 
				 :msgancestors => [] );
  end

  def teardown
	  teardown_db
  end

  def test_create
	  assert_equal( @one, @two.root)
  end

  def test_find_roots_by_mailfolder
	  assert_equal( [],Mailmessage.find_roots_by_mailfolder(nil),"return nil if arg is nil")
	#  assert_equal( [@one,@three],Mailmessage.find_roots_by_mailfolder(@mailfolder),"return two items if arg is @mailfolder")
	  assert_equal( [@one,@three],Mailmessage.find_roots_by_mailfolder(1),"return two items if arg is 1 " )
	  assert_equal( [],Mailmessage.find_roots_by_mailfolder(2),"return nil if arg is 2")
  end

  def test_num_node
	  assert_equal( 2,@one.num_node )
  end
end
