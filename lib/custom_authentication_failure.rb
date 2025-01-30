class CustomAuthenticationFailure < Devise::FailureApp
  protected

  def respond
    # 認証失敗時の処理をカスタマイズするメソッド
    if http_auth?
      http_auth
    else
      redirect
    end
  end

  # 認証失敗時のリダイレクト先を指定するメソッド
  def redirect_url
    # Warden（Devise)が内部で使っている認証ライブラリ）のオプションの一部で、現在の認証スコープを示す
    # ユーザーの種類やロールを特定するために使われる
    if warden_options[:scope] == :user
      root_path
    else
      super
    end
  end
end
