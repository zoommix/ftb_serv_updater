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
ver_dir = "versions/#{ver[:name]}"

`mkdir -p #{ver_dir} &&
  wget http://api.modpacks.ch/public/modpack/#{MODPACK_ID}/#{id}/server/linux -O #{ver_dir}/#{file_name} &&
  sudo chmod +x #{ver_dir}/#{file_name}`

PTY.spawn("cd #{ver_dir} && ./#{file_name}") do |reader, writer|
  writer.printf("\n")
  writer.printf("\n")
  writer.printf("\n")

  reader.each {|line| puts line}
rescue Errno::EIO
end
