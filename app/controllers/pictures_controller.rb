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
      if @picture.save
        flash[:notice] = 'Picture was successfully created.'
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
    variation.pdi_filter(params[:picture][:variation][:filter_type])
    respond_to do |wants|
      if @picture.update(picture_params)
        flash[:notice] = 'Picture was successfully updated.'
        wants.html { redirect_to(:controller=>'welcome',:action =>:index) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.xml
  def destroy
    @picture.destroy

    respond_to do |wants|
      wants.html { redirect_to(pictures_url) }
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
