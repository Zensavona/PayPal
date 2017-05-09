defmodule PayPalPaymentsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.response_headers_blacklist(["paypal-debug-id", "Paypal-Debug-Id", "Set-Cookie"])
    ExVCR.Config.filter_request_headers("Authorization")
    ExVCR.Config.filter_sensitive_data("basic_auth\":\".+?\"", "basic_auth\":\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("app_id\":\".+?\"", "app_id\":\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("access_token\":\".+?\"", "access_token\":\"<REMOVED>\"")
    Application.put_env(:pay_pal, :access_token, "A21AAGRHv8XsoIjSpsPVOPxz3bwAEXTUFxtn7K9TDwARZNlifnAlAwkm5xwr0fDQr1JOfx4aBqTT3k-MqPhFMrcThQC_Zz9XQ")
    :ok
  end

  test "create a payment" do
    use_cassette "payments_create_payment" do
      payment = %{
        intent: "sale",
        payer: %{
          payment_method: "paypal"
        },
        transactions: [%{
          amount: %{
            total: "30.11",
            currency: "USD",
            details: %{
              subtotal: "30.00",
              tax: "0.07",
              shipping: "0.03",
              handling_fee: "1.00",
              shipping_discount: "-1.00",
              insurance: "0.01"
            }
          },
          description: "The payment transaction description.",
          custom: "EBAY_EMS_90048630024435",
          invoice_number: "48787589673",
          payment_options: %{
            allowed_payment_method: "INSTANT_FUNDING_SOURCE"
          },
          soft_descriptor: "ECHI5786786",
          item_list: %{
            items: [%{
              name: "hat",
              description: "Brown hat.",
              quantity: "5",
              price: "3",
              tax: "0.01",
              sku: "1",
              currency: "USD"
            },
            %{
              name: "handbag",
              description: "Black handbag.",
              quantity: "1",
              price: "15",
              tax: "0.02",
              sku: "product34",
              currency: "USD"
            }],
            shipping_address: %{
              recipient_name: "Brian Robinson",
              line1: "4th Floor",
              line2: "Unit #34",
              city: "San Jose",
              country_code: "US",
              postal_code: "95131",
              phone: "011862212345678",
              state: "CA"
            }
          }
        }
        ],
        note_to_payer: "Contact us for any questions on your order.",
        redirect_urls: %{
          return_url: "http://www.paypal.com/return",
          cancel_url: "http://www.paypal.com/cancel"
        }
      }

      resp = PayPal.Payments.Payments.create(payment)
      assert resp == {:ok, %{create_time: "2017-05-09T02:41:25Z", id: "PAY-56X02727YH154025YLEISYVI", intent: "sale", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "self"}, %{href: "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-7MA403949P880733G", method: "REDIRECT", rel: "approval_url"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI/execute", method: "POST", rel: "execute"}], note_to_payer: "Contact us for any questions on your order.", payer: %{payment_method: "paypal"}, state: "created", transactions: [%{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, custom: "EBAY_EMS_90048630024435", description: "The payment transaction description.", invoice_number: "48787589673", item_list: %{items: [%{currency: "USD", description: "Brown hat.", name: "hat", price: "3.00", quantity: 5, sku: "1", tax: "0.01"}, %{currency: "USD", description: "Black handbag.", name: "handbag", price: "15.00", quantity: 1, sku: "product34", tax: "0.02"}], shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", phone: "011862212345678", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payment_options: %{allowed_payment_method: "INSTANT_FUNDING_SOURCE", recurring_flag: false, skip_fmf: false}, related_resources: [], soft_descriptor: "ECHI5786786"}]}}
    end
  end

  test "create a payment error" do
    use_cassette "payments_create_payment_error" do
      resp = PayPal.Payments.Payments.create(nil)
      assert resp == {:error, :malformed_request}
    end
  end

  test "execute a payment" do
    use_cassette "payments_execute_payment" do
      resp = PayPal.Payments.Payments.execute("PAY-56X02727YH154025YLEISYVI", "TM63YY9GU9Q8C")
      assert resp == {:ok, %{cart: "7MA403949P880733G", create_time: "2017-05-09T02:54:15Z", id: "PAY-56X02727YH154025YLEISYVI", intent: "sale", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "self"}], payer: %{payer_info: %{country_code: "US", email: "tedelex06@gmail.com", first_name: "Zen", last_name: "Savona", payer_id: "TM63YY9GU9Q8C", shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payment_method: "paypal", status: "UNVERIFIED"}, state: "approved", transactions: [%{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, description: "The payment transaction description.", invoice_number: "48787589673", item_list: %{items: [%{currency: "USD", description: "Brown hat.", name: "hat", price: "3.00", quantity: 5, sku: "1", tax: "0.01"}, %{currency: "USD", description: "Black handbag.", name: "handbag", price: "15.00", quantity: 1, sku: "product34", tax: "0.02"}], shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}, shipping_phone_number: "011862212345678"}, payee: %{email: "paypal-facilitator@joocyluscious.com.au", merchant_id: "G8Z6LP4WN9SP4"}, related_resources: [%{sale: %{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, create_time: "2017-05-09T02:54:14Z", id: "7UB09546JJ671102D", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D", method: "GET", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D/refund", method: "POST", rel: "refund"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "parent_payment"}], parent_payment: "PAY-56X02727YH154025YLEISYVI", payment_mode: "INSTANT_TRANSFER", protection_eligibility: "ELIGIBLE", protection_eligibility_type: "ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE", soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786", state: "completed", transaction_fee: %{currency: "USD", value: "1.32"}, update_time: "2017-05-09T02:54:14Z"}}]}]}}
    end
  end

  test "show a payment" do
    use_cassette "payments_show_payment" do
      resp = PayPal.Payments.Payments.show("PAY-56X02727YH154025YLEISYVI")
      assert resp == {:ok, %{cart: "7MA403949P880733G", create_time: "2017-05-09T02:54:14Z", id: "PAY-56X02727YH154025YLEISYVI", intent: "sale", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "self"}], payer: %{payer_info: %{country_code: "US", email: "tedelex06@gmail.com", first_name: "Zen", last_name: "Savona", payer_id: "TM63YY9GU9Q8C", phone: "0481854963", shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payment_method: "paypal", status: "UNVERIFIED"}, state: "approved", transactions: [%{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, custom: "EBAY_EMS_90048630024435", description: "The payment transaction description.", invoice_number: "48787589673", item_list: %{items: [%{currency: "USD", description: "Brown hat.", name: "hat", price: "3.00", quantity: 5, sku: "1", tax: "0.01"}, %{currency: "USD", description: "Black handbag.", name: "handbag", price: "15.00", quantity: 1, sku: "product34", tax: "0.02"}], shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payee: %{merchant_id: "G8Z6LP4WN9SP4"}, related_resources: [%{sale: %{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, create_time: "2017-05-09T02:54:14Z", id: "7UB09546JJ671102D", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D", method: "GET", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D/refund", method: "POST", rel: "refund"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "parent_payment"}], parent_payment: "PAY-56X02727YH154025YLEISYVI", payment_mode: "INSTANT_TRANSFER", protection_eligibility: "ELIGIBLE", protection_eligibility_type: "ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE", soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786", state: "completed", transaction_fee: %{currency: "USD", value: "1.32"}, update_time: "2017-05-09T02:54:14Z"}}], soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786"}]}}
    end
  end

  test "update a payment, error" do
    use_cassette "payments_update_error" do
      resp = PayPal.Payments.Payments.update("PAY-56X02727YH154025YLEISYVI", [
      %{
        op: "replace",
        path: "/transactions/0/amount",
        value: %{
          total: "18.37",
          currency: "EUR",
          details: %{
            subtotal: "13.37",
            shipping: "5.00"
          }
        }
      },
      %{
        op: "add",
        path: "/transactions/0/item_list/shipping_address",
        value: %{
          recipient_name: "Anna Gruneberg",
          line1: "Kathwarinenhof 1",
          city: "Flensburg",
          postal_code: "24939",
          country_code: "DE"
        }
      }])
      assert resp == {:error, :malformed_request}
    end
  end

  test "update a payment" do
    use_cassette "payments_update" do
      resp = PayPal.Payments.Payments.update("PAY-56X02727YH154025YLEISYVI", [
      %{
        op: "add",
        path: "/transactions/0/item_list/shipping_address",
        value: %{
          recipient_name: "Anna Gruneberg",
          line1: "Kathwarinenhof 1",
          city: "Flensburg",
          postal_code: "24939",
          country_code: "DE"
        }
      }])
      assert resp == {:error, :malformed_request}
    end
  end

  test "get list of payments" do
    use_cassette "payments_list" do
      resp = PayPal.Payments.Payments.list()
      assert resp == {:ok, [%{cart: "7MA403949P880733G", create_time: "2017-05-09T02:54:14Z", id: "PAY-56X02727YH154025YLEISYVI", intent: "sale", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "self"}], payer: %{payer_info: %{country_code: "US", email: "tedelex06@gmail.com", first_name: "Zen", last_name: "Savona", payer_id: "TM63YY9GU9Q8C", phone: "0481854963", shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payment_method: "paypal", status: "UNVERIFIED"}, state: "approved", transactions: [%{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, custom: "EBAY_EMS_90048630024435", description: "The payment transaction description.", invoice_number: "48787589673", item_list: %{items: [%{currency: "USD", description: "Brown hat.", name: "hat", price: "3.00", quantity: 5, sku: "1", tax: "0.01"}, %{currency: "USD", description: "Black handbag.", name: "handbag", price: "15.00", quantity: 1, sku: "product34", tax: "0.02"}], shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payee: %{merchant_id: "G8Z6LP4WN9SP4"}, related_resources: [%{sale: %{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, create_time: "2017-05-09T02:54:14Z", id: "7UB09546JJ671102D", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D", method: "GET", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D/refund", method: "POST", rel: "refund"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "parent_payment"}], parent_payment: "PAY-56X02727YH154025YLEISYVI", payment_mode: "INSTANT_TRANSFER", protection_eligibility: "ELIGIBLE", protection_eligibility_type: "ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE", soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786", state: "completed", transaction_fee: %{currency: "USD", value: "1.32"}, update_time: "2017-05-09T02:54:14Z"}}], soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786"}]}]}
    end
  end

  test "get list of payments, pass query" do
    use_cassette "payments_list_query" do
      resp = PayPal.Payments.Payments.list(%{count: 1})
      assert resp == {:ok, [%{cart: "7MA403949P880733G", create_time: "2017-05-09T02:54:14Z", id: "PAY-56X02727YH154025YLEISYVI", intent: "sale", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "self"}], payer: %{payer_info: %{country_code: "US", email: "tedelex06@gmail.com", first_name: "Zen", last_name: "Savona", payer_id: "TM63YY9GU9Q8C", phone: "0481854963", shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payment_method: "paypal", status: "UNVERIFIED"}, state: "approved", transactions: [%{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, custom: "EBAY_EMS_90048630024435", description: "The payment transaction description.", invoice_number: "48787589673", item_list: %{items: [%{currency: "USD", description: "Brown hat.", name: "hat", price: "3.00", quantity: 5, sku: "1", tax: "0.01"}, %{currency: "USD", description: "Black handbag.", name: "handbag", price: "15.00", quantity: 1, sku: "product34", tax: "0.02"}], shipping_address: %{city: "San Jose", country_code: "US", line1: "4th Floor", line2: "Unit #34", postal_code: "95131", recipient_name: "Brian Robinson", state: "CA"}}, payee: %{merchant_id: "G8Z6LP4WN9SP4"}, related_resources: [%{sale: %{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, create_time: "2017-05-09T02:54:14Z", id: "7UB09546JJ671102D", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D", method: "GET", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D/refund", method: "POST", rel: "refund"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "parent_payment"}], parent_payment: "PAY-56X02727YH154025YLEISYVI", payment_mode: "INSTANT_TRANSFER", protection_eligibility: "ELIGIBLE", protection_eligibility_type: "ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE", soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786", state: "completed", transaction_fee: %{currency: "USD", value: "1.32"}, update_time: "2017-05-09T02:54:14Z"}}], soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786"}]}]}
    end
  end

  test "show a sale" do
    use_cassette "sale_show" do
      resp = PayPal.Payments.Sales.show("7UB09546JJ671102D")
      assert resp == {:ok, %{amount: %{currency: "USD", details: %{handling_fee: "1.00", insurance: "0.01", shipping: "0.03", shipping_discount: "-1.00", subtotal: "30.00", tax: "0.07"}, total: "30.11"}, create_time: "2017-05-09T02:54:14Z", custom: "EBAY_EMS_90048630024435", id: "7UB09546JJ671102D", invoice_number: "48787589673", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D", method: "GET", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D/refund", method: "POST", rel: "refund"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "parent_payment"}], parent_payment: "PAY-56X02727YH154025YLEISYVI", payment_mode: "INSTANT_TRANSFER", protection_eligibility: "ELIGIBLE", protection_eligibility_type: "ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE", soft_descriptor: "PAYPAL *TESTFACILIT ECHI5786786", state: "completed", transaction_fee: %{currency: "USD", value: "1.32"}, update_time: "2017-05-09T02:54:14Z"}}
    end
  end

  test "refund a sale" do
    use_cassette "sale_refund" do
      resp = PayPal.Payments.Sales.refund("7UB09546JJ671102D", %{
        amount: %{
          total: "1.50",
          currency: "USD"
        }
      })

      assert resp == {:ok, %{amount: %{currency: "USD", total: "1.50"}, create_time: "2017-05-09T04:59:50Z", id: "6N458369VN1308144", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/refund/6N458369VN1308144", method: "GET", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI", method: "GET", rel: "parent_payment"}, %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D", method: "GET", rel: "sale"}], parent_payment: "PAY-56X02727YH154025YLEISYVI", sale_id: "7UB09546JJ671102D", state: "completed", update_time: "2017-05-09T04:59:50Z"}}
    end
  end

  test "show a refund" do
    use_cassette "refund_show" do
      resp = PayPal.Payments.Refunds.show("6N458369VN1308144")
      assert resp == {:ok,
                           %{amount: %{currency: "USD", total: "-1.50"},
                             create_time: "2017-05-09T04:59:50Z", id: "6N458369VN1308144",
                             invoice_number: "48787589673",
                             links: [%{href: "https://api.sandbox.paypal.com/v1/payments/refund/6N458369VN1308144",
                                method: "GET", rel: "self"},
                              %{href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-56X02727YH154025YLEISYVI",
                                method: "GET", rel: "parent_payment"},
                              %{href: "https://api.sandbox.paypal.com/v1/payments/sale/7UB09546JJ671102D",
                                method: "GET", rel: "sale"}],
                             parent_payment: "PAY-56X02727YH154025YLEISYVI", sale_id: "7UB09546JJ671102D",
                             state: "completed", update_time: "2017-05-09T04:59:50Z"}}
    end
  end
end
