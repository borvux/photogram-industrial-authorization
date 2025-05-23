class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]
  # before_action :is_an_authorized_user, only: [:create]
  # before_action :is_a_comment_author, only: [:destroy, :update, :edit]
  before_action :authorize_comment_action, only: [:create, :destroy, :update, :edit]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.author = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_back fallback_location: root_path, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to root_url, notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # # users should only be able to comment on photos in the app if they are following the user or the user is public or it's their photos
  # def is_an_authorized_user
  #   # we don’t want to be looking at the owner of the comment! we want the owner of the photo that is being commented on
  #   @photo = Photo.find(params.fetch(:comment).fetch(:photo_id))
  #   if current_user != @photo.owner && @photo.owner.private? && !current_user.leaders.include?(@photo.owner)
  #     redirect_back fallback_location: root_url, alert: "You're not authorized for that"
  #   end
  # end

  # def is_a_comment_author
  #   if current_user != @comment.author
  #     redirect_back fallback_location: root_url, alert: "You're not authorized for that"
  #   end
  # end

  # combining is_an_authorized_user and is_a_comment_author
  def authorize_comment_action
    case action_name
    when "create"
      # creation, we check if the user is allowed to comment on the photo.
      @photo = Photo.find(params.fetch(:comment).fetch(:photo_id))
      unless current_user == @photo.owner || !@photo.owner.private? || current_user.leaders.include?(@photo.owner)
        redirect_back fallback_location: root_url, alert: "You're not authorized for that"
      end
    when "edit", "update", "destroy"
      # editing/updating/destroying, we verify the user is the comment's author.
      unless current_user == @comment.author
        redirect_back fallback_location: root_url, alert: "You're not authorized for that"
      end
    end
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:author_id, :photo_id, :body)
  end
end
