### Deploy Flink Application

Now let's deploy the Flink workload to the Karmada control plane and define a policy to schedule it.

**Deploy the Flink Custom Resource and PropagationPolicy:**

<details>
<summary>flinkdeployment-cr.yaml</summary>

```yaml
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  name: flinkdeployment-sample
spec:
  flinkConfiguration:
    taskmanager.numberOfTaskSlots: "2"
  flinkVersion: v1_17
  image: flink:1.17
  job:
    args: []
    jarURI: local:///opt/flink/examples/streaming/StateMachineExample.jar
    parallelism: 2
    state: running
    upgradeMode: stateless
  jobManager:
    replicas: 1
    resource:
      cpu: 1
      memory: 100m
  serviceAccount: flink
  taskManager:
    resource:
      cpu: 1
      memory: 100m
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply --validate=false -f /root/examples/flinkdeployment-cr.yaml`{{exec}}

This applies the FlinkDeployment Custom Resource.

<details>
<summary>flink-policy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: flink-propagation
spec:
  resourceSelectors:
    - apiVersion: flink.apache.org/v1beta1
      kind: FlinkDeployment
      name: flinkdeployment-sample
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    spreadConstraints:
      - spreadByField: cluster
        maxGroups: 1
        minGroups: 1
    replicaScheduling:
      replicaSchedulingType: Divided
      replicaDivisionPreference: Aggregated
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply --validate=false -f /root/examples/flink-policy.yaml`{{exec}}

This applies the Flink PropagationPolicy.

**Why this matters:**

A Flink job requires its `JobManager` and `TaskManager` components to communicate constantly. If Karmada schedules them on different clusters, cross-cluster network latency will severely degrade performance.

If you inspect `flink-policy.yaml` (expand the section above), you'll see a specific configuration designed to prevent this:

```yaml
    spreadConstraints:
      - spreadByField: cluster
        maxGroups: 1
        minGroups: 1
```

This configuration (`maxGroups: 1` combined with `Aggregated` preference) guarantees that all components of the Flink workload will be scheduled atomistically. They will be co-located on the **same target cluster**, ensuring optimal performance while preventing resource fragmentation.
