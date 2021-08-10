module MaxMinFilters
  
  def apply_max_min(im,maxmin)
    # Blur 2 - mayor efecto - Se crea matriz
    grid = Vips::Image.new_from_array [
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0]
        ], 1
        #im = im.conv grid, precision: :integer --> Ver. VIPS
        #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
        # abajo version usando ImageMagick para leer pixeles
        #im = Vips::Image.new_from_buffer(convolution2(grid).to_blob,"")
        #im = Vips::Image.new_from_buffer(convolution3(grid,im).to_blob,"")
    return convolution4(grid,im,maxmin)
    grid = nil
  end
  
  def convolution4(grid,image,maxmin)

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
    operator = ['>', '<']
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
          red = rgb[row][pix][0] + fpix if red.send(operator[maxmin],rgb[row][pix][0])
          if pad_image.bands > 1
            green = rgb[row][pix][1] + fpix if green.send(operator[maxmin],rgb[row][pix][1])
            blue = rgb[row][pix][2] + fpix if blue.send(operator[maxmin],rgb[row][pix][2])
          end
          #puts "rgb: #{rgb[row][pix]}, red:#{red}, green:#{green}, blue:#{blue} "
        end

        # aplica los factores de la convolucion y limita a 0 o 255 
        # new_pix = rgb.map{|color|((1/grid.scale) * color * grid.offset).clamp (0..255)}
        red = ((1/grid.scale) * red + grid.offset).clamp (0..255)
        if pad_image.bands > 1
          green = ((1/grid.scale) * green).clamp (0..255)
          blue = ((1/grid.scale) * blue + grid.offset).clamp (0..255)
          out << [red,green,blue]
        else
          out << [red]
        end
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