require 'rexml/document'
require 'net/http'
require 'uri'

url = URI.parse('http://gist.github.com/api/v1/xml/new')


name = ENV['SNIPPET_EXPORT_FILENAME']

puts "Uploading: #{name}"

description = ENV['SNIPPET_NAME']
login = ENV['GIST_LOGIN']
token = ENV['GIST_API_TOKEN']
prv = ENV['GIST_IS_PRIVATE'] == '1'
snippet = ENV['SNIPPET_SOURCE_CODE']

data = {
    'login' => login,
    'token' => token,
    'description' => description,
    "files[#{name}]" => snippet
}

if prv
    data.merge({ 'action_button' => 'private' })
end

response = Net::HTTP.post_form(url, data)

doc = REXML::Document.new(response.body)
gist = REXML::XPath.first(doc, "/gists/gist/repo/text()")

unless gist
    raise "Failed to upload snippet: " << name
end

snippet_url = "http://gist.github.com/#{gist}"
puts "Snippet is successfully uploaded at #{snippet_url}"

ENV['GIST_SNIPPET_URL'] = snippet_url