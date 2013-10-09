require './graphiti'

require 'redised'
include Redised

self.redis = Graphiti.settings.redis_url

def find_graph_by_uuid(uuid)
  h = redis.hgetall "graphs:#{uuid}"
  h['uuid']      = uuid
  h['snapshots'] = redis.zrange "graphs:#{uuid}:snapshots", 0, -1
  h
end

def find_all_graphs
  graph_ids = redis.zrevrange "graphs", 0, -1
  graph_ids ||= []
  graph_ids.flatten.collect do |uuid|
    find_graph_by_uuid(uuid)
  end.compact
end

# Create Graphs

graphs = find_all_graphs

puts "Found #{graphs.count}"
