class TrimLinksController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def create
    result = {
        :message => '',
        :status => 'failure',
        :link => ''
    }
    if trim_link_params[:file_data].nil?
      flash[:error] = 'Please select a trim file (.tr5) before trying to add'
    else
      uploaded_io = trim_link_params[:file_data]
      filename = uploaded_io.original_filename
      if ['.tr5'].include? File.extname(filename)
        data = uploaded_io.read
        @trim_link = TrimLink.new(:data => data, :filename => filename, :size => data.size, :pq_id => trim_link_params[:pq_id])
        if @trim_link.save
          result = {
              :message => 'Trim link was successfully created.',
              :status => 'success',
              :link => "#{url_for trim_link_path(@trim_link)}"
          }
        else
          result[:message]="Could not add Trim link. #{@trim_link.errors}"
        end
      else
        result[:message]='Could not add Trim link. File must be tr5'
      end
    end
    return render json: result.as_json
  end

  def show
    @upload = TrimLink.find(params[:id])
    @data = @upload.data
    send_data(@data, :type => 'application/json', :filename => @upload.filename, :disposition => 'download')
  end

private

  def trim_link_params
    params.require(:trim_link).permit(:file_data, :pq_id)
  end
end
