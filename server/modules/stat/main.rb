require 'json'
puts 'Parsing statistics data'
begin
    $data = JSON.parse(File.read("#{ROOT}/modules/stat/data.json"))
rescue => e
    $data = {}
end
puts 'Binding "at_exit" actions for statistics-helper'
at_exit do
    `echo > #{ROOT}/modules/stat/data.json`
    File.open("#{ROOT}/modules/stat/data.json", 'w') { |file| file.write(JSON.pretty_generate($data)) }    
end

puts 'Initializing stat-method'
def LOG_STAT(method = caller_locations(1,1)[0].label, time = Time.now.to_i)
    $data[method] = {} if $data[method].nil?
    $data[method]['calls'] = [] if $data[method]['calls'].nil?
    $data[method]['counter'] = 0 if $data[method]['counter'].nil?
    $data[method]['counter'] += 1
    $data[method]['calls'] << time
    `echo > #{ROOT}/modules/stat/data.json`
    File.open("#{ROOT}/modules/stat/data.json", 'w') { |file| file.write(JSON.pretty_generate($data)) }    
    return nil
end

puts 'Extending Handler class by statistic-getter'
class IONe
    def GetStatistics(params = {})
        return JSON.pretty_generate($data) if params['method'].nil? && params['json'] == true
        return $data if params['method'].nil?
        begin
            return JSON.pretty_generate($data[params['method']]) if params['json'] == true
            return $data[params['method']]
        rescue => e
            return e.message
        end
    end
end