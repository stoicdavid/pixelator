class WelcomeController < ApplicationController
  
  # GET /imageElements
  # GET /imageElements.xml
  def index
    @picture = Picture.first || Picture.new
    if @picture.image.attached?
      @picture.variations.build
    end
    
    if @picture.variations.exists?
      @variation = @picture.variations.find_by(id:params[:id]) || @picture.variations.last(2).first
    end
    
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @pictures }
    end
  end
  
  
end
