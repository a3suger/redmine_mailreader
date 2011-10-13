class MailfoldersController < ApplicationController
unloadable
#
# 管理系 new,edit,show,destory 
# 表示系 index,details  
# 操作系 fetch
#
  menu_item :mailreader
  before_filter :find_project, :authorize, :only => [:index,:new]
  before_filter :find_folder, :authorize, :except => [:index,:new]

  # プロジェクトとユーザに関連しているフォルダを選ぶ
  def index
	if @project.nil? 
		@folders = Mailfolder.find_all_by_user_id(User.current.id)
	else
		@folders = Mailfolder.find_all_by_user_id_and_project_id(User.current.id,@project.id)
	end
  end

  # 新しいフォルダを作る
  def new
	@mailfolder = Mailfolder.new(params[:mailfolder])
	@mailfolder.user = User.current
	@mailfolder.project = @project
	if request.post? and @mailfolder.save 
		flash[:notice] = l(:notice_successful_create)
		redirect_to :action => :show, :id => @mailfolder.id
	end
  end


  def show
  end


  def edit
	if request.post?
		@mailfolder.attributes = params[:mailfolder]
		if @mailfolder.save 
			flash[:notice] = l(:notice_successful_update)
			redirect_to :action => :show, :id => @mailfolder.id
		end
	end
        rescue ActiveRecord::StaleObjectError
	  flash.now[:error] = l(:notice_locking_conflict)
  end

  def destroy
	@project = @mailfolder.project
	@mailfolder.destroy
	redirect_to :action => :index, :project_id =>@project
  end

  def fetch
	@mailfolder.read_messages
	@mailfolder.save
	redirect_to :action => :index, :project_id =>@project
  end

  def detail
	@messages = Mailmessage.find_roots_by_mailfolder(@mailfolder)
	render :template => "mailmessages/index",
		:locals => {:messages => @messages }
  end

  private 

  def find_project 
	# @project variable must be set before calling the authorize filter
	@project = Project.find(params[:project_id]) if params[:project_id]
 
  end

  def find_folder
	render_403 :message => :notice_not_authorized and return if  User.current.blank? 

	@mailfolder=Mailfolder.find_by_id_and_user_id(params[:id],User.current.id) if params[:id]

	render_404 :message => :notice_file_not_found and return unless  @mailfolder 

	@project = @mailfolder.project
  end
end
