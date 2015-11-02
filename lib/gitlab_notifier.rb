require 'gitlab_notifier/version'
require 'rss'
require 'openssl'
require 'yaml'
require 'terminal-notifier'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module GitlabNotifier
  CONFIG_FILE = "#{ENV['HOME']}/.gitlab_notifier/configs.yml"

  def self.notify(body, title: nil)
    TerminalNotifier.notify(body, title: title)
  end

  def self.read_rss
    configs = YAML.load_file(CONFIG_FILE)
    configs['atom'].each do |atom|
      atom_type, atom_address = atom
      atom_last_read = configs['last_read']["#{atom_type}"]
      rss = RSS::Parser.parse(atom_address, false)
      next if !atom_last_read.nil? && rss.updated.content <= atom_last_read
      rss.items.select do |item|
        notify "#{item.title.content}", title: "#{atom_type.capitalize}" if atom_last_read.nil? || item.updated.content > atom_last_read
      end
      configs['last_read']["#{atom_type}"] = rss.updated.content
      File.open(CONFIG_FILE, 'w') { |f| YAML.dump(configs, f) }
    end
  end
end
