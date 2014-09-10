class TrimLinksController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  # before_action :set_trim_link, only: [:show, :destroy]


  def create
    accepted_formats = [".tr5"]
    @pq = Pq.find(trim_link_params[:pq_id])
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
      if accepted_formats.include? File.extname(filename)
        data = uploaded_io.read
        size = data.size
        @trim_link = TrimLink.new(:data => data, :filename => filename, :size => size, :pq_id => trim_link_params[:pq_id])
        if @trim_link.save
          # flash.now[:success] = 'Trim link was successfully created.'
          result[:message]='Trim link was successfully created.'
          result[:status]='success'
          result[:link]=url_for trim_link_path(@trim_link)
        else
          # flash.now[:error] = "Could not add Trim link. #{@trim_link.errors}"
          result[:message]="Could not add Trim link. #{@trim_link.errors}"
        end
      else
        # flash.now[:error] = 'Could not add Trim link. File must be tr5'
        result[:message]='Could not add Trim link. File must be tr5'
      end
    end
    # respond_to do |format|
    #   format.html  { return render :partial => 'shared/trim_links', :locals => {question: @pq}}
    #   format.json  { return render :json => result.as_json }
    # end
    #return render :partial => 'shared/trim_links', :locals => {question: @pq}
    return render json: result.as_json
  end

  def show
    @upload = TrimLink.find(params[:id])
    @data = @upload.data
    send_data(@data, :type => 'application/json', :filename => @upload.filename, :disposition => 'download')
  end

  def destroy
    result = {
        :message => '',
        :status => 'failure',
        :link => ''
    }

    @trim_link = TrimLink.find(params[:id])
    my_pq = @trim_link.pq


    if @trim_link.delete
      result[:message]='Trim link Deleted.'
      result[:status]='success'
    else
      result[:message]='Trim link Delete Failed please contact support.'
    end

    return render json: result.as_json
  end
  def set_trim_link
    @trim_link = TrimLink.find(params[:id])
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def trim_link_params
      params.require(:trim_link).permit(:file_data, :pq_id)
    end
end
