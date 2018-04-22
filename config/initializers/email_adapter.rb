adapter = ENV['EMAIL_CLIENT'] || 'Mandrill'

adapter_hash = {
  'Mandrill' => Adapters::Mandrill,
  'Mailgun'  => Adapters::Mailgun
}

EMAIL_ADAPTER = adapter_hash[adapter]
