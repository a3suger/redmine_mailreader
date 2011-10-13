class MailmessagesController < ApplicationController
  unloadable

  menu_item :mailreader
 
  before_filter :find_mailmessage,  :only => [:show,:seen]

  helper :attachments
  include AttachmentsHelper


  def show
  end

  def seen
	@mailmessage.turn_seen
	@mailmessage.save!
	redirect_to :action => :show, :id => @mailmessage
  end

  private 

  def find_mailmessage
#	render_403 :message =>:notice_not_authorized if User.current.blank?
	@mailmessage = Mailmessage.find_by_id(params[:id])
	render_404 :message =>:notice_file_not_found and return unless @mailmessage 
#	render_404 :message =>:notice_file_not_found if @mailmessage.mailfolder.user != User.current
	@project = @mailmessage.project
  end

end
