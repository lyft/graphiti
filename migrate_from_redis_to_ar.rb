require './graphiti'

require 'redised'
module GraphitiMigrator
  include Redised

  extend self

  def find_graph_by_uuid(uuid)
    h = redis.hgetall "graphs:#{uuid}"
    h['uuid']      = uuid
    h['snapshots'] = redis.zrange("graphs:#{uuid}:snapshots", 0, -1, :withscores => true).in_groups_of(2)
    h
  end

  def find_all_graphs
    graph_ids = redis.zrevrange "graphs", 0, -1
    graph_ids ||= []
    graph_ids.flatten.collect do |uuid|
      find_graph_by_uuid(uuid)
    end.compact
  end

  def find_dashboard(slug, with_graphs = false)
    dash = redis.hgetall "dashboards:#{slug}"
    return nil if !dash || dash.empty?
    dash['graphs'] = dashboard_graph_ids(slug)
    dash
  end

  def find_all_dashboards(*slugs)
    slugs = redis.zrevrange "dashboards", 0, -1 if slugs.empty?
    slugs ||= []
    slugs.flatten.collect do |slug|
      find_dashboard(slug)
    end.compact
  end

  def dashboard_graph_ids(slug)
    redis.zrange "dashboards:#{slug}:graphs", 0, -1
  end

end

# Create Graphs

GraphitiMigrator.redis = Graphiti.settings.redis_url
graphs = GraphitiMigrator.find_all_graphs
dashboards = GraphitiMigrator.find_all_dashboards
puts "Found #{graphs.count}"
puts "Found #{dashboards.count}"

graphs.each do |graph|
  g = Graph.find_or_create_by_uuid(graph['uuid'])
  g.updated_at = Time.at(graph['updated_at'].to_i / 1000)
  g.url = graph['url']
  g.json = graph['json']
  g.title = graph['title']
  g.save!
  graph['snapshots'].each do |url, created_at|
    g.snapshots.create(:url => url, :created_at => Time.at(created_at.to_i / 1000))
  end
end

dashboards.each do |dashboard|
  d = Dashboard.find_or_create_by_slug(dashboard['slug'])
  d.title = dashboard['title']
  d.updated_at = Time.at(dashboard['updated_at'].to_i / 1000)
  d.save
  dashboard['graphs'].each_with_index do |uuid, i|
    graph = Graph.find_by_uuid(uuid)
    d.dashboard_graphs.create! :graph_id => graph.id, :position => i
  end
end

puts "Graphs in DB: #{Graph.count}"
puts "Dashboards in DB: #{Dashboard.count}"
puts "Snapshots in DB: #{Snapshot.count}"
puts "Dashboard Graphs in DB: #{DashboardGraph.count}"
