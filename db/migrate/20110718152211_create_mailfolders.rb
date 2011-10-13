class CreateMailfolders < ActiveRecord::Migration
  def self.up
    create_table :mailfolders do |t|
	t.references :user
	t.references :project
	t.string     :name,           :null    => false
	t.string     :server         
	t.integer    :port
	t.string     :protocol,       :default => 'imap'
	t.boolean    :usessl,         :default => false
	t.string     :mailid
	t.string     :password
	t.string     :folder
	t.datetime   :included
	t.boolean    :delete_message, :default => false
	t.integer    :mailmessages_count
    end

    create_table :mailmessages do |t|
	t.references :mailfolder
	t.string     :from,      :null => false 
	t.string     :uid,       :null => false
	t.string     :subject,   :null => false 
	t.string     :messageid, :null => false
	t.text       :recipients  
	t.references :user       
	# like journal -- begin --
	t.datetime   :created_on,:null => false
	t.text       :notes
	# like journal -- end --
	t.boolean    :seen,   :default => false
	t.boolean    :enable, :default => true
	t.references :parent
	t.references :assign, :polymorphic => true
    end

  end

  def self.down
    drop_table :mailfolders
    drop_table :mailmessages
  end
end

