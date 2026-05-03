# Verify duplicated distribution across clusters

**Check distributed deployment status:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment`{{exec}}

This shows the nginx deployment status aggregated across all member clusters. You should see `2/1` pods READY as shown below. 

![Expected deployment status](../image/deploymentstatus.png)

The deployment spec defines `1` replica, but Duplicated mode copies it to every cluster, so 2 pods are running in total (1 per cluster).



> **Note:** If READY shows `0/1`, wait ~30 seconds and run the command again — Karmada's scheduler needs a moment to reconcile and propagate the workload to member clusters.

**Check binding status:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding`{{exec}}

This confirms that the ResourceBinding was scheduled and fully applied to the member clusters.

**Check pods on each member cluster directly:**

RUN `kubectl --kubeconfig $HOME/.kube/config-member1 get pods`{{exec}}

RUN `kubectl --kubeconfig $HOME/.kube/config-member2 get pods`{{exec}}

Each cluster should show exactly 1 nginx pod running — a full duplicate on each cluster.
