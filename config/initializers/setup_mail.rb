ActionMailer::Base.smtp_settings = {
  :address                => "smtp.gmail.com",
  :port                   => 587,
  :domain                 => 'gmail.com',
  :user_name              => 'alanpqs',
  :password               => 'nelim3sala',
  :authentication         => 'plain',
  :enable_starttls_auto   => true
}

#Mail.defaults do
#  delivery_method :smtp, options
#end
require "development_mail_interceptor"

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
