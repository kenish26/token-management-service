class TokensController < ApplicationController
  before_action :set_token_service

  def generate
    tokens = @token_service.generate_tokens(params[:count].to_i)
    render json: { tokens: tokens }, status: :ok
  end

  def assign
    token = @token_service.assign_token
    if token
      render json: { token: token }, status: :ok
    else
      render json: { error: 'No available tokens' }, status: :not_found
    end
  end

  def unblock
    if @token_service.unblock_token(params[:token_id])
      render json: { message: 'Token unblocked' }, status: :ok
    else
      render json: { error: 'Token not found or not allocated' }, status: :not_found
    end
  end

  def delete
    if @token_service.delete_token(params[:token_id])
      render json: { message: 'Token deleted' }, status: :ok
    else
      render json: { error: 'Token not found' }, status: :not_found
    end
  end

  def keep_alive
    if @token_service.keep_alive(params[:token_id])
      render json: { message: 'Token kept alive' }, status: :ok
    else
      render json: { error: 'Token not found or not allocated' }, status: :not_found
    end
  end

  private

  def set_token_service
    @token_service = TokenService.new
  end
end
