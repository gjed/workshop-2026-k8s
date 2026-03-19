SSH_KEY := marco.pernigo.key
SSH_USER := workshop
MASTER := 3.67.26.50
WORKER_1 := 10.0.1.154

SSH_OPTS := -o StrictHostKeyChecking=no

.PHONY: ssh-master ssh-worker nodes help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

ssh-master: ## SSH into the master node
	ssh -i $(SSH_KEY) -l $(SSH_USER) $(SSH_OPTS) $(MASTER)

ssh-worker: ## SSH into worker node 1 (via master jump host)
	ssh -l $(SSH_USER) -i $(SSH_KEY) $(SSH_OPTS) \
		-o ProxyCommand="ssh $(SSH_OPTS) -W %h:%p -q -i $(SSH_KEY) -l $(SSH_USER) $(MASTER)" \
		$(WORKER_1)

nodes: ## List cluster nodes (runs on master)
	ssh -i $(SSH_KEY) -l $(SSH_USER) $(SSH_OPTS) $(MASTER) kubectl get nodes
