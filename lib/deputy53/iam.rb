require 'aws-sdk'
require_relative 'contracted_object'
require_relative 'identity'
require_relative 'exceptions'

module Deputy53
  # An IAM Client
  class IAM < ContractedObject
    Contract None => ::Aws::IAM::Client
    def api
      @api ||= ::Aws::IAM::Client.new region: region
    end

    Contract None => String
    def region
      ENV.fetch('AWS_DEFAULT_REGION') { 'us-west-2' }
    end

    Contract None => ArrayOf[::Aws::IAM::Types::User]
    def users
      @users ||= api.list_users.users
    end

    Contract None => ArrayOf[::Aws::IAM::Types::Group]
    def groups
      @groups ||= api.list_groups.groups
    end
    Contract None => ArrayOf[::Aws::IAM::Types::Role]
    def roles
      @roles ||= api.list_roles.roles
    end

    Contract None => ArrayOf[Identity]
    def identities
      @identities ||= [users, groups, roles]
                      .reduce(:+)
                      .map { |i| Identity.new i }
    end

    Contract None => ArrayOf[String]
    def names
      identities.map(&:name)
    end

    Contract String => Bool
    def exists?(name)
      names.include? name
    end

    Contract String => Bool
    def unambiguous?(name)
      names.count { |n| n == name } == 1
    end

    Contract String => Identity
    def identity(name)
      raise IdentityNotFoundError unless exists? name
      raise AmbiguousNameError unless unambiguous? name

      identities.select { |i| i.name == name }.first
    end

    Contract String => String
    def id(name)
      identity(name).id
    end
  end
end
