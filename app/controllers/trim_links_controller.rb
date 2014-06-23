class TrimLinksController < ApplicationController
  before_action :authenticate_user!

  # GET /trim_links/new
  def new
    @pq = PQ.find_by(uin: params[:id])
    if @pq.nil?
      flash[:notice] = 'Question not found'
      redirect_to action: 'index', controller: 'dashboard'
    else
      @trim_link = TrimLink.new(:pq_id => @pq.id)
    end
  end

  # POST /trim_links
  # POST /trim_links.json
  def create
    accepted_formats = [".tr5"]

    uploaded_io = trim_link_params[:file_data]
    filename = uploaded_io.original_filename

    if accepted_formats.include? File.extname(filename)
      data = uploaded_io.read
      size = data.size

      @trim_link = TrimLink.new(:data => data, :filename => filename, :size => size, :pq_id => trim_link_params[:pq_id])
      respond_to do |format|
         if @trim_link.save
           format.html { redirect_to dashboard_url, notice: 'Trim link was successfully created.' }
           format.json { render action: 'index', status: :created, location: @trim_link }
         else
          format.html { render action: 'new' }
          format.json { render json: @trim_link.errors, status: :unprocessable_entity }
        end
       end
    else
      @trim_link = TrimLink.new(:pq_id => @pq.id)
      render action: 'new'
    end
  end

  def show
    @upload = TrimLink.find(params[:id])
   
    @data = @upload.data
    send_data(@data, :type => 'application/octect-stream', :filename => @upload.filename, :disposition => 'download')
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def trim_link_params
      params.require(:trim_link).permit(:file_data, :pq_id)
    end
end
