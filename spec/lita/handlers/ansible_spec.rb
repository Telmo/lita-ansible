require "spec_helper"

describe Lita::Handlers::Ansible, lita_handler: true do

  it do
    is_expected.to route_command('ansible deploy test').to(:ansible_deploy)
    is_expected.to route_command('ansible update').to(:ansible_role_update)
  end

  describe '#deploy with ansible' do
    it 'deploys an ansible playbook to a list of hosts' do
      send_command('ansible deploy test')
      puts replies.last
      #expects(replies).to_not be_empty
    end
  end

  describe '#update ansible roles' do
    it 'updates the roles used by ansible with ansible-galaxy' do
      send_command('ansible update')
      puts replies
      #expects(replies).to_not be_empty
    end
  end
end
