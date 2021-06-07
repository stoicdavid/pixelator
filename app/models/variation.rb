class Variation < ApplicationRecord
  FILTER_TYPES = ['Gray1', 'Gray2','Gray3', 'Gray4','Gray5', 'Gray6','Gray7', 'Gray8','Gray9', 'Brillo', 'Mosaico','Alto Contraste','Inverso','Componente RGB','Blur1','Blur2','Motion Blur','Bordes','Sharpen','Emboss']
  attr_accessor :variations_attributes
  belongs_to :picture
  has_one_attached :image
  validates :mwidth_param,  numericality: {greater_than: 0}, allow_nil: true
  validates :mheight_param,  numericality: {greater_than: 0}, allow_nil: true
  
  # metodo para obtener los filtros de convolucion y mostrarlos en la vista
  def self.convolution_filters
    FILTER_TYPES[14..19]
  end
  # metodo para acceder al color rojo
  def red
    rgb.split(' ',3)[0] if rgb
  end

  # metodo para asignar el color rojo
  def red=(r)
    if rgb.nil? && r.present?
      self.rgb << r 
    else
      a = self.rgb.split(' ',3)
      a[0] = r
      self.rgb = a.join(' ')
    end
  end

  # metodo para acceder al color verde  
  def green
    rgb.split(' ',3)[1]
  end
  
  # metodo para asignar el color verde    
  def green=(g)
    if rgb.nil? && g.present?
      self.rgb << '0 ' + g 
    else
      a = self.rgb.split(' ',3)
      a[1] = g
      self.rgb = a.join(' ')
    end
  end
  # metodo para acceder al color azul
  def blue
    rgb.split(' ',3)[2]
  end
  
  # metodo para asignar el color azul
  def blue=(b)
    if rgb.nil? && g.present?
      self.rgb << '0 0 ' + g 
    else
      a = self.rgb.split(' ',3)
      a[2] = b
      self.rgb = a.join(' ')
    end
  end

  # metodo para asignar el componente r,g,b
  def component(r,g,b)
    self.rgb = [r,g,b].join(' ') if rgb.nil?
  end
  

  
  
  def pdi_filter(filter_asked, bright = 0, horizontal = 0, vertical = 0, c_rgb = '0 0 0')
    
    # Método para aplicar filtros básicos o filtros de convolución
    # Se obtiene el método solicitiado de entre los disponibles en la constante FILTER_TYPES
    
    filter_applied = FILTER_TYPES.index(filter_asked)
    
    # Se determina el tipo de acceso a la imágen ya sea random o sequential
    # sequential es mas rápido pero para imagenes con muchos pixeles puede no funcionar
    
    filter_applied == 10 ? access = :random : access = :sequential
    
    
    # se obtiene la imagen cargada en el modelo Picture
    im = Vips::Image.new_from_file ActiveStorage::Blob.service.send(:path_for, picture.image.key), access: :sequential
    # Configuración de algunos parametros obtenidos desde el controlador
    bright = bright.to_i
    
    # Se elimina el canal alpha de la imágen para operar solo con r,g,b
    alpha = nil
    if im.has_alpha?
      alpha = im.bandsplit[3] 
      im = im.flatten background: 255
    end
    
    #Se aplica el filtro correspondiente, para el caso de escalas de grises, todas las imágenes pasan de 3 bandas de color a una banda
    
    case filter_applied
    when 0
      # Promedio de los tres colores r,g,b
      im = (im[0]+im[1]+im[2])/3
    when 1
      # Aplicando factores a cada color 
      im = (im[0]*0.3+im[1]*0.59+im[2]*0.11)
    when 2
      # Aplicando factores a cada color      
      im = (im[0]*0.2126+im[1]*0.7152+im[2]*0.0722)
    when 3
      # punto medio entre el máximo y mínimo de R,G,B
      im = ([im[0],im[1],im[2]].max+[im[0],im[1],im[2]].min) / 2
    when 4
      # Descomposición por el máximo
      im = [im[0],im[1],im[2]].max
    when 5
      # Descomposición por el mínimo
      im = [im[0],im[1],im[2]].min
    when 6
      # Escala de grises tomando solo el rojo
      im = im[0]
    when 7
      # Escala de grises tomando solo el azul      
      im = im[1]
    when 8
      # Escala de grises tomando solo el verde       
      im = im[2]
    when 9
      # Brillo sumado a cada banda aplicando la transformacion lineal [r,g,b] *[1,1,1] + [c,c,c]
      im = im.linear [1,1,1], [bright,bright,bright]
      self[:bright_param] = bright

    when 10
      # Mosaico - Se obtienen los valores del rectangulo o cuadrado a generar
      # Por default se limitan a 10 hasta la mitad de la imagen
      wstep = horizontal.to_i.clamp (10..im.width/2)
      hstep = vertical.to_i.clamp (10..im.height/2)
      
      # Iteracion en toda la imagen para obtener los mosaicos
      # se utiliza el método mutate de ruby-vips para aplicar los cambios sobre la imagen
      im = im.mutate do |result| 
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
      self[:mwidth_param] = horizontal
      self[:mheight_param] = vertical

    when 11
      # Alto Contraste - Se conviere a escala de grises y luego se cambia cada pixel mayor a 127 en 255 eoc 0
      im = (im[0]*0.3+im[1]*0.59+im[2]*0.11)
      im = (im > 127).ifthenelse(255,0)
    when 12
      # Inverso - Se conviere a escala de grises y luego se cambia cada pixel mayor a 127 en 0 eoc 255
      im = im.bandand
      im = (im > 127).ifthenelse(0,255)
    when 13
      #Componente RGB - Se obtienen los parametros capturados por el usuario
      r = c_rgb.split(' ',3)[0]
      g = c_rgb.split(' ',3)[1]
      b = c_rgb.split(' ',3)[2]      
      # se crea una mica con los valores de RGB correspondientes
      mica = im.new_from_image [r.to_i,g.to_i,b.to_i]
      # Se aplica un 'and' con la imagen original y la mica
      im = im.boolean(mica,:and)
      # se libera la memoria
      mica = nil
      r = g = b = nil
    when 14
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
      im = convolution3(grid,im)
      grid = nil
    when 15
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
          im = convolution3(grid,im)
          grid = nil
    when 16
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
          im = convolution3(grid,im)
          grid = nil
    when 17
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
          im = convolution3(grid,im)
          grid = nil
    when 18
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
          im = convolution3(grid,im)
          grid = nil
    when 19                        
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
          im = convolution3(grid,im)
          grid = nil
    else
    end

    # Finalmente se envia a guarda el filtro correspondiente en la base de datos
    variant_save(im,alpha,filter_asked)
    
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
    pad_image = image.embed(offset,offset,image.width+(offset*2),image.height+(offset*2))
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
    puts "#{image.width}, #{image.height}, #{image.bands}"

    return Vips::Image.new_from_memory out.flatten.pack("C*"),image.width,image.height,image.bands,image.format
    out = nil
  end

  
  #Método para regresar el alpha a la imagen, si es que tenia uno y guardarla en base de datos anexandola por medio de Active Storage.
  def variant_save(im,alpha=nil,filter_asked='')
    filext = nil    
    
    if !alpha.nil? 
      filext = ".png"
      im = im.bandjoin(alpha)
    else
      filext = ".jpg"
    end
    suffix = filter_asked.empty? ? 'support' : filter_asked
    filename = "#{im.filename.to_s.split('.').first}_#{suffix}"+filext
    #im.pngsave "app/assets/images/#{filename}"
    #result = ImageProcessing::Vips.source(im)
    self[:filter_type] = filter_asked
    #image.attach(io: File.open(Rails.root.join('app','assets','images',"#{filename}")), filename:'#{filename}.jpg',content_type:'image/jpg')
    if im.bands==2 || im.has_alpha?
      puts "#{alpha.width}, #{alpha.height}, #{alpha.bands}"
      image.attach(io: StringIO.new(im.pngsave_buffer), filename:filename, content_type:'image/png')
    else
      image.attach(io: StringIO.new(im.jpegsave_buffer), filename:filename, content_type:'image/jpeg')
    end
    im = nil
  end
  
  
end