ActiveAdmin.register Job do
    permit_params :title, :content

    form do |f|
        f.inputs 'Job' do
            f.input :title
            f.input :content, as:  :medium_editor, input_html: { data: { options: '{"spellcheck":false,"toolbar":{"buttons":["bold","italic","underline","anchor"]}}' } }
        end
        f.actions
    end
end
