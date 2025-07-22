class CommentPolicy < ApplicationPolicy
  attr_reader :user, :comment

  def initialize(user, comment)
    @user = user
    @comment = comment
  end

  def create?
    user.present? # or PhotoPolicy.new(user, like.photo).show?
  end

  def update?
    user == comment.author
  end

  def destroy?
    user == comment.author || user == comment.photo.owner
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
