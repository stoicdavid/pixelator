module BasicFilters
  def apply_gray1(im)
      # Promedio de los tres colores r,g,b
      return (im[0]+im[1]+im[2])/3
  end
  
  def apply_gray2(im)
    # Aplicando factores a cada color 
    return (im[0]*0.3+im[1]*0.59+im[2]*0.11)
  end
  
  def apply_gray3(im)
    # Aplicando factores a cada color      
    return (im[0]*0.2126+im[1]*0.7152+im[2]*0.0722)
  end
  
  def apply_gray4(im)
    # punto medio entre el máximo y mínimo de R,G,B
    return ([im[0],im[1],im[2]].max+[im[0],im[1],im[2]].min) / 2
  end
  
  def apply_gray5(im)
    # Descomposición por el máximo
    return [im[0],im[1],im[2]].max
  end
  
  def apply_gray6(im)
    # Descomposición por el mínimo
    return [im[0],im[1],im[2]].min
  end
  
  def apply_gray7(im)
    # Escala de grises tomando solo el rojo
    return im[0]
  end
  
  def apply_gray8(im)
    # Escala de grises tomando solo el azul      
    return im[1]
  end
  
  def apply_gray9(im)
    # Escala de grises tomando solo el verde       
    return im[2]
  end
  
  def apply_brillo(im, bright)
    # Brillo sumado a cada banda aplicando la transformacion lineal [r,g,b] *[1,1,1] + [c,c,c]
    self[:bright_param] = bright
    return im.linear [1,1,1], [bright,bright,bright]

  end

  def apply_mosaico(im,horizontal,vertical)
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (10..im.width/2)
    hstep = vertical.to_i.clamp (10..im.height/2)
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
    
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
    return im.mutate do |result| 
      (0...result.height-hstep).step(hstep).each do |h|
        (0...result.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          ravg = s.getpoint(4,1) [0]
          gavg = s.getpoint(4,2) [0]
          bavg = s.getpoint(4,3) [0]
          # Se aplica el promedio a toda el area en la nueva imagen
          result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true
        end
      end
    end
  end
end