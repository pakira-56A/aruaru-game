class Users::RegistrationsController < Devise::RegistrationsController

    protected

    def update_resource(resource, params)
        if resource.update_without_password(params)
            true
        else
            flash.now[:alert] = "お名前を入力してね"
            false
        end
    end

    def after_update_path_for(resource)
        flash[:notice] = "OK！きみは、#{resource.name}さんだね！"
        myindex_posts_path
    end

end
