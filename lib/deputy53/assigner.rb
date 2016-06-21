require 'aws-sdk'
require 'json'
require_relative 'contracted_object'
require_relative 'iam'
require_relative 'route53'

module Deputy53
  # Assigns control of a zone to an identity
  class Assigner < ContractedObject
    Contract None => IAM
    def iam
      @iam ||= IAM.new
    end

    Contract None => Route53
    def route53
      @route53 ||= Route53.new
    end

    Contract String => String
    def policy(subdomain)
      zone = route53.id(subdomain).sub(%r{^/}, '')
      document = {
        'Version' => '2012-10-17',
        'Statement' => [
          'Effect' => 'Allow',
          'Action' => ['route53domains:*', 'route53:*'],
          'Resource' => "arn:aws:route53:::#{zone}"
        ]
      }
      JSON.dump document
    end

    Contract String, String => Bool
    def assign(subdomain, identity)
      identity = iam.identity identity

      true if iam.api.method("put_#{identity.type}_policy").call(
        :"#{identity.type}_name" => identity.name,
        policy_name: "manage-dns@#{subdomain}",
        policy_document: policy(subdomain)
      )
    end
  end
end
