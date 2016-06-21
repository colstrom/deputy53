require 'contracts'

module Deputy53
  # An Object that supports Contracts
  class ContractedObject
    include Contracts::Core
    include Contracts::Builtin
  end
end
