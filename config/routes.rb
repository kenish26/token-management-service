Rails.application.routes.draw do
  post 'tokens/generate', to: 'tokens#generate'

  post 'tokens/assign', to: 'tokens#assign'

  post 'tokens/unblock', to: 'tokens#unblock'

  delete 'tokens/delete', to: 'tokens#delete'

  post 'tokens/keep_alive', to: 'tokens#keep_alive'
end
