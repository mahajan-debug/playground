### Inspect the Flink ResourceBinding

When you apply a workload, Karmada uses its Resource Interpreter to analyze the custom resource, extract its requirements, and wrap it into a `ResourceBinding`. Let's inspect this binding to see what Karmada discovered.

First, extract the dynamic binding name into a variable:

RUN `BINDING_NAME=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding -n default -o json | jq -r '.items[] | select(.spec.resource.kind=="FlinkDeployment") | .metadata.name')`{{exec}}

#### Replicas

Let's check if Karmada successfully parsed the `spec.components` array. The array should contain exactly 2 distinct components:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $BINDING_NAME -n default -o json | jq '.spec.components | length'`{{exec}}

This outputs `2`, confirming exactly two distinct components were extracted.

Check the specific names of the components Karmada identified:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $BINDING_NAME -n default -o json | jq '.spec.components[].name'`{{exec}}

This outputs `"jobmanager"` and `"taskmanager"`.

#### Resource Requirement

The Flink manifest specified `parallelism: 2` and `taskmanager.numberOfTaskSlots: "2"`. Using the Lua interpreter we applied earlier, Karmada correctly calculates that `ceil(2/2) = 1` taskManager replica is needed. Let's verify that Karmada captured this, along with the CPU (1) and memory (100Mi) requests:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $BINDING_NAME -n default -o json | jq '.spec.components[] | select(.name=="taskmanager") | .replicaRequirements.resourceRequest'`{{exec}}

This outputs a JSON object with `"cpu": "1"` and `"memory": "100Mi"`.

#### Scheduling Result

Check that the workload was successfully scheduled by the Karmada control plane:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $BINDING_NAME -n default -o json | jq '.status.conditions[] | select(.type=="Scheduled") | .status'`{{exec}}

This outputs `"True"`, indicating the workload was successfully scheduled.

Finally, let's see which cluster it landed on and verify that the Flink components actually exist there:

RUN `TARGET_CLUSTER=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $BINDING_NAME -n default -o json | jq -r '.spec.clusters[0].name')`{{exec}}

This extracts the scheduled target cluster into a variable.

Verify that the FlinkDeployment exists on the target cluster:

RUN `kubectl --kubeconfig=$HOME/.kube/config-${TARGET_CLUSTER#kind-} get flinkdeployment -n default`{{exec}}

This lists the `flinkdeployment-sample` resource, verifying it exists on the target cluster.
