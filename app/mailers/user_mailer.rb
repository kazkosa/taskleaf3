class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #

  default from: "ticketline.information@gmail.com"
  
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end

  def join_the_project(from_user, to_user, project)
    @from_user = from_user
    @to_user = to_user
    @project = project
    mail to: to_user.email, subject: "#{from_user.name} invited you to #{project.name}"
  end
end
