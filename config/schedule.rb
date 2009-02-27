# Learn more about this file: http://github.com/javan/whenever

set :environment, 'production'

every 1.hour, :at => 19 do
  runner 'Group.update_memberships; NewsItem.update_from_feed; LogItem.flag_suspicious_activity'
end

every 1.day, :at => '2:49 am' do
  runner "CGI::Session::ActiveRecordStore::Session.delete_all(['updated_at < ?', 1.day.ago.utc])"
end

if File.exist?('config/email.yml')
  every 1.minute do
    settings = YAML::load_file('config/email.yml')[@environment.to_s]['pop']
    command "#{Rails.root}/script/inbox -e #{@environment} \"#{settings['host']}\" \"#{settings['username']}\" \"#{settings['password']}\""
  end
end