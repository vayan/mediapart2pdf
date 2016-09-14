require 'mechanize'
require 'rss'
require 'optparse'

options = {}

OptionParser.new do |parser|
  parser.banner = 'Usage: mediapart2pdf.rb [options]'
  parser.on('-u', '--username USERNAME', 'Your account username') do |v|
    options[:username] = v
  end
  parser.on('-p', '--password PASSWORD', 'Your account password') do |v|
    options[:password] = v
  end
  parser.on('-o', '--output FOLDER', 'Specify folder output') do |v|
    options[:folder] = v
  end
  parser.on('-h', '--help', 'Show this help message') do
    puts parser
    exit
  end
end.parse!

raise OptionParser::MissingArgument if options[:username].nil? || options[:password].nil? || options[:folder].nil?

agent = Mechanize.new

agent.post('https://www.mediapart.fr/login_check', { 'name' => options[:username], 'password' => options[:password] })

rss_feed = agent.get('https://www.mediapart.fr/articles/feed')
feed = RSS::Parser.parse(rss_feed.body, false)
feed.items.each do |item|
  article_page = agent.get(item.link)
  filename = "#{options[:folder]}/#{item.title}.pdf"
  if File.file?(filename)
    puts "#{filename} already downloaded"
    next
  end
  puts "Downloading: #{item.title}"
  pdf = agent.get(article_page.link_with(text: 'Article en PDF').href)
  pdf.save(filename)
end
