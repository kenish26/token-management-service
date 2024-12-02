require 'redis'
require 'securerandom'

class TokenService
  AVAILABLE_TOKEN_EXPIRATION_TIME = 5 * 60 # 5 minutes
  ALLOCATED_TOKEN_EXPIRATION_TIME = 60 # 60 seconds for allocated tokens

  def initialize(redis = nil)
    @redis = redis || Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
  end

  def generate_tokens(count)
    count = count > 0 ? count : 1
    tokens = []

    count.times do
      token_id = SecureRandom.uuid
      add_token_to_available_pool(token_id)
      tokens << token_id
    end

    tokens
  end

  def assign_token
    cleanup_expired_tokens

    token_id = @redis.zpopmin(available_tokens_set_key, 1).first rescue nil

    return nil unless token_id # No available tokens

    @redis.setex(redis_key(token_id), ALLOCATED_TOKEN_EXPIRATION_TIME, 'allocated')
    token_id
  end

  def unblock_token(token_id)
    token_key = redis_key(token_id)

    if @redis.get(token_key) == 'allocated'
      @redis.del(token_key)
      add_token_to_available_pool(token_id) # Move token back to available pool
      true
    else
      false
    end
  end

  def delete_token(token_id)
    token_key = redis_key(token_id)

    del_response = @redis.del(token_key)

    return true if del_response && del_response > 0

    zrem_response = @redis.zrem(available_tokens_set_key, token_id)

    return true if zrem_response && zrem_response > 0

    false
  end


  def keep_alive(token_id)
    token_key = redis_key(token_id)

    if @redis.get(token_key) == 'allocated'
      @redis.expire(token_key, ALLOCATED_TOKEN_EXPIRATION_TIME)
      true
    else
      current_time = Time.now.to_i
      token_score = @redis.zscore(available_tokens_set_key, token_id)

      if token_score && token_score > current_time
        new_expiration_time = current_time + AVAILABLE_TOKEN_EXPIRATION_TIME
        @redis.zadd(available_tokens_set_key, new_expiration_time, token_id)
        true
      else
        false
      end
    end
  end


  private

  def add_token_to_available_pool(token_id)
    expiration_time = Time.now.to_i + AVAILABLE_TOKEN_EXPIRATION_TIME
    @redis.zadd(available_tokens_set_key, expiration_time, token_id)
  end

  def redis_key(token_id)
    "token:#{token_id}"
  end

  def available_tokens_set_key
    "tokens:available"
  end

  def cleanup_expired_tokens
    current_time = Time.now.to_i
    @redis.zremrangebyscore(available_tokens_set_key, '-inf', current_time - 1)
  end
end
