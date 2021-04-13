class Variation < ApplicationRecord
  FILTER_TYPES = ['Gray1', 'Gray2','Gray3', 'Gray4','Gray5', 'Gray6','Gray7', 'Gray8','Gray9', 'Brillo', 'Mosaico','Alto Contraste','Inverso','Componente RGB','Blur1','Blur2','Motion Blur','Bordes','Sharpen','Emboss']
  attr_accessor :variations_attributes
  belongs_to :picture
  has_one_attached :image
  validates :mwidth_param,  numericality: {greater_than: 0}, allow_nil: true
  validates :mheight_param,  numericality: {greater_than: 0}, allow_nil: true
  
  
  def self.convolution_filters
    FILTER_TYPES[14..19]
  end

  def red
    rgb.split(' ',3)[0] if rgb
  end
  
  def red=(r)
    if rgb.nil? && r.present?
      self.rgb << r 
    else
      a = self.rgb.split(' ',3)
      a[0] = r
      self.rgb = a.join(' ')
    end
  end
  
  def green
    rgb.split(' ',3)[1]
  end
  
  def green=(g)
    if rgb.nil? && g.present?
      self.rgb << '0 ' + g 
    else
      a = self.rgb.split(' ',3)
      a[1] = g
      self.rgb = a.join(' ')
    end
  end
  
  def blue
    rgb.split(' ',3)[2]
  end
  
  def blue=(b)
    if rgb.nil? && g.present?
      self.rgb << '0 0 ' + g 
    else
      a = self.rgb.split(' ',3)
      a[2] = b
      self.rgb = a.join(' ')
    end
  end
  
  def component(r,g,b)
    self.rgb = [r,g,b].join(' ') if rgb.nil?
  end
  

  
  
  def pdi_filter(filter_asked, bright = 0, horizontal = 0, vertical = 0, c_rgb = '0 0 0')
    filter_applied = FILTER_TYPES.index(filter_asked)
    filter_applied == 10 || filter_applied >= 14 ? access = :random : access = :sequential
    im = Vips::Image.new_from_file ActiveStorage::Blob.service.send(:path_for, picture.image.key), access: access
    bright = bright.to_i
    alpha = nil
    if im.has_alpha?
      alpha = im.bandsplit[3] 
      im = im.flatten background: 255
    end
    
    case filter_applied
    when 0
      im = (im[0]+im[1]+im[2])/3
    when 1
      im = (im[0]*0.3+im[1]*0.59+im[2]*0.11)
    when 2
      im = (im[0]*0.2126+im[1]*0.7152+im[2]*0.0722)
    when 3
      im = ([im[0],im[1],im[2]].max+[im[0],im[1],im[2]].min)/2
    when 4
      im = [im[0],im[1],im[2]].max
    when 5
      im = [im[0],im[1],im[2]].min
    when 6
      im = im[0]
    when 7
      im = im[1]
    when 8
      im = im[2]
    when 9
      im = im.linear [1,1,1], [bright,bright,bright]
      self[:bright_param] = bright

    when 10
      
      wstep = horizontal.to_i.clamp (10..im.width/2)
      hstep = vertical.to_i.clamp (10..im.height/2)
      
        
      result = im.new_from_image [0,0,0]
      (0...im.height-hstep).step(hstep).each do |h|
        mline = []
        (0...im.width-wstep).step(wstep).each do |w|
          #puts "#{h} , #{w}"
          area = im.extract_area(w,h,wstep,hstep)
          s = area.stats
          ravg = s.getpoint(4,1) [0]
          gavg = s.getpoint(4,2) [0]
          bavg = s.getpoint(4,3) [0]
          r,g,b = area.bandsplit
          r = r.linear [0], [ravg]
          g = g.linear [0], [gavg]
          b = b.linear [0], [bavg]
          mline << r.bandjoin(g).bandjoin(b)
        end
        if h == 0
          result = Vips::Image.arrayjoin(mline)
        else
          result = result.join Vips::Image.arrayjoin(mline), :vertical
        end
          mline = nil
      end
      im = result
      result = nil
      self[:mwidth_param] = horizontal
      self[:mheight_param] = vertical

    when 11
        im = (im[0]*0.3+im[1]*0.59+im[2]*0.11)
       im = (im > 127).ifthenelse(255,0)
    when 12
      im = im.bandand
      im = (im > 127).ifthenelse(0,255)
    when 13
      r = c_rgb.split(' ',3)[0]
      g = c_rgb.split(' ',3)[1]
      b = c_rgb.split(' ',3)[2]      
      mica = im.new_from_image [r.to_i,g.to_i,b.to_i]
      im = im.boolean(mica,:and)
      mica = nil
      r = g = b = nil
    when 14
      grid = Vips::Image.new_from_array [
          [0.0,0.2,0.0],
          [0.2,0.2,0.2],
          [0.0,0.2,0.0]
          ], 1
      #im = im.conv grid, precision: :integer --> Ver. VIPS
      #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
      # abajo version usando ImageMagick para leer pixeles
      im = Vips::Image.new_from_buffer(convolution2(grid,im).to_blob,"")
      grid = nil
    when 15
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
          im = Vips::Image.new_from_buffer(convolution2(grid,im).to_blob,"")
          grid = nil
    when 16
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
          im = Vips::Image.new_from_buffer(convolution2(grid,im).to_blob,"")
          grid = nil
    when 17
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
          im = Vips::Image.new_from_buffer(convolution2(grid,im).to_blob,"")
          grid = nil
    when 18
      grid = Vips::Image.new_from_array [
          [-1,-1,-1],
          [-1, 9,-1],
          [-1,-1,-1],
          ], 1
          #im = im.conv grid, precision: :integer --> Ver. VIPS
          #im = Vips::Image.new_from_buffer(convolution(grid,im).to_blob,"") --> Ver. only VIPS
          # abajo version usando ImageMagick para leer pixeles
          im = Vips::Image.new_from_buffer(convolution2(grid,im).to_blob,"")
          grid = nil
    when 19                        
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
          im = Vips::Image.new_from_buffer(convolution2(grid,im).to_blob,"")
          grid = nil
    else
    end
    
    variant_save(im,alpha,filter_asked)
    
  end
  

  def convolution(grid,image)
        
    mfilter = grid.to_a
    offset = mfilter.length / 2
    filter_width = mfilter[0].length
    filter_height = mfilter.length
    
    mgrid = Matrix.build(filter_width,filter_height) {|row,col| grid.to_a.reverse[row][col][0]}
    pad_image = image.embed(offset,offset,image.width+offset*2,image.height+offset*2)
    iheight = pad_image.height-filter_height+1
    iwidth = pad_image.width-filter_width+1

    new_im = Enumerator.new do |ni|
      (iheight).times do |y|
        (iwidth).times do |x|
          rgb = pad_image.extract_area(x,y,filter_width,filter_height).bandsplit.map {|color| color.to_a}
          new_pixel = rgb.map do |color|
            m = Matrix.build(filter_width, filter_height) {|row,col| color[row][col][0]}
              calc = ((1/grid.scale) * (m.hadamard_product(mgrid).to_a.flatten.reduce(&:+)) + grid.offset).clamp (0..255)
            end
          rgb=nil
          ni << new_pixel
          new_pixel = nil
        end
      end
    end
    return MiniMagick::Image.get_image_from_pixels(new_im.collect { |element| element}, [image.width,image.height], 'rgb', 8 ,'jpg')
  end
  
  
  def convolution2(grid,image)

    mfilter = grid.to_a
    offset = mfilter.length / 2
    filter_width = mfilter[0].length
    filter_height = mfilter.length
    mgrid = Matrix.build(filter_width,filter_height) {|row,col| grid.to_a[row][col][0]}
    o_image = MiniMagick::Image.open ActiveStorage::Blob.service.send(:path_for, picture.image.key)
    o_pixels = o_image.get_pixels
    
    out = []
    (o_image.height).times do |y|
      new_pix = []
      (o_image.width).times do |x|       
        red = green = blue = 0
        mgrid.each_with_index do |fpix,row,col|
          pix = x + (offset-col)
          piy = y + (offset-row)
          if( piy.between?(0,o_image.height-1) && pix.between?(0,o_image.width-1))
            red += o_pixels[piy][pix][0] * fpix
            green += o_pixels[piy][pix][1] * fpix
            blue += o_pixels[piy][pix][2] * fpix
          end
        end
        red = ((1/grid.scale) * red + grid.offset).clamp (0..255)
        green = ((1/grid.scale) * green + grid.offset).clamp (0..255)
        blue = ((1/grid.scale) * blue + grid.offset).clamp (0..255)
        new_pix << [red,green,blue]
      end
      out << new_pix
    end
    o_pixels = nil
    new_pix = nil
    return MiniMagick::Image.get_image_from_pixels(out, [o_image.width,o_image.height], 'rgb', 8 ,'jpg')
    out = nil
  end
  
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
      image.attach(io: StringIO.new(im.pngsave_buffer, background: 255), filename:filename, content_type:'image/png')
    else
      image.attach(io: StringIO.new(im.jpegsave_buffer), filename:filename, content_type:'image/jpeg')
    end
    im = nil
  end
  
  
end

#filterX = (x - filter_width / 2 + col + o_image.width ).abs.modulo(o_image.width)
#filterY = (y - filter_height / 2 + row + o_image.height ).abs.modulo(o_image.height)
#red += o_pixels[filterY * o_image.width + filterX]