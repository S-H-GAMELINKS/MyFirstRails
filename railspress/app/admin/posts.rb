ActiveAdmin.register Post do
    permit_params :title, :content, :auther, :date
    form do |f|
        f.inputs 'Article' do
          f.input :title
          f.input :content, as: :froala_editor
          f.input :auther
          f.input :date
        end
        f.actions
      end

end
