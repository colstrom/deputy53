require_relative 'contracted_object'
require_relative 'route53'

module Deputy53
  # A DNS Zone
  class Zone < ContractedObject
    attr_reader :id

    Contract String => Zone
    def initialize(id)
      @id = id
      self
    end

    Contract None => Route53
    def route53
      @route53 ||= Route53.new
    end

    Contract None => ::Aws::Route53::Types::GetHostedZoneResponse
    def zone
      @zone ||= route53.api.get_hosted_zone(id: id).data
    end

    Contract None => ArrayOf[String]
    def name_servers
      @name_servers ||= zone.delegation_set.name_servers
    end

    Contract None => ArrayOf[::Aws::Route53::Types::ResourceRecordSet]
    def records
      @records ||= route53.api.list_resource_record_sets(hosted_zone_id: id).resource_record_sets
    end

    Contract String => ArrayOf[::Aws::Route53::Types::ResourceRecordSet]
    def records(type)
      records.select { |r| r.type == type }
    end

    Contract String => Bool
    def delegating?(name)
      records('NS').any? { |r| r.name == name }
    end

    Contract String => ArrayOf[String]
    def delegation(name)
      records('NS')
        .select { |r| r.name == name }
        .flat_map(&:resource_records)
        .map(&:value)
    end
  end
end
