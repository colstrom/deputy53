require 'exponential_backoff'
require_relative 'contracted_object'
require_relative 'route53'
require_relative 'zone'

module Deputy53
  # Handles creation and delegation
  class Agent < ContractedObject
    Contract String => Agent
    def initialize(target)
      @target = target
      self
    end

    Contract None => String
    def caller_reference
      @caller_reference ||= "#{subdomain}@#{Time.now.to_i}"
    end

    Contract None => String
    def domain
      @domain ||= @target.split('.').last(2).join('.') << '.'
    end

    Contract None => String
    def prefix
      @prefix ||= @target.split('.').slice(0..-3).join('.')
    end

    Contract None => String
    def subdomain
      @subdomain ||= "#{prefix}.#{domain}"
    end

    Contract None => Route53
    def route53!
      @route53 = Route53.new
    end

    Contract None => Route53
    def route53
      @route53 ||= route53!
    end

    Contract None => Zone
    def child
      @child ||= Zone.new create subdomain
    end

    Contract None => Zone
    def parent
      @parent ||= Zone.new create domain
    end

    Contract String => String
    def create(name)
      return route53.id(name) if route53.zone? name

      route53
        .api
        .create_hosted_zone(
          name: name,
          caller_reference: caller_reference
        ).hosted_zone
        .id
    end

    Contract None => Bool
    def delegate
      return true if parent.delegation(subdomain).sort == child.name_servers.sort
      wait_for_change route53.api.change_resource_record_sets(payload).change_info
    end

    Contract Aws::Route53::Types::ChangeInfo => Bool
    def wait_for_change(change)
      ExponentialBackoff.new(0.5, 8.0).tap do |backoff|
        while change.status == 'PENDING'
          route53.api.get_change(id: change.id).change_info.tap do |info|
            backoff.next_interval
            message = "#{info.id} is #{info.status}"
            if info.status == 'PENDING'
              STDERR.puts "#{message} (recheck in #{backoff.current_interval}s)"
              sleep backoff.current_interval
            else
              STDERR.puts message
            end
            change = info
          end
        end
      end
      true if change.status == 'INSYNC'
    end

    Contract None => Hash
    def payload
      {
        hosted_zone_id: parent.id,
        change_batch: {
          changes: [
            action: 'CREATE',
            resource_record_set: {
              name: subdomain,
              type: 'NS',
              ttl: 300,
              resource_records: child.name_servers.map { |ns| { value: ns } }
            }
          ]
        }
      }
    end
  end
end
