class ZipfilesController < ApplicationController
    def create
        @zip = Zipfile.new(zipfile_params)
        @zip.save!
        redirect_to :root
    end

    private

        def zipfile_params
            params.require(:zip).permit(:file)
        end
end
  