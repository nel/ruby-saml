require "base64"
require "uuid"
require "zlib"
require "cgi"

module Onelogin::Saml
  class Authrequest
    def create(settings, params={})
      encoded_request   = CGI.escape(create_encoded_xml(settings))
      request_params    = "?SAMLRequest=" + encoded_request

      params.each_pair do |key, value|
        request_params << "&#{key}=#{CGI.escape(value.to_s)}"
      end

      settings.idp_sso_target_url + request_params
    end
    
    def create_encoded_xml(settings)
      request = create_xml(settings)
      deflated_request  = Zlib::Deflate.deflate(request, 9)[2..-5]
      base64_request    = Base64.encode64(deflated_request)
    end
    
    def create_xml(settings)
      uuid = "_" + UUID.new.generate
      time = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

      request =
        "<samlp:AuthnRequest xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\" ID=\"#{uuid}\" Version=\"2.0\" IssueInstant=\"#{time}\" ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" AttributeConsumingServiceIndex=\"#{settings.attributes_index}\" AssertionConsumerServiceURL=\"#{settings.assertion_consumer_service_url}\">" +
        "<saml:Issuer xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">#{settings.issuer}</saml:Issuer>\n" +
        "<samlp:NameIDPolicy xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\" Format=\"#{settings.name_identifier_format}\" AllowCreate=\"true\"></samlp:NameIDPolicy>\n" +
        "<samlp:RequestedAuthnContext xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\" Comparison=\"exact\">" +
        "<saml:AuthnContextClassRef xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef></samlp:RequestedAuthnContext>\n" +
        "</samlp:AuthnRequest>"

    end
  end
end
