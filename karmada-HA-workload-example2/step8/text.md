# Verify Weighted Distribution Across Clusters

**Check distributed deployment status:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment`{{exec}}

This shows the nginx deployment status aggregated across all member clusters. You should see `3/3` pods READY.

> **Note:** If READY shows `0/3`, wait ~30 seconds and run the command again — Karmada's scheduler needs a moment to reconcile and propagate the workload to member clusters.

**Check binding status:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding`{{exec}}

This confirms that the ResourceBinding was scheduled and fully applied to the member clusters.

**Check distributed pod status:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods`{{exec}}

This shows the running pods across member clusters. If it briefly returns no resources, wait a few seconds and run it again after reconciliation completes.
