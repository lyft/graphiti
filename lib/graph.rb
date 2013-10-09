require 'uri'
require 'fileutils'

class Graph < ActiveRecord::Base
  include Redised

  SNAPSHOT_SERVICES = ['s3', 'fs']

  # Given a URL or a URI, append the current graphite_base_url
  def self.make_url(uri)
    uri = if uri !~ /^\//
      URI.parse(uri).request_uri
    end
    Graphiti.graphite_base_url + uri.gsub(/\#.*$/,'')
  end

  def self.snapshot(uuid)
    service = Graphiti.snapshots['service'] if Graphiti.respond_to?(:snapshots)
    if !snapshot_service?(service)
      raise "'#{service}' is not a valid snapshot service (must be one of #{SNAPSHOT_SERVICES.join(', ')})"
    end
    graph = find(uuid)
    return nil if !graph
    url = make_url(graph['url'])
    response = Typhoeus::Request.get(url, :timeout => 20000)
    return false if !response.success?
    graph_data = response.body
    time = (Time.now.to_f * 1000).to_i
    filename = "/snapshots/#{uuid}/#{time}.png"
    image_url = send("store_on_#{service}", graph_data, filename)
    redis.zadd "graphs:#{uuid}:snapshots", time, image_url if image_url
    image_url
  end

  def self.snapshot_service?(service)
    SNAPSHOT_SERVICES.include?(service)
  end

  # upload graph_data to S3 with filename
  def self.store_on_s3(graph_data, filename)
    S3::Request.credentials ||= Graphiti.snapshots
    return false if !S3::Request.upload(filename, StringIO.new(graph_data), 'image/png')
    S3::Request.url(filename)
  end

  # store graph_data at filename, prefixed with Graphiti.snapshots['dir']
  def self.store_on_fs(graph_data, filename)
    directory = File.expand_path(Graphiti.snapshots['dir'])
    fullpath = File.join(directory, filename)
    fulldir = File.dirname(fullpath)
    FileUtils.mkdir_p(fulldir) unless File.directory?(fulldir)
    File.open(fullpath, 'wb') do |file|
      file << graph_data
    end
    image_url = "#{Graphiti.snapshots['public_host']}#{filename}"
  end

  def self.dashboards(uuid)
    redis.smembers("graphs:#{uuid}:dashboards")
  end

  def self.destroy(uuid)
    redis.del "graphs:#{uuid}"
    redis.zrem "graphs", uuid
    self.dashboards(uuid).each do |dashboard|
      Dashboard.remove_graph dashboard, uuid
    end
  end

  def self.make_uuid(graph_json)
    Digest::SHA1.hexdigest(graph_json.inspect + Time.now.to_f.to_s + rand(100).to_s)[0..10]
  end

end
