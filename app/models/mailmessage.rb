class Mailmessage < ActiveRecord::Base
  unloadable

  belongs_to :mailfolder

  acts_as_tree 
 # belongs_to :parent, :class_name => 'Mailmessage' 
  belongs_to :assign, :polymorphic => true
  belongs_to :user 

  validates_presence_of :subject
  validates_presence_of :from
  validates_presence_of :uid
  validates_presence_of :messageid

  attr_reader :num_node, :num_none
  attr_writer :msgancestors

  acts_as_attachable :view_permission => :view_files, :delete_permission => :manage_files ;

  before_save :assign_parent

  def self.find_roots_by_mailfolder(mailfolder)
	_mailfolder = mailfolder.instance_of?(Mailfolder) ? mailfolder : Mailfolder.find_by_id(mailfolder) 
	_messages = self.roots 
	_messages.delete_if{|m| m.mailfolder != _mailfolder}
  end

  def self.assign_by_id(id,target)
	  if _message = Mailmessage.find_by_id(id)
		  _message.assign = target 
		  if _message.attachments.any?
		  	if target.instance_of?(Issue)
				_message.attachments.each{|a|
					a.author = target.author
					a.save!
				}
			end
			if target.instance_of?(Journal)
				_message.attachments.each{|a|
					a.author = target.user
					a.save!
				}
			end
		  end
		  _message.save
	  end
  end

  def self.find_by_issue(issue)
	_message =  Mailmessage.find_by_assign_type_and_assign_id('Issue', issue.instance_of?(Issue) ? issue.id : issue )
  end

  def self.find_by_journal(journal)
	_message =  Mailmessage.find_by_assign_type_and_assign_id('Journal', journal.instance_of?(Journal) ? journal.id : journal )
  end

  def project
	  mailfolder.project
  end

  def turn_seen
	  self.seen = true 
  end

  def done?
	self.seen || assign_type  
  end

  def has_an_issue?
	return false if assign.nil?	
	return assign.instance_of? Issue
  end

  def has_an_journal?
	return false if assign.nil?	
	return assign.instance_of? Journal
  end

  def issue_of_ancestor
	return self.assign if has_an_issue?
	self.parent.nil? ? nil : self.parent.issue_of_ancestor 
  end

  def to_s
	"##{id}: #{subject} @ #{format_time(created_on)}"
  end

  def num_node
	  self.calc
	  @num_node
  end

  def css_classes
	s = ''
	case assign_type 
	when nil
		s << 'icon icon-checked' if self.seen
	when 'Issue'
		s << 'icon icon-issue'
	when 'Journal'
		s << 'icon icon-comment'
	else
		#nothing
	end
	s
  end

  def calc
	#©•ª©g
	@num_node = 1 
	@num_none = done? ? 0  : 1 
	unless self.children.blank? 
		self.children.each{|child|
			child.calc
			@num_node += child.num_node
			@num_none += child.num_none
	}
	end
  end

  private

  def assign_parent
	unless  @msgancestors.blank?
		@msgancestors.each do |a|
			self.parent = mailfolder.mailmessages.find_by_messageid(a)
			break unless self.parent.nil?
		end
	end 
  end


end
