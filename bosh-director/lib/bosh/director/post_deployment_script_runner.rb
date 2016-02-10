module Bosh::Director
  class PostDeploymentScriptRunner

    def self.run_post_deploys_after_resurrection(deployment)
      instances = Models::Instance.filter(deployment: deployment).exclude(vm_cid: nil).all
      agent_options = {
          timeout: 10,
          retry_methods: {get_state: 0}
      }

      ThreadPool.new(:max_threads => Config.max_threads).wrap do |pool|
        instances.each do |instance|
          pool.process do
            agent = AgentClient.with_vm_credentials_and_agent_id(instance.credentials, instance.agent_id, agent_options)
            agent.run_script('post_deploy', {})
          end
        end
      end
    end
  end
end