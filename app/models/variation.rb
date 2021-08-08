class Variation < ApplicationRecord
  include BasicFilters, ConvolutionFilters, LetterFilters, WatermarkFilters, RecursiveFilters, SemitoneFilters
  
  FILTER_TYPES = ['Gray1', 'Gray2','Gray3', 'Gray4','Gray5', 'Gray6','Gray7', 'Gray8','Gray9', 'Brillo', 'Mosaico',
    'Alto Contraste','Inverso','Mica RGB','Blur1','Blur2','Motion Blur','Bordes','Sharpen','Emboss',
    'Una Letra','Letra Gris','Simula Grises','16 Colores','16 Grises','Letrero','Domino Blancas','Domino Negras','Naipes',
    'Imagenes Recursivas',
    'Semitonos',
    'Max Min',
    'Dither Ordenado','Dither Disperso','Dither Random',
    'Foto Mosaico']
  SEMITONES = {'a' =>'img4.idx', 'b'=>'img10.idx','c'=>'img2.idx'}
  attr_accessor :variations_attributes
  belongs_to :picture
  has_one_attached :image
  validates :mwidth_param,  numericality: {greater_than: 0}, allow_nil: true
  validates :mheight_param,  numericality: {greater_than: 0}, allow_nil: true
  
  # metodo para obtener los filtros de convolucion y mostrarlos en la vista
  def self.convolution_filters
    FILTER_TYPES[14..19]
  end
  
  def big?
    Variation::FILTER_TYPES[22].include? self.filter_type
  end
  
  def positioning(x,y,w,h)
    self.coorext = [x,y,w,h].join(' ') if coorext.nil?
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
  

  def semitone_type
    'a'
  end
  
  def semitone_type=(type)
    @semitone = type
  end
  
  
  def pdi_filter(filter_asked, bright = 0, horizontal = 0, vertical = 0, c_rgb = '0 0 0', phrase = '', rotation=false, repeat=false,transparent=1.0, coordinates='', color=false,semitone='a')
    
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
    im_html = []
    #Se aplica el filtro correspondiente, para el caso de escalas de grises, todas las imágenes pasan de 3 bandas de color a una banda
    case filter_asked
    when "Brillo"
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, bright)
    when "Mosaico"
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, horizontal, vertical)
    when "Mica RGB"
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, c_rgb)
    when "Una Letra", "Letra Gris","Simula Grises", "16 Colores", "16 Grises", "Letrero", "Domino Blancas", "Domino Negras", "Naipes"
      im_html << self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, horizontal, vertical)
    when "Marca Agua"
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, phrase,rotation,repeat,transparent,coordinates)
    when "Imagenes Recursivas"
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, horizontal, vertical,color)
      #im.write_to_file "pre123.jpg"
    when "Semitonos"
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im, horizontal, vertical,semitone)
      #im.write_to_file "pre123.jpg"
    else
      im = self.send("apply_#{filter_asked.parameterize(separator:'_')}", im)
    end
    
    # Finalmente se envia a guarda el filtro correspondiente en la base de datos
    if im_html.empty?
      variant_save(im,alpha,filter_asked)
    else
      filext =".html"
      suffix = filter_asked.empty? ? 'support' : filter_asked
      filename = "#{im.filename.to_s.split('.').first}_#{suffix}"+filext
      image.attach(io: StringIO.new(im_html.join('')), filename:filename, content_type:'text/html')
      self[:filter_type] = filter_asked
      im_html = []
    end
    
  end
  
  

  
  #Método para regresar el alpha a la imagen, si es que tenia uno y guardarla en base de datos anexandola por medio de Active Storage.
  def variant_save(im,alpha=nil,filter_asked='')
    filext = nil    
    
    if !alpha.nil? && !(['Imagenes Recursivas','Semitonos'].include? filter_asked)
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
      logger.info "Imagen con alpha: #{im.width}, #{im.height}, #{im.bands},#{filename}"
      image.attach(io: StringIO.new(im.write_to_buffer ".png"), filename:filename, content_type:'image/png')
    else
      image.attach(io: StringIO.new(im.jpegsave_buffer), filename:filename, content_type:'image/jpeg')
    end
    im = nil
  end
  
  
end