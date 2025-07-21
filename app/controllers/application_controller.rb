class ApplicationController < ActionController::Base
  include Pundit::Authorization

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  after_action :verify_authorization, unless: :devise_controller?

    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_user_search, if: -> { current_user.present? }
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_user_search
    @q = User.where.not(id: current_user.id).ransack(params[:q])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :private, :name, :bio, :website, :avatar_image ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :private, :name, :bio, :website, :avatar_image ])
  end

  private

    def verify_authorization
      if action_name == "index"
        verify_policy_scoped
      else
        verify_authorized
      end
    end

    def user_not_authorized
      flash[:alert] = "PUNDIT: You are not authorized to perform this action."
      
      redirect_back fallback_location: root_url
    end
end
