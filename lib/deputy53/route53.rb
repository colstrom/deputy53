require 'aws-sdk'
require_relative 'exceptions'

module Deputy53
  # A Route53 Client
  class Route53 < ContractedObject
    Contract None => ::Aws::Route53::Client
    def api
      @api ||= ::Aws::Route53::Client.new region: region
    end

    Contract None => String
    def region
      ENV.fetch('AWS_DEFAULT_REGION') { 'us-west-1' }
    end

    Contract None => ArrayOf[::Aws::Route53::Types::HostedZone]
    def zones
      @zones ||= api.list_hosted_zones.hosted_zones
    end

    Contract None => ArrayOf[String]
    def names
      @names ||= zones.map(&:name)
    end

    Contract String => ArrayOf[::Aws::Route53::Types::HostedZone]
    def zones(name)
      zones.select { |z| z.name == name }
    end

    Contract String => Bool
    def zone?(name)
      !zones(name).empty?
    end

    Contract String => String
    def id(name)
      raise ZoneNotFoundError unless zone? name
      zones(name).first.id
    end
  end
end
