module MailHelpdesk
  private def mail_uuid(name, uuid)
    msg = "Subject: Account #{name} has been deleted.\n\n" \
          "The account's entryUUID is #{uuid}."
    smtp = Net::SMTP.new "smtp.#{Figaro.env.domain}", 587
    smtp.enable_starttls
    smtp.start(Figaro.env.domain,
               Figaro.env.mail_user,
               Figaro.env.mail_password,
               :login) do
      smtp.send_message(msg,
                        "#{Figaro.env.mail_user}@#{Figaro.env.domain}",
                        "#{Figaro.env.mail_helpdesk}@#{Figaro.env.domain}")
    end
    "Mail sent to #{Figaro.env.mail_helpdesk}@#{Figaro.env.domain} " \
    "with entry UUID.\n"
  end
end
