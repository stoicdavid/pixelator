class PicturesController < ApplicationController


  # GET /pictures
  # GET /pictures.xml
  def index

  #  @picture = Picture.first || Picture.new
  #  if @picture.image.attached?
  #    @picture.variations.build
  #  end
  #  
  #  if @picture.variations.exists?
  #    @variation = @picture.variations.find_by(id:params[:id]) || @picture.variations.last(2).first
  #  end
  #  
  #  respond_to do |wants|
  #    wants.html # index.html.erb
  #    wants.xml  { render :xml => @pictures }
  #  end
  
  @pictures = Picture.all
  
  end

  # GET /pictures/1
  # GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id]) || Picture.first
    @variation = @picture.variations.last
  end

  # GET /pictures/new
  # GET /pictures/new.xml
  def new
    @picture = Picture.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @picture }
    end
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.xml
  def create

    @picture = Picture.create(params.require(:picture).permit(:image))

    respond_to do |wants|
      if @picture.save!
        #puts "***********PROCESA THUMBNAIL************"
        #ImageProcessing::Vips
        #  .source(ActiveStorage::Blob.service.send(:path_for, @picture.image.key))
        #  .resize_to_fill!(400, 400,crop: :attention)
        #  .call!
        #puts "***********THUMBNAIL PROCESADO************"          
        #flash[:notice] = 'La imagen fue cargada exitosamente.'
        #wants.html { redirect_to(:controller=>'welcome',:action =>:index) }
        wants.html { redirect_to @picture, notice: 'La imagen fue cargada exitosamente.' }
        wants.xml  { render :xml => @picture, :status => :created, :location => @picture }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pictures/1
  # PUT /pictures/1.xml
  def update
    @picture = Picture.find params[:id]
    variation = @picture.variations.build(picture_params)
    filter = params[:commit]
    bright = params[:picture][:variation][:bright_param]
    mwidth = params[:picture][:variation][:mwidth_param]
    mheight = params[:picture][:variation][:mheight_param] 
    r = params[:picture][:variation][:red]
    g = params[:picture][:variation][:green]
    b = params[:picture][:variation][:blue]
    phrase = params[:picture][:variation][:phrase]
    rotation = !params[:picture][:variation][:rotation].to_i.zero?
    repeat = !params[:picture][:variation][:repeat].to_i.zero?
    alpha = params[:picture][:variation][:alpha].to_f / 100
    coorext = params[:picture][:variation][:coorext]
    color = !params[:picture][:variation][:color].to_i.zero? 
    semitone = params[:picture][:variation][:semitone]
    maxmin = params[:picture][:variation][:maxmin].to_i
    
    variation.component(r,g,b) if filter == 'Mica RGB'
    variation.pdi_filter(filter,bright,mwidth,mheight,variation.rgb,phrase,rotation,repeat,alpha,coorext,color,semitone,maxmin)

    respond_to do |wants|
      if @picture.update(picture_params)
        #flash[:notice] = "El filtro #{filter} fue aplicado exitosamente."
        #wants.html { redirect_to(:controller=>'welcome',:action =>:index,:id=> variation.id) }
        wants.html { redirect_to @picture, notice: "El filtro #{filter} fue aplicado exitosamente"}
        wants.xml  { head :ok }
      else
        #wants.html { redirect_to(:controller=>'welcome',:action =>:index)}
        #wants.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
        wants.html { render :edit, status: :unprocessable_entity }
        wants.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.xml
  def destroy
    @picture = Picture.find(params[:id])
    @picture.image.purge
    @picture.destroy

    respond_to do |wants|
      #wants.html { redirect_to(:controller=>'welcome',:action =>:index) }
      wants.html {redirect_to pictures_url, alert: "Product was successfully destroyed."}
      wants.xml  { head :ok }
    end
  end

  private
    def find_picture
      @picture = Picture.find(params[:id])
    end

    def picture_params
      params.require(:picture).permit(:image, {:variations_attributes => :filter_type})
    end

end
