module Lita
  module Handlers
    class Ansible < Handler
      # insert handler code here

      Lita.register_handler(self)
    end
  end
end
