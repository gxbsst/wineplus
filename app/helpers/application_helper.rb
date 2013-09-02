module ApplicationHelper

  def taxons_tree(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    content_tag :ul, class: 'taxons-list' do
      root_taxon.children.map do |taxon|
        css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
        content_tag :li, class: css_class do
          link_to(taxon.name, seo_url(taxon)) +
          taxons_tree(taxon, current_taxon, max_level - 1)
        end
      end.join("\n").html_safe
    end
  end

  def region_tree
    root_taxon = Spree::Taxon.find_by_name('region')
    #current_taxon = Spree::Taxon.find_by_name('')
    taxons_tree(root_taxon,  @taxon, max_level = 1)
  end

  def style_tree
    root_taxon = Spree::Taxon.find_by_name('style')
    taxons_tree(root_taxon, @taxon, max_level = 1)
  end

  def variety_tree
    root_taxon = Spree::Taxon.find_by_name('variety')
    current_taxon =  @taxon
    content_tag :ul, class: 'taxons-list' do

      root_taxon.children.limit(40).map do |taxon|
        css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
        content_tag :li, class: css_class do
          link_to(taxon.name, seo_url(taxon)) +
          taxons_tree(taxon, current_taxon, 0)
        end
      end.join("\n").html_safe
    end
  end

  def link_to_taxon(taxon_name)
    taxon = Spree::Taxon.find_by_name(taxon_name)
    seo_url(taxon)
  end


  def link_to_my_cart(text = nil)
    #return "" if current_spree_page?(spree.cart_path)

    text = text ? h(text) : Spree.t('cart')
    css_class = nil

    if current_order.nil? or current_order.line_items.empty?
      text = "#{text}: (#{Spree.t('empty')})"
      css_class = 'empty'
    else
      text = "#{text}: (#{current_order.item_count})  <span class='amount'>#{current_order.display_total}</span> <a class='checkout' href='/cart'>Checkout</a>".html_safe
      css_class = 'full'

    end

    link_to text, spree.cart_path, :class => "cart-info #{css_class}"
  end

  def full_address(address)
    "#{address.firstname}#{address.lastname}, #{address.address1},    #{address.city}, #{address.state}, #{address.country}"
  end

  def ship_mehtod_to_text(shipments)
    ship_methods = []
    shipping_rates =  shipments.collect(&:shipping_rates).flatten
    unless shipping_rates.blank?
      shipping_rates.select{|i| i.selected}.inject({}) do |h, i|
        h[:method_name] = i.shipping_method.name
        h[:cost] = i.cost.to_f
        ship_methods << h
        h = {}
      end
    end
    ship_methods
  end

  def custom_display_price(product_or_variant)
    product_or_variant.price_in(current_currency).display_price
  end
end
