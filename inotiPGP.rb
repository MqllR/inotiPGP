# Syntax: inotiPGP.rb -c "myconf.yaml" [-v]

require 'optparse'
require 'rb-inotify'
require  'yaml'
require 'logger'

require_relative 'lib/pgp'

config = 'config.yaml'
verbose = false

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"
  opts.on("-cCONFIG", "--config=CONFIG", "Path to the config file [default
  config.yaml") do |c|
    config = c
  end
  opts.on("-v", "--verbose", "Verbose mode") do |v|
    verbose = true
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

logger = Logger.new STDOUT
logger.level = verbose ? Logger::DEBUG : Logger::INFO

InotiPGP.logger=(logger)

def load_config(c)
    InotiPGP.logger.debug "Load config from #{c}"
    YAML.load_file(c)
end

c = load_config(config)
if c.nil? || c['watchers'].nil?
    InotiPGP.logger.error "Nothing to do"
    exit
end

notifier = INotify::Notifier.new

c['watchers'].each do |watcher|
    InotiPGP.logger.info "Watcher positioned on #{watcher['src']}"
    notifier.watch(watcher['src'], :moved_to, :create) do |event|
        InotiPGP.logger.info "#{event.name} is now in #{watcher['src']}"

        p = InotiPGP::Pgp.new(
            File.join(watcher['src'], event.name),
            File.join(watcher['dest'], event.name + ".pgp"),
            watcher['id'],
            watcher['passphrase']
            )

        InotiPGP::BaseRunner.execute(p)
    end
end

notifier.run
