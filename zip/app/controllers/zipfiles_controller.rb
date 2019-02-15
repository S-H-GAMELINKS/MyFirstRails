class ZipfilesController < ApplicationController

    def index
        @zipfiles = Zipfile.all
    end

    def create
        @zip = Zipfile.new(zipfile_params)
        @zip.save!
        redirect_to :root
    end

    private

        def zipfile_params
            params.require(:zipfile).permit(:file)
        end
end
  