module LetterFilters
  include BasicFilters
  include ActionView::Helpers::TagHelper
  

  
  def apply_una_letra(im,horizontal,vertical)
    
    
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (10..im.width/2)
    hstep = vertical.to_i.clamp (10..im.height/2)
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
    
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      html_image = ""
      (0...im.height-hstep).step(hstep).each do |h|
        html_line = ""
        (0...im.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          ravg = s.getpoint(4,1) [0]
          gavg = s.getpoint(4,2) [0]
          bavg = s.getpoint(4,3) [0]
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true
          
          html_line << tag.span('M', style:"color:rgba(#{ravg},#{gavg},#{bavg},1)")
          
        #  helper.capture do
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #  end
        end
        html_image << tag.p(html_line.html_safe, style:"margin:0px; line-height:14px")
        #html_image << tag.br(style:"display:block; margin-bottom: -.4em", type)
      end
      return html_image
  end
  
  def apply_letra_gris(im,horizontal,vertical)
    
    
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (10..im.width/2)
    hstep = vertical.to_i.clamp (10..im.height/2)
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
    
    im = apply_gray3(im)
    
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      html_image = ""
      (0...im.height-hstep).step(hstep).each do |h|
        html_line = ""
        (0...im.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          ravg = s.getpoint(4,1) [0]
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true
          
          html_line << tag.span('M', style:"color:rgba(#{ravg},#{ravg},#{ravg},1)")
          
        #  helper.capture do
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #  end
        end
        html_image << tag.p(html_line.html_safe, style:"margin:0px; line-height:14px")
        #html_image << tag.br(style:"display:block; margin-bottom: -.4em", type)
      end
      return html_image
  end
  
  
  def apply_simula_grises(im,horizontal,vertical)
    GC.start
    allocated_before = GC.stat(:total_allocated_objects)
    freed_before = GC.stat(:total_freed_objects)
    mem = GetProcessMem.new
    puts "Memory usage before: #{mem.mb} MB."


    
    im = apply_gray3(im)
    
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      html_image = "<pre>"
      (0...im.height).lazy.each do |h|
        html_line = ""
        gray_values = im.extract_area(0,h,im.width,1).to_a
        (0...im.width).lazy.each do |w|

          # Se obtiene el promedio del area deseada por cada banda de color
          pixel_value = im.getpoint(w,h)
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true
          char = gray_char(pixel_value)
          html_line << tag.span(char).freeze
          #html_line << char
        #  helper.capture do
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #  end
        end
        html_image << tag.p(html_line.html_safe, style:"margin:0px; line-height:14px").freeze
        html_line = nil
        #html_image << html_line
        #html_image << '\n'
        #html_image << tag.br(style:"display:block; margin-bottom: -.4em", type)
      end
      html_image << "</pre>"
      
      mem = GetProcessMem.new
      puts "Memory usage after: #{mem.mb} MB."
      GC.start
      allocated_after = GC.stat(:total_allocated_objects)
      freed_after = GC.stat(:total_freed_objects)
      puts "Total objects allocated: #{allocated_after - allocated_before}"
      puts "Total objects freed: #{freed_after - freed_before}"
      return html_image
      html_image = nil
  end
  
  def apply_16_colores(im,horizontal,vertical)
    
    
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (10..im.width/2)
    hstep = vertical.to_i.clamp (10..im.height/2)
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
  
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      html_image = "<pre>"
      (0...im.height-hstep).step(hstep).each do |h|
        html_line = ""
        (0...im.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          rchar = s.getpoint(4,1) [0]
          gchar = s.getpoint(4,2) [0]
          bchar = s.getpoint(4,3) [0]
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true  
          values = [rchar,gchar,bchar]
          avg = values.sum / values.size.to_f  
          char = gray_char(avg)  
          html_line << tag.span(char, style:"color:rgba(#{rchar},#{gchar},#{bchar},1)")
          #html_line << char
        #  helper.capture do
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #  end
        end
        html_image << tag.p(html_line.html_safe, style:"margin:0px; line-height:14px")
        #html_image << html_line
        #html_image << '\n'
        #html_image << tag.br(style:"display:block; margin-bottom: -.4em", type)
      end
      html_image << "</pre>"
      return html_image
  end
  
  
  def apply_16_grises(im,horizontal,vertical)
    
    
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (10..im.width/2)
    hstep = vertical.to_i.clamp (10..im.height/2)
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
  
    im = apply_gray3(im)
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      html_image = "<pre>"
      (0...im.height-hstep).step(hstep).each do |h|
        html_line = ""
        (0...im.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color

          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          ravg = s.getpoint(4,1) [0]
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true
          
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true  
          char = gray_char(ravg)  
          html_line << tag.span(char, style:"color:rgba(#{ravg},#{ravg},#{ravg},1)")
          #html_line << char
        #  helper.capture do
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #  end
        end
        html_image << tag.p(html_line.html_safe, style:"margin:0px; line-height:14px")
        #html_image << html_line
        #html_image << '\n'
        #html_image << tag.br(style:"display:block; margin-bottom: -.4em", type)
      end
      html_image << "</pre>"
      return html_image
  end
  
  def apply_letrero(im,horizontal,vertical,letrero='')
    
    
    # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
    # Por default se limitan a 10 hasta la mitad de la imagen
    wstep = horizontal.to_i.clamp (10..im.width/2)
    hstep = vertical.to_i.clamp (10..im.height/2)
    self[:mwidth_param] = wstep
    self[:mheight_param] = hstep
  
    # Iteracion en toda la imagen para obtener los mosaicos
    # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      html_image = "<pre>"
      idx=0
      (0...im.height-hstep).step(hstep).each do |h|
        html_line = ""
        
        (0...im.width-wstep).step(wstep).each do |w|
          # Se obtiene el area deseada del tamaño del rectangulo
          color_avg = im.extract_area(w,h,wstep,hstep)
          # Se obtiene el promedio del area deseada por cada banda de color
          s = color_avg.stats
          rchar = s.getpoint(4,1) [0]
          gchar = s.getpoint(4,2) [0]
          bchar = s.getpoint(4,3) [0]
          # Se aplica el promedio a toda el area en la nueva imagen
          #result.draw_rect! [ravg,gavg,bavg],w,h,wstep,hstep, fill: true  
          letrero = 'Ridiculous is perfectly safe '
          charset = letrero.split('')
          html_line << tag.span(charset[idx % charset.length], style:"color:rgba(#{rchar},#{gchar},#{bchar},1)")

          #html_line << char
        #  helper.capture do
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #    helper.concat helper.tag.span 'M', style:"color:rgba(1,2,2,0)"
        #  end
        idx += 1
        end
        html_image << tag.p(html_line.html_safe, style:"margin:0px; line-height:14px")
        #html_image << html_line
        #html_image << '\n'
        #html_image << tag.br(style:"display:block; margin-bottom: -.4em", type)
      end
      html_image << "</pre>"
      return html_image
  end
  
  def gray_char(pixel)
    
    chars = {
      0..15 => 'M',
      16..31 => 'N',
      32..47 => 'H',
      48..63 => '#',
      64..79 => 'Q',
      80..95 => 'U',
      96..111 => 'A',
      112..127 => 'D',
      128..143 => '0',
      144..159 => 'Y',
      160..175 => '2',
      176..191 => '$',
      192..209 => '%',
      210..225 => '+',
      226..239 => '.',
      240..255 => " "
    }
    if pixel.kind_of?(Array)
      return chars.select{ |chars| chars === pixel[0].to_i}.values.first
    else
      return chars.select{ |chars| chars === pixel.to_i}.values.first
    end
  end
  
  
end