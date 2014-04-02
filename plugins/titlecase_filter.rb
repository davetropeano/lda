module Jekyll
	module TitlecaseFilter
		def titlecase(input)
			input.titlecase
		end
	end
end

Liquid::Template.register_filter(Jekyll::TitlecaseFilter)
