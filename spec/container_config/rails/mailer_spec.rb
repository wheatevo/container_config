# frozen_string_literal: true

require "container_config/rails"

RSpec.describe ContainerConfig::Rails::Mailer do
  before do
    allow(Rails).to receive(:env).and_return(double(production?: false))
  end

  describe "self#load" do
    context "when no config is specified" do
      it "returns default values" do
        expect(described_class.load("MAILER")).to eq({
                                                       delivery_method: :sendmail,
                                                       perform_caching: false,
                                                       perform_deliveries: false,
                                                       raise_delivery_errors: false,
                                                       sendmail_settings: {},
                                                       smtp_settings: { port: 25 }
                                                     })
      end
    end

    context "when SMTP config is specified" do
      before do
        stub_const("ENV", {
                     "MAILER_PERFORM_DELIVERIES" => "true",
                     "MAILER_PERFORM_CACHING" => "true",
                     "MAILER_RAISE_DELIVERY_ERRORS" => "true",
                     "MAILER_DELIVERY_METHOD" => "smtp",
                     "MAILER_SMTP_ADDRESS" => "mail.cernerasp.com",
                     "MAILER_SMTP_PORT" => 25,
                     "MAILER_SMTP_DOMAIN" => "mail.cernerasp.com",
                     "MAILER_SMTP_USER_NAME" => "mailuser",
                     "MAILER_SMTP_PASSWORD" => "mailpass",
                     "MAILER_SMTP_AUTHENTICATION" => "cram_md5",
                     "MAILER_SMTP_ENABLE_STARTTLS_AUTO" => "true",
                     "MAILER_SMTP_OPENSSL_VERIFY_MODE" => "VERIFY_PEER",
                     "MAILER_SMTP_SSL" => "true",
                     "MAILER_SMTP_TLS" => "true"
                   })
      end

      it "returns SMTP config" do
        expect(described_class.load("MAILER")).to eq({
                                                       delivery_method: :smtp,
                                                       perform_caching: true,
                                                       perform_deliveries: true,
                                                       raise_delivery_errors: true,
                                                       sendmail_settings: {},
                                                       smtp_settings: {
                                                         address: "mail.cernerasp.com",
                                                         port: 25,
                                                         domain: "mail.cernerasp.com",
                                                         user_name: "mailuser",
                                                         password: "mailpass",
                                                         authentication: :cram_md5,
                                                         enable_starttls_auto: true,
                                                         openssl_verify_mode: OpenSSL::SSL::VERIFY_PEER,
                                                         ssl: true,
                                                         tls: true
                                                       }
                                                     })
      end
    end

    context "when sendmail config is specified" do
      before do
        stub_const("ENV", {
                     "MAILER_PERFORM_DELIVERIES" => "true",
                     "MAILER_PERFORM_CACHING" => "true",
                     "MAILER_RAISE_DELIVERY_ERRORS" => "true",
                     "MAILER_DELIVERY_METHOD" => "sendmail",
                     "MAILER_SENDMAIL_LOCATION" => "/bin/sendmail",
                     "MAILER_SENDMAIL_ARGUMENTS" => "-i"
                   })
      end

      it "returns sendmail config" do
        expect(described_class.load("MAILER")).to eq({
                                                       delivery_method: :sendmail,
                                                       perform_caching: true,
                                                       perform_deliveries: true,
                                                       raise_delivery_errors: true,
                                                       sendmail_settings: {
                                                         location: "/bin/sendmail",
                                                         arguments: "-i"
                                                       },
                                                       smtp_settings: { port: 25 }
                                                     })
      end
    end
  end
end
