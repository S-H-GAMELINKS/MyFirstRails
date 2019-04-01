ActiveAdmin.register Job do
    permit_params :title, :content

    index do
        column :id
        column :title

        actions defaults: true do |job|
        end
    end

    show do
        attributes_table do
            row :title
            row (:content) { |job| sanitize(job.content) }
        end
        active_admin_comments
    end

    form do |f|
        f.inputs 'Job' do
            f.input :title
            f.input :content, as:  :medium_editor, input_html: { data: { options: '{"spellcheck":false,"toolbar":{"buttons":["bold","italic","underline","anchor"]}}' } }
        end
        f.actions
    end
end
