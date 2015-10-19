require 'upwork/api'
require 'upwork/api/routers/jobs/search'
require_relative 'utils'

module Labourant
  class Upwork
    def initialize
      @client = ::Upwork::Api::Client.new(config)
    end

    def find_jobs(limit: 10, offset: 0, **params)
      paging = [offset, limit].join(';')

      search = ::Upwork::Api::Routers::Jobs::Search.new(client)
      search.find(Utils.stringify_keys(params.merge(paging: paging)))
    end

  private
    attr_reader :client

    def config
      ::Upwork::Api::Config.new(
        'consumer_key'    => ENV['UPWORK_KEY'],
        'consumer_secret' => ENV['UPWORK_SECRET'],
        'access_token'    => ENV['UPWORK_ACCESS_TOKEN'],
        'access_secret'   => ENV['UPWORK_ACCESS_SECRET']
      )
    end
  end
end
