require_relative 'agent'
require_relative 'assigner'

module Deputy53
  # CommandLine Interface
  class CLI
    def delegate(subdomain)
      Agent.new(subdomain).delegate
    end

    def assign(subdomain, user = nil)
      subdomain = "#{subdomain}." unless subdomain.end_with? '.'
      user ||= subdomain.split('.').slice(0..-3).join('.')
      Assigner.new.assign(subdomain, user)
    end
  end
end
