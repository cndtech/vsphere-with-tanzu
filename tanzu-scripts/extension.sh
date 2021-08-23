#!/bin/sh

# ! 클러스터에 인증서 추가
#   $ ./tkg-add-ca-via-sv.sh --vc_ip <vCenter IP or FQDN> --vc_admin_passowrd <vCenter PWD> --vc_admin_user <vCenter ID> --vc_root_password <vCenter PWD> --sv_ip <Sevice IP> -c <cluster name> -n <namespace name> --ca_file_path <ca path>

# ! embeded harbor secret
#   $ kubectl create secret docker-registry <secret name> --docker-server=<ip> --docker-username=<vCenter ID> --docker-password=<vCenter PWD>

EXTENSIONS=$HOME/Documents/vsphere-with-tanzu/tkg-extensions-v1.2.0+vmware.1/extensions

kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated

kubectl apply -f $EXTENSIONS/tmc-extension-manager.yaml
# kubectl create configmap vm-harbor-certs --from-file=/usr/local/share/ca-certificates/ca.crt -n vmware-system-tmc
kubectl apply -f $EXTENSIONS/kapp-controller.yaml
kubectl apply -f $EXTENSIONS/../cert-manager/

# contour ingress
# kubectl create secret docker-registry <secret name> --docker-server <image registry> --docker-username <registry ID> --docker-password <registry PWD> -n tanzu-system-ingress (필요 한 것인가??)
kubectl apply -f $EXTENSIONS/ingress/contour/namespace-role.yaml
kubectl create secret generic contour-data-values --from-file=values.yaml=$EXTENSIONS/ingress/contour/vsphere/contour-data-values.yaml -n tanzu-system-ingress
# edit secret
# kubectl create secret generic contour-data-values --from-file=values.yaml=$EXTENSIONS/ingress/contour/vsphere/contour-data-values.yaml -n tanzu-system-ingress -o yaml --dry-run=client | kubectl replace -f -
kubectl apply -f  ingress/contour/contour-extension.yaml

# ! 참고 (alias 포함)
# @ contexts 변경
#     $ kubectl config get-contexts
#     $ kcgc
#     $ kubectl config set-contexts ss-infra-cluster
#     $ kcuc ss-infra-cluster
# @ namespace 변경
#     $ kubectl get namespaces
#     $ kgns
#     $ kubectl config set-context --current --namespace vmware-system-tmc
#     $ kcn vmware-system-tmc