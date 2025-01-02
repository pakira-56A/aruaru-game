class CustomAuthenticationFailure < Devise::FailureApp
    protected

    def redirect_url
        # Warden（Devise)が内部で使っている認証ライブラリ）のオプションの一部で、現在の認証スコープを示す
        # ユーザーの種類やロールを特定するために使われる
        if warden_options[:scope] == :user
            root_path
        else
            super
        end
    end

    def respond
        # HTTP認証を使ってレスポンスを返すhttp_authメソッドを呼び出す
        if http_auth?
            http_auth
        else
            redirect
        end
    end
end
