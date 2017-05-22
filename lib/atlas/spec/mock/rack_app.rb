module Atlas
  module Spec
    module Mock
      RackApp = lambda do |body = false|
        internal_body = body || ['OK']
        ->(_env) { [200, { 'Content-Type' => 'text/plain' }, internal_body] }
      end
    end
  end
end
