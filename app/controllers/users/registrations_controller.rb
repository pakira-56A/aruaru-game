class Users::RegistrationsController < Devise::RegistrationsController
  # Deviseのデフォルトの`authenticate_user!`を使用
  prepend_before_action :authenticate_user!, only: [ :edit, :update ]

  protected

  def update_resource(resource, params)
    if resource.update_without_password(params)
      true
    else
      flash.now[:alert] = I18n.t("devise.registrations.edit.no_name")
      false
    end
  end

  def after_update_path_for(resource)
    flash[:notice] = I18n.t("devise.registrations.edit.update_success", name: resource.name)
    myindex_posts_path
  end
end
