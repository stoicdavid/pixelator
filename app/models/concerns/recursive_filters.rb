module RecursiveFilters
    
  
  def apply_imagenes_recursivas(im, horizontal, vertical, color)
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (5..im.width/2)
    hstep = vertical.to_i.clamp (5..im.height/2)
    origin = nil
    array = nil    
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
    if color
      origin = im
      #mini_origin = Vips::Image.thumbnail_image(origin,wstep,height: hstep)
      mini_origin = origin.resize 0.1
    else
      origin = apply_gray3(im) if im.bands >1
      origin = im if im.bands == 1
      images = create_images(origin)
    end
      
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen  
      (0...origin.height-hstep).step(hstep).each do |h|
        if color
          temp = mini_origin
          mica = temp.new_from_image [255,255,255]
          temp = temp.boolean(mica,:and)
        else
          temp = Vips::Image.new_from_file(select_image(255,images)).resize(0.1)
        end
        (0...origin.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = origin.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          ravg = s.getpoint(4,1) [0]
          gavg = s.getpoint(4,2) [0] if color_avg.bands > 1
          bavg = s.getpoint(4,3) [0] if color_avg.bands > 2
          
          #Se unen las múltiples imágenes
          unless color
            temp = temp.join(Vips::Image.new_from_file(select_image(ravg,images)).resize(0.1),:horizontal)
          else
            mica = mini_origin.new_from_image [ravg,gavg,bavg] 
            temp = temp.join(mini_origin.boolean(mica,:and),:horizontal)
          end
        end
          array = temp if h == 0
          array = array.join(temp, :vertical)
          temp = nil
      end
      return array
      array = nil
  end
  
  def create_images(image)
    images = {}
    scale = 0
    (-255..255).step(15) do |idx|
      im = image
      im = im.linear([1], [idx])
      if idx == -255
        scale = 0
      else
        scale += 7
      end
      
      filename = "app/assets/images/recursivas/#{scale}.jpg"
      im.write_to_file filename
      images[idx] = filename
    end
    return images
  end
  
  def select_image(color,images)
    color = color.clamp(0..255)
    return images[images.keys.bsearch{|x| x>= color}]
  end
  
end