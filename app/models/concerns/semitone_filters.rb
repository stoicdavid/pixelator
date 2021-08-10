
module SemitoneFilters
    
  
  def apply_semitonos(im, horizontal, vertical,semitone)
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (5..im.width/2)
    hstep = vertical.to_i.clamp (5..im.height/2)
    origin = nil
    array = nil    
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep

      origin = apply_gray3(im) if im.bands >1
      #origin = im if im.bands == 1
      images = semitone_images(semitone)
      puts "semitone #{semitone}"
      puts images

    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen  
      #return im.mutate do |result|
      (0...origin.height-hstep).step(hstep).each do |h|
        temp = Vips::Image.new_from_file(select_image2(255,images,semitone)).resize(0.03)
        (0...origin.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = origin.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          ravg = s.getpoint(4,1) [0]
          # result.draw_rect!([ravg,gavg],w,h,wstep,hstep, fill: true) if color_avg.bands > 1
          #result.draw_image!(Vips::Image.new_from_file(select_image(ravg,images)).bandand.resize(0.03),w,h) if color_avg.bands == 1
          temp = temp.join(Vips::Image.new_from_file(select_image2(ravg,images,semitone)).resize(0.03),:horizontal)
        end
        array = temp if h == 0
        array = array.join(temp, :vertical)
        temp = nil
      end
      #end
      return array
      array = nil
    end
  
  def semitone_images(semitone)
    images = {}
    ssize = (semitone == 'a' || semitone == 'b') ? 10 : 5 
    scale = ssize == 5 ? 50 : 25
    scale2 = ssize == 5 ? 255+50 : 255 +25
    (0...ssize).each do |idx|
      if semitone == 'a'
        index = idx + 1
        filename = "app/assets/images/semitonos/#{semitone+index.to_s}.jpg"
        images[((idx+1)*scale)+5] = filename
      else
        filename = "app/assets/images/semitonos/#{semitone+idx.to_s}.jpg"
        images[scale2 -= scale] = filename
        images[0] = "app/assets/images/semitonos/#{semitone+idx.to_s}.jpg"
      end
    end
    return images.sort.to_h
  end
  
  def select_image2(color,images,semitone)
    color = color.clamp(0..255)
    return images[images.keys.bsearch{|x| x>= color}]
  end
  
end