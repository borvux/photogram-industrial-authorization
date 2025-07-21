class LikePolicy < ApplicationPolicy
  attr_reader :user, :like

  def initialize(user, like)
    @user = user
    @like = like
  end

  def create?
    user.present? # or PhotoPolicy.new(user, like.photo).show?
  end

  def destroy?
    user == like.fan
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
