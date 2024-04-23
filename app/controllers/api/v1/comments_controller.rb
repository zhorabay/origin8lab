class Api::V1::CommentsController < ApplicationController
  before_action :set_api_comment, only: %i[show update destroy]

  def index
    @api_user = current_api_user
    @api_comments = Comment.all
    render_comments_json
  end

  def show
    render_comment_json
  end

  def create
    @api_user = current_api_user
    @api_comment = Comment.new(comment_params)
    if @api_comment.save
      render_comment_json(status: :created)
    else
      render json: { success: false, message: @api_comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @api_user = current_api_user
    if @api_comment.update(comment_params)
      render_comment_json
    else
      render json: { success: false, message: @api_comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @api_comment.destroy
      render json: { success: true, message: 'Comment deleted' }
    else
      render json: { success: false, message: @api_comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_api_comment
    @api_comment = Comment.find_by(id: params[:id])
    render_comment_not_found unless @api_comment
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def render_comments_json
    if @api_comments.present?
      render json: { success: true, comments: @api_comments }
    else
      render json: { success: false, message: 'No comments found' }
    end
  rescue StandardError => e
    render json: { success: false, message: e.message }
  end

  def render_comment_json(status: :ok)
    render json: { success: true, comment: @api_comment }, status:
  end

  def render_comment_not_found
    render json: { success: false, message: 'Comment not found' }, status: :not_found
  end
end
