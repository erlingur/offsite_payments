# encoding: utf-8
require 'test_helper'

class ValitorNotificationTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @notification = Valitor::Notification.new(http_raw_query)
  end

  def test_accessors
    assert @notification.complete?
    assert @notification.acknowledge
    assert @notification.success?
    assert_equal "Completed", @notification.status
    assert_equal "2b969de3-6928-4fa7-a0d6-6dec63fec5c3", @notification.transaction_id
    assert_equal "order684afbb93730db2492a8fa2f3fedbcb9", @notification.order
    assert_equal Time.parse("2021-03-30").utc, @notification.received_at

    assert_equal "VISA", @notification.card_type
    assert_equal "9999", @notification.card_last_four
    assert_equal "123450", @notification.authorization_number
    assert_equal "108913106545", @notification.transaction_number
    assert_equal "NAME", @notification.customer_name
    assert_equal "123 ADDRESS", @notification.customer_address
    assert_equal "CITY", @notification.customer_city
    assert_equal "98765", @notification.customer_zip
    assert_equal "COUNTRY", @notification.customer_country
    assert_equal "EMAIL@EXAMPLE.COM", @notification.customer_email
    assert_equal "COMMENTS", @notification.customer_comment
    assert_equal "0", @notification.gross
    assert_nil @notification.currency

    assert !@notification.test?
  end

  def test_acknowledge
    valid = Valitor.notification(http_raw_query, :credential2 => 'password')
    assert valid.acknowledge
    assert valid.success?
    assert valid.complete?

    invalid = Valitor.notification(http_raw_query, :credential2 => 'bogus')
    assert !invalid.acknowledge
    assert !invalid.success?
    assert !invalid.complete?
  end

  def test_test_mode
    assert Valitor::Notification.new(http_raw_query, :test => true).test?
    assert !Valitor::Notification.new(http_raw_query).test?
  end

  def http_raw_query
    "CardType=VISA&CardNumberMasked=999999******9999&Date=30.03.2021&AuthorizationNumber=123450&TransactionNumber=108913106545&SaleID=2b969de3-6928-4fa7-a0d6-6dec63fec5c3&ReferenceNumber=order684afbb93730db2492a8fa2f3fedbcb9&DigitalSignatureResponse=03d859813eff711d6c8667b0caf5f5a5&ContractNumber=122&ContractType=ORUGGS&CardTypeCode=500&SSN=0605862768&Name=NAME&Address=123+ADDRESS&PostalCode=98765&City=CITY&Country=COUNTRY&Phone=5555555&Email=EMAIL%40EXAMPLE.COM&Comments=COMMENTS"
  end
end
