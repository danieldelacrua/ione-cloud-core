require 'rubygems'
require 'zmqjsonrpc'
require 'nori'

client = ZmqJsonRpc::Client.new("tcp://185.66.68.238:8008")

client.test(ARGV[0].to_i)