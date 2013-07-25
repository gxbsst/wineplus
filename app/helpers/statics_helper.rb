module StaticsHelper
	def link_to_static(text, url, action_name)
		current = action_name == url.gsub('/', '') ? 'current4' : ''
		link_to text, url, :class => current
	end
end