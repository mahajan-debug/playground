# Create PropagationPolicy with StaticWeight

**Create PropagationPolicy for `nginx` with weighted distribution:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/propagationPolicy.yaml`{{exec}}

This applies a policy that distributes replicas across clusters using static weight scheduling.

This policy selects the nginx Deployment and divides the 3 replicas across member clusters using a 2:1 weight ratio:

- kind-member1: 2 replicas (weight: 2)
- kind-member2: 1 replica (weight: 1)

**Verify policy exists:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

This checks that the propagation policy has been successfully created.
