class MailmessageViewhooks < Redmine::Hook::ViewListener 
  include MailmessagesHelper

  def view_issues_form_details_bottom(context)
	if context[:request].respond_to?(:params) && _mailmessage = Mailmessage.find_by_id(context[:request].params[:mailmessage_id])
		context[:controller].send(:render,{
			:partial => 'mailmessages/issues_form_details_bottom',
			:locals =>{:f => context[:form], :mailmessage => _mailmessage }
		})
	end
  end

  def view_issues_show_details_bottom(context)
	if _mailmessage = Mailmessage.find_by_issue(context[:issue])
		context[:controller].send(:render_to_string,{
			:partial => 'mailmessages/issues_show_details_bottom',
			:locals =>{:mailmessage => _mailmessage}})
	end
  end

  def view_issues_history_journal_bottom(context)
	if _mailmessage = Mailmessage.find_by_journal(context[:journal])
		context[:controller].send(:render_to_string,{
			:partial => 'mailmessages/issues_show_details_bottom',
			:locals =>{:mailmessage => _mailmessage}})
	end
  end
end
