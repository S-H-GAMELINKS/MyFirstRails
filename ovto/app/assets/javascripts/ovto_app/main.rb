require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
    item :count, default: 0
  end

  class Actions < Ovto::Actions
    def add_count(state:, count:)
        return {count: state.count + count}
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Hello Ruby on Rails & Ovto!'
        o 'input', type: 'button', onclick: ->(e){ actions.add_count(count: 1) }, value: 'Sum'
        o 'p', state.count
      end
    end
  end
end

MyApp.run(id: 'ovto')