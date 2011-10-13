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
   # �����̃R�����[���[�̃A�N�V������permission���o�������Ƃ���
   # Hash �Ƃ��ċL�ڂ��Ă悢�悤���D�@lib/redmin/access_control.rb
   menu :project_menu, :mailreader, { :controller => 'mailfolders', :action => 'index' }, :caption => :label_mailfolders, :last => true, :param => :project_id
end
