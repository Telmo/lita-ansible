require 'pathname'
require 'open3'

module Lita
  module Handlers
    class Ansible < Handler
      config :ansible_directory


      route(/ansible update/, :ansible_update, command: true, help: {
        "ansible update" => "Clears out the local roles and reclones them using ansible-galaxy."
      })

      route(/ansible list\s(?<type>roles|playbooks)/, :ansible_list, command: true, help: {
        "ansible update" => "List the roles or Playbooks known to the bot."
      })

      route(/ansible deploy\s/, :ansible_update, command: true, help: {
        "ansible update" => "Clears out the local roles and reclones them using ansible-galaxy."
      })

      def ansible_update(response)
        response.reply "Starting Module Update..."
        Dir.chdir(config.ansible_directory)
        # Precaution
        Dir.mkdir("roles") unless File.exists?("roles")
        update = run_command("ansible-galaxy install -p roles/ -r requirements.yml")
        if update[0] == true
          response.reply "Successfuly Finished Module Update"
        else
          response.reply "I am sorry something went terrible bad because: #{update[2].to_s}"
        end
      end

      def ansible_list(response)
        type = response.matches[:type].downcase
        case type
        when "roles"
          response.reply list_roles
        when "playbooks"
          response.reply list_playbooks
        else
          response.reply "That is not a valid thing to list"
        end
      end

      private

      def list_roles
        begin
          Dir.chdir(config.ansible_directory + "/roles")
          # I could probably write this a bit more defensibly... assign the output to a
          # variable and only print out if the variable exist.. but I don't think is necessary.
          "Known roles: " + Dir.glob('*').select {|c| File.directory? c }.join(' ')
        rescue => kaboom
          "I am sorry something went terrible bad because: #{kaboom.message}"
        end
      end

      def list_playbooks
        begin
          Dir.chdir(config.ansible_directory)
          # This is very naive in assuming that all .yml files are playbooks and not something else
          "Known playbooks: " + (Dir.glob('*.yml') - ["requirements.yml"]).join(' ')
        rescue => kaboom
          "I am sorry something went terrible bad because: #{kaboom.message}"
        end
      end

      def run_command(command)
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          return [wait_thr.value, stdout, stderr]
        end
      end

    end

    Lita.register_handler(self)
  end
end
