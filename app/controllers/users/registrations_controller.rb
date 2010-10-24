class Users::RegistrationsController < Devise::RegistrationsController
  # Overrides the Devise registration controller for post-processing the user after they register
 
  # POST /resource/sign_up
  def create
    build_resource

    if resource.save
      group = Group.obfuscated(params[:group_id])
      resource.group_id = group.id unless group.nil?
      resource.has_role! :experimenter
      resource.save
      if resource.active?
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      else
       # set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s #Bug? - Devise 1.13.0 Dpitman, 10/28
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
  
  protected
  
      # The path used after sign up. You need to overwrite this method
    # in your own RegistrationsController.
    def after_sign_up_path_for(resource)
      after_sign_in_path_for(resource)
    end
  
# The path used after sign up for inactive accounts. You need to overwrite
    # this method in your own RegistrationsController.
    def after_inactive_sign_up_path_for(resource)
      root_path
    end

    # The default url to be used after updating a resource. You need to overwrite
    # this method in your own RegistrationsController.
    def after_update_path_for(resource)
      if defined?(super)
        ActiveSupport::Deprecation.warn "Defining after_update_path_for in ApplicationController " <<
          "is deprecated. Please add a RegistrationsController to your application and define it there."
        super
      else
        after_sign_in_path_for(resource)
      end
    end
  
end
