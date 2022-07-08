require 'faraday'
require 'pry'
require 'pty'
require 'expect'

MODPACK_ID = 95

# call get response
response = Faraday.get('https://api.modpacks.ch/public/modpack/95')
body = JSON.parse(response.body, symbolize_names: true)
ver = body[:versions].sort { |v| v[:updated] }.first
id = ver.fetch(:id) # get latest version id

file_name = "serverinstall_#{MODPACK_ID}_#{id}.sh"
ver_dir = "versions/#{id}"

`wget http://api.modpacks.ch/public/modpack/#{MODPACK_ID}/#{id}/server/linux -O #{ver_dir}/#{file_name}`
`sudo chmod +x server/#{file_name}`
`mkdir -p #{ver_dir}`

PTY.spawn("./#{ver_dir}/#{file_name}") do |reader, writer|
  reader.expect(/Where would you like to install the server? [current directory]/)
  writer.puts
  reader.expect(/Path . already exists - still want to install? (y/n) [y]/)
  writer.puts
  reader.expect(/Continuing will install/)
  writer.puts
end
