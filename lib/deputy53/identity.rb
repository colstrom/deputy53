require_relative 'contracted_object'

module Deputy53
  # Unified class for Users, Groups, and Roles.
  class Identity < ContractedObject
    Contract Xor[::Aws::IAM::Types::User, ::Aws::IAM::Types::Group, ::Aws::IAM::Types::Role] => Identity
    def initialize(identity)
      @identity = identity
      self
    end

    Contract None => Enum[:user, :group, :role]
    def type
      @type ||= @identity.arn.split(':').last.split('/').first.to_sym
    end

    Contract None => String
    def name
      @name ||= @identity.method("#{type}_name").call
    end

    Contract None => String
    def id
      @id ||= @identity.method("#{type}_id").call
    end
  end
end
