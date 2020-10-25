Rails.application.configure do
  # Default to Mailtrap if we have it, then fallback to sendgrid then SENDGRID_USERNAME.
  # If nothing is present. don't send emails (Which each environment can override if needed).
  if ENV['MAILTRAP_API_TOKEN'].present?
    first_inbox = JSON.parse(open("https://mailtrap.io/api/v1/inboxes.json?api_token=#{ENV['MAILTRAP_API_TOKEN']}").read)[0]
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: first_inbox['username'],
      password: first_inbox['password'],
      address: first_inbox['domain'],
      domain: first_inbox['domain'],
      port: first_inbox['smtp_ports'][0],
      authentication: :cram_md5
    }
  elsif ENV['SENDGRID_USERNAME'].present? && ENV['SENDGRID_PASSWORD'].present?
    config.action_mailer.smtp_settings = {
      address: 'smtp.sendgrid.net',
      port: 587,
      authentication: :plain,
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      domain: 'heroku.com',
      enable_starttls_auto: true
    }
  elsif Rails.env.development? && defined?(LetterOpenerWeb)
    #  https://github.com/fgrehm/letter_opener_web
    # Preview mailers in your browser.
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true
  else
    config.action_mailer.perform_deliveries = false
  end

  # Enable previewing mailers in review environments.
  config.action_mailer.show_previews = (ENV['ENABLE_MAILER_PREVIEWS'].present? || Rails.env.development?)
end
