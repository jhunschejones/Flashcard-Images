class SessionsController < ApplicationController
  skip_before_action :authenticate_user

  def new
    if session[:user_id]
      redirect_to session.delete(:return_to) || root_path
    else
      render :new
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      flash.discard
      audit_login_attempt(user_id: user&.id, user_email: params[:email], success: true)
      redirect_to session.delete(:return_to) || root_path
    else
      audit_login_attempt(user_id: user&.id, user_email: params[:email], success: false)
      redirect_to login_url, alert: "Invalid email/password combination"
    end
  end

  def destroy
    reset_session
    redirect_to login_url, notice: "Succesfully logged out"
  end

  private

  def audit_login_attempt(user_id:, user_email:, success:)
    NewRelic::Agent.record_custom_event(
      "AccountAccessAudit",
      "action" => "user.login",
      "attributes" => {
        "user_id" => user_id,
        "user_email" => user_email,
        "login_time" => Time.now.to_i,
        "success" => success
      }
    )
  end
end
