require 'yaml'

CONFIG_FILE = 'default.yml'

raise "Missing configuration file #{CONFIG_FILE}" unless File.exists?(CONFIG_FILE)

DEFAULT_CONFIG = YAML.load_file('default.yml')['default']
CONFIGS = YAML.load_file(CONFIG_FILE)

CONFIGS.each{|key, value| value.merge!(DEFAULT_CONFIG.merge(value))}

raise "Missing configuration argument, possible are #{CONFIGS.keys.join(', ')}" if ARGV.empty?

CONFIG = CONFIGS[ARGV.first]

raise "Missing configuration, possible are #{CONFIGS.keys.join(', ')}" unless CONFIG

puts "used configuration :"
puts CONFIG.map{|key, value| 
	{key => case key when 'twitter-consumer-key', 'twitter-consumer-secret' then value[0..4] + '**********************' else value end}
}
