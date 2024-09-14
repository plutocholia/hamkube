## CRDs

resource "helm_release" "prometheus_operator_crds" {
  name       = "prometheus-operator-crds"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-operator-crds"
  version    = "9.0.1"
  create_namespace  = true
}

## Cert-Manager

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.3"
  create_namespace  = true
  
  values = [
    "${file("files/cert-manager/values.yaml")}"
  ]
}

## Storage

resource "helm_release" "openebs" {
  name       = "openebs"
  namespace  = "openebs"
  repository = "https://openebs.github.io/charts"
  chart      = "openebs"
  version    = "3.10.0"
  create_namespace  = true

  values = [
    "${file("files/openebs/values.yaml")}"
  ]
}

resource "kubectl_manifest" "openebs_hostpath_x_storage_class" {
  yaml_body = "${file("files/openebs/openebs-hostpath-x-storageclass.yml")}"
  depends_on = [ helm_release.openebs ]
}

## Ingress

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2"
  create_namespace  = true

  values = [
    "${file("files/ingress-nginx/values.yaml")}"
  ]

  depends_on = [ helm_release.prometheus_operator_crds ]
}

## Monitoring Stack

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"
  create_namespace  = true

  values = [
    "${file("files/kube-prometheus-stack/values.yaml")}"
  ] 

  depends_on = [ 
    helm_release.prometheus_operator_crds,
    kubectl_manifest.openebs_hostpath_x_storage_class,
    helm_release.ingress-nginx
  ]
}

## HamHook

resource "helm_release" "hamhook" {
  name       = "hamhook"
  namespace  = "hamhook"
  repository = "https://plutocholia.github.io/hamhook"
  chart      = "hamhook"
  version    = "0.1.1"
  create_namespace  = true

  depends_on = [ helm_release.cert-manager ]
}

resource "kubectl_manifest" "hamhook_test_pod" {
  yaml_body = "${file("files/hamhook-tests/manifests.yaml")}"
  depends_on = [ helm_release.hamhook ]
}
