#! /usr/bin/env ruby

require 'optparse'
require 'erb'
require 'pdfkit'

######################################################################
## METHODS
#####################################################################
def load_set(file_path)
	set = []
	header = []
	counter = 0
	File.open(file_path).each do |line|
		fields = line.chomp.split("\t")
		if counter == 0
			header = fields
		else
			card = {}
			header.each_with_index do |h, i|
				card[h] = fields[i]
			end
			set << card
		end
		counter += 1
	end
	return set
end

def generate_cardset(set, template, output, wkhtmltopdf_bin)
	string = File.open(template).read
	renderer = ERB.new(string)
	renderer.result(binding)

	html_file = output + '.html'
	File.open(html_file, 'w'){|f| f.print(renderer.result())}
	PDFKit.configure do |config|
		if !wkhtmltopdf_bin.nil?
	  		config.wkhtmltopdf = wkhtmltopdf_bin
		end
		config.default_options = {
			margin_top: '0.1in',
			margin_bottom: '0.1in',
			margin_right: '0.1in',
			margin_left: '0.1in'
		}
  		config.verbose = true
  	end
	kit = PDFKit.new(File.new(html_file))
	kit.to_file(output + '.pdf')
end

def ins_img(card_attr)
	return File.join('..', 'img',  card_attr)
end

######################################################################
## OPTPARSE
#####################################################################

options = {}
OptionParser.new do |parser|
	options[:set] = nil
	parser.on("-s", "--set STRING", "Name of the set to be generated") do |item|
		options[:set] = item
	end

	options[:template] = nil
	parser.on("-t", "--template STRING", "Template to use in the set generation") do |item|
		options[:template] = item
	end

	options[:wkhtmltopdf_bin] = nil
	parser.on("-w", "--wkhtmltopdf_bin PATH", "Path for html to pdf converter") do |item|
		options[:wkhtmltopdf_bin] = item
	end

end.parse!

######################################################################
## MAIN
#####################################################################

set = load_set(File.join('sets', options[:set]))
generate_cardset(
	set, 
	File.join('templates', options[:template]) + '.erb', 
	File.join('output', options[:set]),
	options[:wkhtmltopdf_bin]
)