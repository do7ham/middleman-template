module CustomHelpers
  # Breadcrumbs
  # ==============================
  def get_breadcrumbs(home = 'Home')
    current_page_data = current_page
    hierarchy = [current_page_data]
    hierarchy.unshift hierarchy.first.parent while hierarchy.first.parent
    breadcrumbs = current_page_data.metadata[:page]['breadcrumbs']
    list = []
    hierarchy.each_with_index do |page, index|
      title =
      if breadcrumbs.blank?
        page.data.title
      else
        breadcrumbs[index - 1]
      end
      list <<
      case index
      when 0
        content_tag(:li, link_to(home, '/'), class: 'breadcrumb-item')
      when hierarchy.size - 1
        content_tag(:li, title, class: 'breadcrumb-item active', 'aria-current' => 'page')
      else
        content_tag(:li, link_to(title, '/'), class: 'breadcrumb-item')
      end
    end
    list.join.html_safe
  end
  # host_url
  # ==============================
  def host_url(url)
    data.site.url + url
  end
end
