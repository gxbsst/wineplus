module ProductsHelper
	
	def varieties(varieties)
		html = ''
		url = "/t/variety/"
		varieties.each do |v|
			html << (link_to v.origin_name, "#{url}#{v.name_en}") + " <span> #{v.percent}</span> <br />".html_safe
		end
		html
	end

	def link_to_region(regions)
		url ="/t/region"
		result = []
		urls = [url]
		regions.split(">").each  do |region| 
			urls << urls.last + "/" + region.to_url
			result << (link_to region.strip, "#{urls.last}")
		end
		result.join(" > ").html_safe
	end
end