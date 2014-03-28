require_relative '../conduit_client'

module Phabricator::Maniphest
  class Task
    module Priority
      # TODO: Make these priority values actually correct, or figure out
      # how to pull these programmatically.
      PRIORITIES = {
        unbreak_now: 100,
        needs_triage: 90,
        high: 80,
        normal: 50,
        low: 25,
        wishlist: 0
      }

      PRIORITIES.each do |priority, value|
        define_method(priority) do
          value
        end
      end
    end

    attr_reader :id
    attr_accessor :title, :description, :priority

    def self.create(title, description=nil, projects=[], priority='normal', other={})
      response = JSON.parse(client.request(:post, 'maniphest.createtask', {
        title: title,
        description: description,
        priority: Priority.send(priority),
        projectPHIDs: projects.map {|p| Phabricator::Project.find_by_name(p).phid }
      }.merge(other)))

      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def initialize(attributes)
      @id = attributes['id']
      @title = attributes['title']
      @description = attributes['description']
      @priority = attributes['priority']
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
