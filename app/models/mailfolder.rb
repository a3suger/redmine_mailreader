class Mailfolder < ActiveRecord::Base
  unloadable

require 'net/imap'
#require 'nkf'

  belongs_to :user
  belongs_to :project
  has_many :mailmessages, :dependent => :destroy

  validates_presence_of :name,:mailid,:server,:port
  validates_numericality_of :port

#  def init_message(subject,addr,recipients,date,note,messageid,uid,ancestors)
#	_user = User.find_by_mail(addr)
#	_user = User.anonymous if _user.nil? || project.nil? || ! project.users.include?( _user )
#
#	parent = find_by_ancestors(ancestors)	
#	_msg = Mailmessage.new(:mailfolder => self, 
#			       :subject => subject,
#			       :uid => uid, :messageid => messageid,
#			       :created_on => date, :notes => note,
#			       :from => addr ,:parent =>parent,
#			       :user => _user,
#			       :recipients => recipients)
#	mailmessages << _msg
#	_msg
#
#  end

  def read_messages 
	method_name = "read_messages_via_#{protocol}"
	if self.class.private_instance_methods.collect(&:to_s).include?(method_name)
        	send method_name
		included = Time.now
		save!
	else
       		# ignoring it
      	end
  end

  private
  #
  # Read messages via imap
  #
  def read_messages_via_imap
	imap = Net::IMAP.new(server,port,usessl)
	imap.login(mailid,password)
	imap.select(folder)
	since = included.blank? ? "1-Jan-2000" : included.yesterday.to_date.strftime("%e-%b-%Y")
	imap.uid_search(["SINCE",since]).each do |msg_id|
		next unless mailmessages.find_by_uid(msg_id).nil?
		body  = imap.uid_fetch(msg_id,['RFC822']).first.attr['RFC822']

		MailfolderMailhandler::receive(body,self,msg_id)
		imap.store(msg_id, "+FLAG", [:Deleted]) if delete_message?
	end
	imap.expunge if delete_message?
	imap.logout
  end


#  def find_by_ancestors(ancestors)
#	return nil if ancestors.blank?
#	ancestors.each do |a|
#		parent = mailmessages.find_by_messageid(a)
#		return parent unless parent.nil?
#	end
#	return nil
#  end

end
