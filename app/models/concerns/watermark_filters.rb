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
  
  def apply_marca_agua(im, phrase, rotation=true,repeat=true,transparent=1.0,coor='')
    
    rot = rotation ? -45 : 0

    text_width = rotation ? im.height : im.width
    
    text_dpi = im.width
    puts coor
    if repeat
      text_width = text_width / 2
      text_dpi = text_dpi / 2
    end
    
    iw = im.width
    ih = im.height
    
    if !coor.empty?
      iw = coor.split(' ')[1].to_i
      ih = coor.split(' ')[3].to_i  
    end
    
    extension = text_width/2
    
    # Crea el texto
    text = Vips::Image.text phrase, width: extension, dpi: text_dpi, font: "sans bold"
    text = text.rotate(rot)
    # Aplicar transparencia
    text = (text * transparent).cast(:uchar)

    if repeat
      text = text.gravity :centre, extension, extension
      text = text.replicate 1 + im.width / text.width, 1 + im.height / text.height
      text = text.crop 0, 0, im.width, im.height
    else
      puts iw, ih
      text = text.gravity :centre, iw, ih
    end

    # Crear una imagen con el texto
    overlay = (text.new_from_image [255, 128, 128]).copy interpretation: :srgb
    overlay = overlay.bandjoin text

    # Sobreponer el texto
    return im.composite overlay, :over
    # return im.flatten background: 255
  end
  
end