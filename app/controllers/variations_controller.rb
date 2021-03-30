class VariationsController < ApplicationController
  def show
  end

  def destroy
    @variation = Variation.find(params[:id])
    @variation.image.purge
    @variation.destroy
    respond_to do |wants|
      wants.html { redirect_to(:controller=>'welcome',:action =>:index) }
      wants.xml  { head :ok }
    end
  end
  
  private
    def picture_params
      params.require(:variation).permit(:image)
    end
  
  
end
