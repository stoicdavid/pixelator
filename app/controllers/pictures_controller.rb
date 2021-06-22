class PicturesController < ApplicationController


  # GET /pictures
  # GET /pictures.xml
  def index
    @picture = Picture.first || Picture.new

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @pictures }
    end
  end

  # GET /pictures/1
  # GET /pictures/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @picture }
    end
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
        flash[:notice] = 'La imagen fue cargada exitosamente.'
        wants.html { redirect_to(:controller=>'welcome',:action =>:index) }
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
    filter = ''
    if Variation.convolution_filters.include? params[:picture][:variation][:filter_type]
        filter = params[:picture][:variation][:filter_type]
      else
        filter = params[:commit]        
    end
    
    bright = params[:picture][:variation][:bright_param]
    mwidth = params[:picture][:variation][:mwidth_param]
    mheight = params[:picture][:variation][:mheight_param] 
    r = params[:picture][:variation][:red]
    g = params[:picture][:variation][:green]
    b = params[:picture][:variation][:blue]

    variation.component(r,g,b) if filter == 'Mica RGB'
    variation.pdi_filter(filter,bright,mwidth,mheight,variation.rgb)

    respond_to do |wants|
      if @picture.update(picture_params)
        flash[:notice] = "El filtro #{filter} fue aplicado exitosamente."
        wants.html { redirect_to(:controller=>'welcome',:action =>:index,:id=> variation.id) }
        wants.xml  { head :ok }
      else
        wants.html { redirect_to(:controller=>'welcome',:action =>:index)}
        wants.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
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
      wants.html { redirect_to(:controller=>'welcome',:action =>:index) }
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
