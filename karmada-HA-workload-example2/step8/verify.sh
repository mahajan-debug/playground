#!/bin/bash
set -e

karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding
karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods
