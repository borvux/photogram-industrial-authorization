class PhotoPolicy < ApplicationPolicy
  attr_reader :user, :photo

  def initialize(user, photo)
    @user = user
    @photo = photo
  end

  def create?
    user.present?
  end

  def show?
    user == photo.owner ||
      !photo.owner.private? ||
      photo.owner.followers.include?(user)
  end

  def update?
    user == photo.owner
  end

  def destroy?
    user == photo.owner
  end

  class Scope < Scope
    def resolve
      # determines which photos appear in the index view
      # A user can see:
      #   1. all photos from public users
      #   2. all photos from private users that they follow
      #   3. all of their own photos
      scope.joins(:owner).where(owner: { private: false }).or(
      scope.joins(:owner).where(owner: user.leaders)).or(
      scope.where(owner: user)).distinct
    end
  end
end
