module WatermarkFilters
  
  def apply_marca_agua2(im, phrase )
    
    
    text = Vips::Image.text(phrase, font:"Sans 12", width:500, align: :centre, dpi: 300)
    text = text.linear(0.3, 0).cast(:uchar)
    text = text.embed(100, 100, text.width + 200, text.height + 200, extend: :black)
    text = text.replicate(1 + im.width / text.width, 1 + im.height / text.height)
    text = text.extract_area(0, 0, im.width, im.height)

    #background = Vips::Image.black(1, 1, bands:3).linear([1,1,1], [255,0,0]).cast(:uchar)
    #background = background.embed(0, 0, im.width, im.height, extend: :mirror)

    # we make a constant colour image and attach the text mask as the alpha
    overlay = (text.new_from_image [255, 128, 128]).copy interpretation: :srgb
    overlay = overlay.bandjoin text

    # overlay the text
    #im = im.composite overlay, :over


    #return im.composite(background, :over)    
    return im.composite overlay, :over
  end
  
  def apply_marca_agua(im, phrase, rotation= -45,position='',alpha=1.0)
    
    
    # make the text mask
    text = Vips::Image.text phrase, width: 200, dpi: 200, font: "sans bold"
    text = text.rotate(rotation)
    # make the text transparent
    text = (text * 0.6).cast(:uchar)
    text = text.gravity :centre, 200, 200
    text = text.replicate 1 + im.width / text.width, 1 + im.height / text.height
    text = text.crop 0, 0, im.width, im.height

    # we make a constant colour image and attach the text mask as the alpha
    overlay = (text.new_from_image [255, 128, 128]).copy interpretation: :srgb
    overlay = overlay.bandjoin text

    # overlay the text
    return im.composite overlay, :over
  end
  
end