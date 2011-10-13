module MailmessagesHelper

#  def link_to_mailmessage(message)
# 	link_to_if message ,
#		"<b>#{l(:label_mailmessages)}</b> #{message}",
#		{:controller => 'mailmessages', :action => 'show', :id => message} 
#  end

#  def link_to_mailmessage_from_issue(issue)
#	link_to_mailmessage  Mailmessage.find_by_issue(issue) 
#  end


  def link_to_issue_from_mailmessage(message)
	_issue = message.issue_of_ancestor
	link_to_if _issue, 
	 	 "<b>#{l(:label_issue)}</b> #{_issue}" ,
		 {:controller => 'issues', :action => 'show', :id => _issue }
  end


  def display_messages_by_tree(message)
	_root = message.root 
	display_messages_for_descendants(_root,message)
  end

  def button_to_seen(message)
	ret = ''
	unless message.done?
		url = url_for :action => :seen , :id => message
		ret << "<form action='#{url}' method='post'>"
		ret << "<input type='hidden' name='authenticity_token' value='#{form_authenticity_token}' />"
		ret << "<input type='submit' name='commit' value='#{l(:label_seen)}' />"
		ret << "</form>"
	end
	ret
  end

  def button_to_new_issue(message)
	ret = ''
        unless message.done?
		url = url_for :controller => :issues, :action => :new , :project_id => message.project
		ret << "<form action='#{url}' method='post'>"
		ret << "<input type='hidden' name='authenticity_token' value='#{form_authenticity_token}' />"
		ret << "<input type='hidden' name='mailmessage_id' value='#{message.id}' />"
		ret << "<input type='hidden' name='issue[subject]' value='#{message.subject.toutf8}' />"
		ret << "<input type='hidden' name='issue[description]' value='#{message.notes}' />"
		ret << "<input type='hidden' name='issue[start_date]' value='#{message.created_on.strftime("%Y-%m-%d")}' />"
		if _parent_issue = message.issue_of_ancestor
			ret << "<input type='hidden' name='issue[parent_issue_id]' value='#{_parent_issue.id}' />"
		end
		ret << "<input type='submit' name='commit' value='#{l(:label_issue_new)}' />"
		ret << "</form>"
	end
	ret
  end

  def button_to_edit_issue(message)
	ret = ''
	if !message.done? && _issue = message.issue_of_ancestor
		url = url_for :controller => :issues, :action => :edit , :id => _issue
		ret << "<form action='#{url}\' method='get'>"
		ret << "<input type='hidden' name='authenticity_token' value='#{form_authenticity_token}' />"
		ret << "<input type='hidden' name='mailmessage_id' value='#{message.id}' />"
		ret << "<input type='hidden' name='issue[notes]' value='#{message.notes}' />"
		ret << "<input type='submit' name='commit' value='#{l(:label_issue_edit,:id =>_issue.id)}' />"
		ret << "</form>"
	end
	ret
  end

  private

  def display_messages_for_descendants(message,current_message)
	ret = "<ul style='list-style-type:none;'>"
	# begin myself 
	ret += "<li>"
	ret += (message == current_message) ? "<strong class='#{message.css_classes}'>#{message}</strong>" : link_to("#{message}",{:action =>'show',:id=> message.id} ,:class => message.css_classes )
	# begin children
  	if _children = message.children
		_children.each { |child| ret += display_messages_for_descendants(child,current_message) } 
	end
	# end children
	ret += "</li>"
	# end myself
	ret += "</ul>"
	ret
  end
end
