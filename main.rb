require 'faraday'
require 'pry'
require 'open-uri'

MODPACK_ID = 95

# call get response
response = Faraday.get('https://api.modpacks.ch/public/modpack/95')
body = JSON.parse(response.body, symbolize_names: true)
id = body[:versions].sort { |v| v[:updated] }.first.fetch(:id) # get katest version id

file_name = "serverinstall_#{MODPACK_ID}_#{id}.sh"

`wget http://api.modpacks.ch/public/modpack/#{MODPACK_ID}/#{id}/server/linux -O server/#{file_name}`
`sudo chmod +x server/#{file_name}`
