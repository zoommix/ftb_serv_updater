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
  sudo chmod +x #{ver_dir}/#{file_name} &&
  ln -s #{ENV['PWD']}/persisted/world #{ENV['PWD']}/#{ver_dir}/world &&
  ln -s #{ENV['PWD']}/persisted/banned-ips.json #{ENV['PWD']}/#{ver_dir}/banned-ips.json &&
  ln -s #{ENV['PWD']}/persisted/banned-players.json #{ENV['PWD']}/#{ver_dir}/banned-players.json &&
  ln -s #{ENV['PWD']}/persisted/ops.json #{ENV['PWD']}/#{ver_dir}/ops.json &&
  ln -s #{ENV['PWD']}/persisted/whitelist.json #{ENV['PWD']}/#{ver_dir}/whitelist.json &&
  ln -s #{ENV['PWD']}/persisted/eula.txt #{ENV['PWD']}/#{ver_dir}/eula.txt &&
  ln -s #{ENV['PWD']}/persisted/user_jvm_args.txt #{ENV['PWD']}/#{ver_dir}/user_jvm_args.txt &&
  exit 0
`

PTY.spawn("cd #{ver_dir} && ./#{file_name}") do |reader, writer|
  writer.printf("\n")
  writer.printf("\n")
  writer.printf("\n")

  reader.each {|line| puts line}
rescue Errno::EIO
end

`rm -rf #{ENV['PWD']}/current &&
  ln -s #{ENV['PWD']}/#{ver_dir} #{ENV['PWD']}/current`
