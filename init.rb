require 'redmine'
require 'i18n'

require 'mailmessage_hooks'
require 'mailmessage_viewhooks'

Redmine::Plugin.register :redmine_mailreader do
  name 'mail reader using IMAP plugin'
  author 'Akira SATO'
  description 'This is a plugin for Redmine'
  version '0.0.1'

 # menu :account_menu, :mailreader, { :controller => 'mailfolders', :action => 'index' }
#   permission :mailreader, {:mailfolders => [:index, :detail]}, :public => true
   permission :edit_mailreader, :mailfolders => [:index,:new,:show,:edit,:destory]
   permission :read_mailreader, :mailfolders => :read
   permission :view_mailreader, {:mailfolders => :detail ,:mailmessages => :show }
   # 複数のコンローラーのアクションのpermissionを出したいときは
   # Hash として記載してよいようだ．　lib/redmin/access_control.rb
   menu :project_menu, :mailreader, { :controller => 'mailfolders', :action => 'index' }, :caption => :label_mailfolders, :last => true, :param => :project_id
end
