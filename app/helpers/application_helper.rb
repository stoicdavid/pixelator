module ApplicationHelper
  include MenuOptions
  
  def icon(icon, options = {})
    file = File.read("node_modules/bootstrap-icons/icons/#{icon}.svg")
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    if options[:class].present?
      svg['class'] += " " + options[:class]
    end
      doc.to_html.html_safe
  end
  
  def filter_menu(filter)
    render :partial => "layouts/application/#{filter}"
  end
  
  def button_icon(filter,image)
    capture do
      concat icon(image,class:"icon-2")
      concat tag.br
      concat filter.titleize
    end
  end
  
  def filter_icon(filter,image)
    form_tag path, :method => :post do
      button_tag do
        content_tag button_icon(filter,image), ''
      end
    end
  end
  
  def slider(position,max,step,reference,idx)
    content_tag(:div, class:"slider",:'data-slider'=>'',:'data-initial-start'=>position,:'data-step'=>step,:'data-end'=>max) do
      handler(reference,idx)
    end
  end
  
  def handler(reference,idx)
    capture do
      concat tag.span class:"slider-handle",:'data-slider-handle'=>'',role:'slider',tabindex:'1',:'aria-controls'=>reference,id:idx
      concat tag.span class:"slider-fill",:'data-slider-fill'=>'',id:idx
    end
  end
  
  
end
