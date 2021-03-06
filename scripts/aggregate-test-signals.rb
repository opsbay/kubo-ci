#!/usr/bin/env ruby

files = Dir.glob("gcs-*-shipables").flat_map{|d| Dir.glob(d+"/*shipable")}
overlap = File.read(files.first).split("\n")

files.each { |f| overlap = File.read(f).split("\n") & overlap }

if overlap.any?
  release_sha, deployment_sha = overlap.last.split
  File.write(ENV["SLACK_MESSAGE_FILE"],
             "Ready to :ship: <https://github.com/cloudfoundry-incubator/kubo-release/tree/#{release_sha}/|#{release_sha}> <https://github.com/cloudfoundry-incubator/kubo-deployment/tree/#{deployment_sha}/|#{deployment_sha}>")
  File.write(ENV["SHIPABLE_VERSION_FILE"], overlap.last)

else
  File.write(ENV["SLACK_MESSAGE_FILE"], "No shippable version found")
  exit 1
end
