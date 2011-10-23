class MailmessagesController < ApplicationController
  unloadable

  menu_item :mailreader

  before_filter :find_mailfolder,  :only   => [:list]
  before_filter :find_mailmessage, :except => [:list]

  helper :attachments
  include AttachmentsHelper


  def show
  end

  def set_parent
        @mailmessage.parent_id = params[:parent_id]
        @mailmessage.save!
        redirect_to :action => :show, :id => @mailmessage
  end


  def seen
	@mailmessage.turn_seen
	@mailmessage.save!
	redirect_to :action => :show, :id => @mailmessage
  end

  def list
      @per_page = params['per_page'].to_i 
      @per_page = 50 unless  ( @per_page > 0 )  
      @message_count = @mailfolder.mailmessages.size
      @message_pages = Paginator.new self, @message_count, @per_page, params['page']
      @offset ||= @message_pages.current.offset
      @messages = Mailmessage.find :all,:order => 'id DESC',
                          :limit  =>  @message_pages.items_per_page,
                          :offset =>  @message_pages.current.offset,
			  :conditions => ["mailfolder_id = ?",@mailfolder.id]
     respond_to do |format|
        format.html { render :template => 'mailmessages/list', :layout => !request.xhr? }
     end 
  end

  private 

  def find_mailfolder 
	# @project variable must be set before calling the authorize filter
	@mailfolder = Mailfolder.find(params[:mailfolder_id]) if params[:mailfolder_id]
	@project = @mailfolder.project
  end

  def find_mailmessage
#	render_403 :message =>:notice_not_authorized if User.current.blank?
	@mailmessage = Mailmessage.find_by_id(params[:id])
	render_404 :message =>:notice_file_not_found and return unless @mailmessage 
#	render_404 :message =>:notice_file_not_found if @mailmessage.mailfolder.user != User.current
	@project = @mailmessage.project
  end

end
