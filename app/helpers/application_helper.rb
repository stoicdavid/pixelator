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
  

  
  
end
