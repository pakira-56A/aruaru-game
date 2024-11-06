class CustomAuthenticationFailure < Devise::FailureApp
  protected

  def redirect_url
    root_path
  end
end
