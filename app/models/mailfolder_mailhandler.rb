class MailfolderMailhandler < ActionMailer::Base

  include ActionView::Helpers::SanitizeHelper
  include Redmine::I18n


require 'nkf'

  def self.receive(email,folder,uid)
	Thread.current[:current_folder_id] = folder.id
  	Thread.current[:current_uid]       = uid
	super email
  end

  def receive ( email )
	@email = email
	_fld = Mailfolder.find_by_id( Thread.current[:current_folder_id] )

	_subject   = NKF.nkf('-Mw',email.subject.to_s).chomp[0,255].toutf8
	_subject   = '(no subject)' if _subject.blank?

	#sender    is email.from.to_a.first.to_s.strip
	_recipients = Marshal.dump({:to       =>email.to,
				   :cc       =>email.cc, 
				   :reply_to =>email.reply_to})
	#date      is email.date
	#note      is plain_text_body
	#messageid is email.message_id
	#uid       is Thread.current[:uid]
	_ancestors = [email.in_reply_to,email.references].flatten.compact

	_message  = _fld.mailmessages.create(
		:subject      => _subject,
		:uid          => Thread.current[:current_uid],
		:messageid    => email.message_id,
		:created_on   => email.date,
		:notes        => plain_text_body,
		:from         => email.from.to_a.first.to_s.strip,
		:recipients   => _recipients,
		:msgancestors => _ancestors)
			

#	_message  = _fld.init_message(_subject,
#				      email.from.to_a.first.to_s.strip,
#				      _recipients,
#				      email.date,
#				      plain_text_body,
#				      email.message_id,
#				      Thread.current[:current_uid],
#				      _ancestors)
	add_attachments(_message,_fld.user)
	_message
  end

  def self.full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end
  
  private
  def plain_text_body
	_parts = @email.parts.collect {|c| (c.respond_to?(:parts) && !c.parts.empty?) ? c.parts : c}.flatten
    	if _parts.empty?
      		_parts << @email
    	end
    	plain_text_part = _parts.detect {|p| p.content_type == 'text/plain'}
    	if plain_text_part.nil?
      		# no text/plain part found, assuming html-only email
      		# strip html tags and remove doctype directive
      		@plain_text_body = strip_tags(@email.body.to_s)
      		@plain_text_body.gsub! %r{^<!DOCTYPE .*$}, ''
    	else
      		@plain_text_body = plain_text_part.body.to_s
    	end
    	@plain_text_body.strip!
    	@plain_text_body
  end

  def add_attachments(msg,user)
	if @email.has_attachments?
      		@email.attachments.each do |attachment|
        		Attachment.create(:container => msg,
					  :file => attachment,
					  :author => user,
					  :content_type => attachment.content_type)
      		end
    	end
  end
 

end
