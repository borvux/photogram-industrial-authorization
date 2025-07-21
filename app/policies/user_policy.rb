class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def show?
    true
  end

  def feed?
    user == current_user
  end

  def discover?
    feed?
  end

  def show_photos?
    user == current_user ||
     !user.private? || 
     user.followers.include?(current_user)
  end

  def liked?
    show_photos?
  end

  class Scope < Scope
    def resolve
      # anyone can search for any other user.
      scope.all
    end
  end
end
