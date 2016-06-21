require_relative 'agent'

module Deputy53
  class CLI
    def delegate(subdomain)
      Agent.new(subdomain).delegate
    end
  end
end
