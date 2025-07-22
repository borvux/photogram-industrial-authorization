class UsersController < ApplicationController
  before_action :set_user, only: %i[ show liked feed discover ]
  # before_action :ensure_current_user, only: [:feed, :discover]

  def index
    # @users = @q.result
    @users = policy_scope(@q.result)
  end

  def show
    authorize @user
  end

  def liked
    authorize @user
  end

  def feed
    authorize @user
  end

  def discover
    authorize @user
  end

  private

  def set_user
    if params[:username]
      @user = User.find_by!(username: params.fetch(:username))
    else
      @user = current_user
    end
  end

  # def ensure_current_user
  #   if current_user != @user
  #     redirect_back fallback_location: root_url, alert: "You're not authorized for that"
  #   end
  # end
end
