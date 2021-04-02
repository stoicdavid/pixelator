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
    filter_applied == 10 ? access = :random : access = :sequential
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
      if !im.has_alpha?
        im = im.linear [1,1,1], [bright,bright,bright]
      else
        im = im.linear [1,1,1,1], [bright,bright,bright,bright]
      end
      self[:bright_param] = bright

    when 10
      
      if (10..im.width/2).include?(horizontal.to_i)
        wstep = horizontal.to_i
      else 
        raise "Bad input" 
      end
      
      if (10..im.height/2).include?(vertical.to_i) 
        hstep = vertical.to_i
      else 
        raise "Bad input"
      end
        
      result = im.new_from_image [0,0,0]
      h = 0
      while h+hstep <= im.height
        mline = []
        w = 0
        while w+wstep <= im.width
          area = im.extract_area(w,h,wstep,hstep)
          s = area.stats
          ravg = s.getpoint(4,1) [0]
          gavg = s.getpoint(4,2) [0]
          bavg = s.getpoint(4,3) [0]
          r,g,b = area.bandsplit
          r = r.linear [0], [ravg]
          g = g.linear [0], [gavg]
          b = b.linear [0], [bavg]
          mosaic = r.bandjoin(g).bandjoin(b)
          mline << mosaic
          w += wstep
        end
        if h == 0
          result = Vips::Image.arrayjoin(mline)
        else
          result = result.join Vips::Image.arrayjoin(mline), :vertical
        end
          h += hstep
      end
      im = result
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
    when 14
      grid = Vips::Image.new_from_array [
          [0.0,0.2,0.0],
          [0.2,0.2,0.2],
          [0.0,0.2,0.0]
          ], 1
      im = im.conv grid, precision: :float
    when 15
      grid = Vips::Image.new_from_array [
          [0,0,1,0,0],
          [0,1,1,1,0],
          [1,1,1,1,1],
          [0,1,1,1,0],
          [0,0,1,0,0]                              
          ], 13
      im = im.conv grid, precision: :integer
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
      im = im.conv grid, precision: :integer
    when 17
      grid = Vips::Image.new_from_array [
          [-1,0,0,0,0],
          [0,-2,0,0,0],
          [0,0,6,0,0],
          [0,0,0,-2,0],
          [0,0,0,0,-1]
          ], 1
      im = im.conv grid, precision: :integer
    when 18
      grid = Vips::Image.new_from_array [
          [-1,-1,-1],
          [-1, 9,-1],
          [-1,-1,-1],
          ], 1
      im = im.conv grid, precision: :integer
    when 19                        
      grid = Vips::Image.new_from_array [
          [-1,-1,-1,-1,0],
          [-1,-1,-1,0, 1],
          [-1,-1,0, 1, 1],
          [-1,0, 1, 1, 1],
          [0, 1, 1, 1, 1]                    
          ], 1, 128
      im = im.conv grid, precision: :integer
    else
    end
    
    filext = nil    
    
    if !alpha.nil? 
      filext = ".png"
      im = im.bandjoin(alpha)
    else
      filext = ".jpg"
    end
    
    filename = "#{im.filename.to_s.split('.').first}_#{filter_asked}"+filext
    #im.pngsave "app/assets/images/#{filename}"
    #result = ImageProcessing::Vips.source(im)
    self[:filter_type] = filter_asked
    #image.attach(io: File.open(Rails.root.join('app','assets','images',"#{filename}")), filename:'#{filename}.jpg',content_type:'image/jpg')
    if im.bands==2 || im.has_alpha?
      image.attach(io: StringIO.new(im.pngsave_buffer, background: 255), filename:filename, content_type:'image/png')
    else
      image.attach(io: StringIO.new(im.jpegsave_buffer), filename:filename, content_type:'image/jpeg')
    end
    
  end
  

  
end
