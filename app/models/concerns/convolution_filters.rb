module ConvolutionFilters
    def apply_alto_contraste(im)
      # Alto Contraste - Se conviere a escala de grises y luego se cambia cada pixel mayor a 127 en 255 eoc 0
      im = (im[0]*0.3+im[1]*0.59+im[2]*0.11)
      return (im > 127).ifthenelse(255,0)
    end

    def apply_inverso(im)
      # Inverso - Se conviere a escala de grises y luego se cambia cada pixel mayor a 127 en 0 eoc 255
      im = im.bandand
      return (im > 127).ifthenelse(0,255)
    end
    
    def apply_mica_rgb(im,c_rgb)
      #Componente RGB - Se obtienen los parametros capturados por el usuario
      r = c_rgb.split(' ',3)[0]
      g = c_rgb.split(' ',3)[1]
      b = c_rgb.split(' ',3)[2]      
      # se crea una mica con los valores de RGB correspondientes
      mica = im.new_from_image [r.to_i,g.to_i,b.to_i]
      # Se aplica un 'and' con la imagen original y la mica
      return im.boolean(mica,:and)
      # se libera la memoria
      mica = nil
      r = g = b = nil
    end

    def apply_blur1(im)
      # Blur 1 - soft blur - Se crea matriz
      grid = Vips::Image.new_from_array [
          [0.0,0.2,0.0],
          [0.2,0.2,0.2],
          [0.0,0.2,0.0]
          ], 1
      #im = im.conv grid, precision: :integer --> Ver. VIPS
      # Se implementaron dos versiones de convolución una lenta y otra con optimizaciones aunque todavia puede mejorar
      #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS

      # version optimizada abajo version usando ImageMagick para leer pixeles
      #im = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
      return convolution3(grid,im)
      #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"memory=true")      
      grid = nil
    end

    def apply_blur2(im)
      # Blur 2 - mayor efecto - Se crea matriz
      grid = Vips::Image.new_from_array [
          [0,0,1,0,0],
          [0,1,1,1,0],
          [1,1,1,1,1],
          [0,1,1,1,0],
          [0,0,1,0,0]                              
          ], 13
          #im = im.conv grid, precision: :integer --> Ver. VIPS
          #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
          # abajo version usando ImageMagick para leer pixeles
          #im = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
          #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"")
      return convolution3(grid,im)
      grid = nil
    end
    
    def apply_motion_blur(im)
      # Motion Blur - mayor efecto - Se crea matriz      
      grid = Vips::Image.new_from_array [
          [1,0,0,0,0,0,0,0,0],
          [0,1,0,0,0,0,0,0,0],
          [0,0,1,0,0,0,0,0,0],
          [0,0,0,1,0,0,0,0,0],
          [0,0,0,0,1,0,0,0,0],
          [0,0,0,0,0,1,0,0,0],
          [0,0,0,0,0,0,1,0,0],
          [0,0,0,0,0,0,0,1,0],
          [0,0,0,0,0,0,0,0,1]                                                                                
          ], 9
          #im = im.conv grid, precision: :integer --> Ver. VIPS
          #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
          # abajo version usando ImageMagick para leer pixeles
          #sim = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
      return convolution3(grid,im)
          #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"")
          grid = nil
    end
    
    def apply_bordes(im)
      # Encontrar bordes - Se crea matriz
      grid = Vips::Image.new_from_array [
          [-1,0,0,0,0],
          [0,-2,0,0,0],
          [0,0,6,0,0],
          [0,0,0,-2,0],
          [0,0,0,0,-1]
          ], 1
          #im = im.conv grid, precision: :integer --> Ver. VIPS
          #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
          # abajo version usando ImageMagick para leer pixeles
          #im = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
          return convolution3(grid,im)
          #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"")                    
          grid = nil
    end
    
    def apply_sharpen(im)
      # Sharpen - Se crea matriz      
      grid = Vips::Image.new_from_array [
          [-1,-1,-1],
          [-1, 9,-1],
          [-1,-1,-1],
          ], 1
          #im = im.conv grid, precision: :integer --> Ver. VIPS
          #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
          # abajo version usando ImageMagick para leer pixeles
          #im = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
          return convolution3(grid,im)
          #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"")          
          grid = nil
    end
    
    def apply_emboss(im)
      # Emboss - Se crea matriz      
      grid = Vips::Image.new_from_array [
          [-1,-1,-1,-1,0],
          [-1,-1,-1,0, 1],
          [-1,-1,0, 1, 1],
          [-1,0, 1, 1, 1],
          [0, 1, 1, 1, 1]                    
          ], 1, 128
          #im = im.conv grid, precision: :integer --> Ver. VIPS
          #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
          # abajo version usando ImageMagick para leer pixeles
          #im = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
          return convolution3(grid,im)
          #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"")
          grid = nil
    end

  
  # Abajo el método de convolución lento
  def convolution(grid,image)
    # Se obtiene la matriz para la convolucion y se obtienen sus caracteristicas
    # mfilter - la matrix en arreglo
    # offset - el desplazamiento del pixel central - tamaño de la matriz entre dos
    # filter_width y filter_height - alto y ancho de la matriz
    mfilter = grid.to_a
    offset = mfilter.length / 2
    filter_width = mfilter[0].length
    filter_height = mfilter.length
    
    # Pasa el arreglo a matriz para facilitar su manipulación
    mgrid = Matrix.build(filter_width,filter_height) {|row,col| grid.to_a.reverse[row][col][0]}
    # Crea imagen igual que la imagen a tratar con un borde de 0s tan amplio como el offset del filtro
    pad_image = image.embed(offset,offset,image.width+offset*2,image.height+offset*2)
    # alto y ancho de la nueva imagen
    iheight = pad_image.height-filter_height+1
    iwidth = pad_image.width-filter_width+1

    # Iterador para realizar la convolución con cada área de la imagen
    new_im = Enumerator.new do |ni|
      (iheight).times do |y|
        (iwidth).times do |x|
          #obtiene area del mismo tamaño que el filtro a aplicar
          rgb = pad_image.extract_area(x,y,filter_width,filter_height).bandsplit.map {|color| color.to_a}
          # realiza la convolución iterando con el filtro, multiplicando entrada a entrada y aplicando los factores.
          new_pixel = rgb.map do |color|
            m = Matrix.build(filter_width, filter_height) {|row,col| color[row][col][0]}
              calc = ((1/grid.scale) * (m.hadamard_product(mgrid).to_a.flatten.reduce(&:+)) + grid.offset).clamp (0..255)
            end
          rgb=nil
          # se almancena cada nuevo pixel en un arreglo
          ni << new_pixel
          new_pixel = nil
        end
      end
    end
    # se crea imagen con los nuevos pixeles y se regresa
    return MiniMagick::Image.get_image_from_pixels(new_im.collect { |element| element}, [image.width,image.height], 'rgb', 8 ,'jpg')
  end
  

  # Abajo el método de convolución optimizado aunque puede mejorar  
  def convolution2(grid)

    # Se obtiene la matriz para la convolucion y se obtienen sus caracteristicas
    # mfilter - la matrix en arreglo
    # offset - el desplazamiento del pixel central - tamaño de la matriz entre dos
    # filter_width y filter_height - alto y ancho de la matriz
    mfilter = grid.to_a
    offset = mfilter.length / 2
    filter_width = mfilter[0].length
    filter_height = mfilter.length
    mgrid = Matrix.build(filter_width,filter_height) {|row,col| grid.to_a[row][col][0]}    

    # Pasa el arreglo a matriz para facilitar su manipulación
    o_image = MiniMagick::Image.open ActiveStorage::Blob.service.send(:path_for, picture.image.key)
    # obtiene pixeles de la imagen
    o_pixels = o_image.get_pixels
    # recorre los pixeles de la imagen
    out = []
    (o_image.height).times do |y|
      new_pix = []
      (o_image.width).times do |x|       
        red = green = blue = 0
        mgrid.each_with_index do |fpix,row,col|
          # coordenadas en la imagen conforme el filtro
          pix = x + (offset-col)
          piy = y + (offset-row)

          # condicion para evitar los bordes en la imagen
          if( piy.between?(0,o_image.height-1) && pix.between?(0,o_image.width-1))
            #aplica la convolucion
            red += o_pixels[piy][pix][0] * fpix
            green += o_pixels[piy][pix][1] * fpix
            blue += o_pixels[piy][pix][2] * fpix
          end
        end
        # aplica los factores de la convolucion y limita a 0 o 255 
        red = ((1/grid.scale) * red + grid.offset).clamp (0..255)
        green = ((1/grid.scale) * green + grid.offset).clamp (0..255)
        blue = ((1/grid.scale) * blue + grid.offset).clamp (0..255)
        new_pix << [red,green,blue]
      end
      out << new_pix
    end
    o_pixels = nil
    new_pix = nil
    # regresa la imagen generada
    return MiniMagick::Image.get_image_from_pixels(out, [o_image.width,o_image.height], 'rgb', 8 ,'jpg')
    out = nil
  end

  def convolution3(grid,image)

    # Se obtiene la matriz para la convolucion y se obtienen sus caracteristicas
    # mfilter - la matrix en arreglo
    # offset - el desplazamiento del pixel central - tamaño de la matriz entre dos
    # filter_width y filter_height - alto y ancho de la matriz
    mfilter = grid.to_a
    offset = mfilter.length / 2
    filter_width = mfilter[0].size
    filter_height = mfilter.size
    mgrid = Matrix.build(filter_width,filter_height) {|row,col| grid.to_a.reverse[row][col][0]}    
    pad_image = image.embed(offset,offset,image.width+(offset*2),image.height+(offset*2),extend: :mirror)
    # alto y ancho de la nueva imagen
    iheight = image.height
    iwidth = image.width
    piwidth = pad_image.width

    # recorre los pixeles de la imagen
    out = []
    iheight.times do |y|
      #new_pix = []
      rgb = pad_image.extract_area(0,y,pad_image.width,filter_height).to_a
      iwidth.times do |x|
        red = green = blue = 0       
        mgrid.each_with_index do |fpix,row,col|
          # coordenadas en la imagen conforme el filtro
          #piy = y + offset
          pix = (x + col) % piwidth
          #puts "#{pix}"
          #rgb = rgb.zip(rgb[piy][pix].map {|e| e * fpix}).map {|pair|pair.reduce(&:+)}
          red += rgb[row][pix][0] * fpix
          green += rgb[row][pix][1] * fpix
          blue += rgb[row][pix][2] * fpix
          #puts "rgb: #{rgb[row][pix]}, red:#{red}, green:#{green}, blue:#{blue} "
        end

        # aplica los factores de la convolucion y limita a 0 o 255 
        # new_pix = rgb.map{|color|((1/grid.scale) * color * grid.offset).clamp (0..255)}
        red = ((1/grid.scale) * red + grid.offset).clamp (0..255)
        green = ((1/grid.scale) * green).clamp (0..255)
        blue = ((1/grid.scale) * blue + grid.offset).clamp (0..255)
        out << [red,green,blue]
      end
      #out << new_pix.flatten.pack('C*')
      #new_pix = nil
    end

    # regresa la imagen generada
    #return MiniMagick::Image.get_image_from_pixels(out, [image.width,image.height], 'rgb', 8 ,'jpg')
    logger.info "#{iwidth}, #{out.size}, #{out[0].size}"
    return Vips::Image.new_from_memory out.flatten.pack("C*"), image.width, image.height, image.bands, image.format
    out = nil
  end
end