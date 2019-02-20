class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def mastodon
      callback_from :mastodon
    end
  
    private
  
    def callback_from(provider)
      provider = provider.to_s
  
      @user = User.find_for_oauth(request.env['omniauth.auth'])
  
      if @user.persisted?
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: provider.capitalize)
        sign_in_and_redirect @user, event: :authentication
      else
        session["devise.#{provider}_data"] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end