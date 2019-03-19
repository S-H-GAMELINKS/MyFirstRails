require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
  end

  class Actions < Ovto::Actions
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Hello Ruby on Rails & Ovto!'
      end
    end
  end
end

MyApp.run(id: 'ovto')