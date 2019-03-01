require 'capybara/rails'
require 'capybara/minitest'

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def heavens_door
    scenario 'GENERATED' do
        visit '/posts'
    
        click_link 'New Post'
    
        fill_in 'Title', with: 'test'
        fill_in 'Content', with: 'aaaaaaaaaaaaaaaaaaaaaaaaa'
        click_button 'Create Post'
    
        click_link 'Back'
    end
  end
end