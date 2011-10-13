class MailmessageHooks < Redmine::Hook::Listener 

  # see also view_issues_form_details_bottom at MailmessageViewhooks 
  def controller_issues_new_after_save(context) 
	if context[:params][:mailmessage_id] 
		Mailmessage.assign_by_id(context[:params][:mailmessage_id],context[:issue])
	end
  end

  # see also view_issues_form_details_bottom at MailmessageViewhooks 
  def controller_issues_edit_after_save(context) 
	if context[:params][:mailmessage_id] 
		Mailmessage.assign_by_id(context[:params][:mailmessage_id],context[:issue].current_journal)
	end
  end

  def controller_issues_new_before_save(context) 
	if context[:params][:user]
		_user = user_select(context)
		if _user.nil? 
			return false
		end
 		context[:issue].author = _user
	end
  end 

  def controller_issues_edit_before_save(context) 
	if context[:params][:user]
		_user = user_select(context)
		if _user.nil? 
			return false
		end
 		context[:journal].user = _user
	end
  end 

  private

  def user_select(context)
	if context[:params][:user] == 'make'
		user = User.new
		user.mail      = context[:params][:user_mail]
		names = user.mail.gsub(/@.*$/,'').split('.')
		user.firstname = names.shift
		user.lastname  = names.join(' ')
		user.lastname  = '-' if user.lastname.blank?
		user.login     = user.mail
		user.random_password
		user.save!
	else
		user = User.find_by_id(context[:params][:user].to_i)
	end
	user
  end

end

