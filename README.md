# Current Lab Setup

Kind cluster - locally on mac (using podman backend)

# Preping DEMO with ansible
```sh
cd ansible
ansible-playbook kind_build.yaml -v
```
```sh
kind get clusters
kubectl get ns
```
# Installing Kro

## Prerequisites
Before you begin, ensure you have the following:
- Helm 3.x installed (if using Helm)
- `kubectl` installed and configured to interact with your Kubernetes cluster

```sh
export KRO_VERSION=$(curl -sL \
    https://api.github.com/repos/kro-run/kro/releases/latest | \
    jq -r '.tag_name | ltrimstr("v")'
  )

echo $KRO_VERSION
0.2.1

helm install kro oci://ghcr.io/kro-run/kro/kro \
  --namespace kro \
  --create-namespace \
  --version=${KRO_VERSION}
```

Check running pods:
```sh
kubectl get ns
kubectl get pods -n kro
```

---

# Terraform
```sh
terraform init
terraform apply -var="kro_version=0.2.1"
```

# Manual
```sh
cd /Users/darrenlavery/Documents/code/Kro_demo/kro-app/example-app/works/
kubectl apply -f test-instance.yaml
kubectl apply -f test-rgd.yaml
```

# Check the RGD: 
```sh
kubectl get rgd  -owide                           
NAME             APIVERSION   KIND          STATE      TOPOLOGICALORDER                     AGE
my-application   v1alpha1     Application   Active     ["deployment","service","ingress"]   5m43s
postgres-db      v1alpha1     Application   Inactive                                        3s
```

# Check deployment
``` sh
kubectl get po,svc,ingress -n default
```

# DEV wants to drop ingress version (edit the instance)
image: nginx:1.26.0

# DEV Wants to have fun
kubectl apply -f fun/doom-instance.yaml
kubectl apply -f fun/doom-rg.yaml
k9s
<shift-f>



# Troubleshoot: rgd check the logs on the kro controller:
```sh
NAME                  READY   STATUS    RESTARTS   AGE
kro-b667bd485-q2lg2   1/1     Running   0          44m
```
```sh
kubectl logs kro-b667bd485-q2lg2 -n kro | grep ERROR
```

# To remove inactive: 
```sh
kubectl rgd delete postgres-db 
```

---

# Understanding KRO

## Key Points about ResourceGraphDefinition

- **Schema Definition:** Defines the schema for the custom resource, specifying the fields that users can provide when creating an instance, including default values and types.
- **Resource Templates:** Contains templates for Kubernetes resources that will be created based on the schema. These templates use placeholders to dynamically insert values provided by the instance.
- **Dependency Management:** Ensures resources are created in the correct order (e.g., a Service depends on a Deployment being created first).
- **Conditional Resources:** Supports conditional creation of resources, such as an Ingress being created only if `ingress.enabled` is set to `true`.

## Example Workflow
1. **Define the ResourceGraphDefinition:** Create an RGD that specifies the schema and resource templates.
2. **Create an Instance:** Use the `Instance` kind to create an instance based on the RGD, providing specific values for the schema fields.
3. **Deploy Resources:** The instance uses the RGD to deploy the specified resources in the Kubernetes cluster.

---

# Comparison

## Resource Management
- **Normal Deployment:** Manage each resource (ConfigMap, Deployment, Namespace, Secret, Service) separately.
- **ResourceGraphDefinition:** Define and manage multiple related resources as a single unit, ensuring consistency and correct order of creation.

## Deployment
- **Normal Deployment:** Uses standard Kubernetes resources with basic features.
- **InstanceSet:** Extends capabilities with features like role-based management, high availability, and in-place updates, particularly useful for stateful workloads.

## Scaling and Updates
- **Normal Deployment:** Manual scaling and rolling updates with limited control.
- **InstanceSet:** Efficient horizontal scaling and deterministic rolling updates, ensuring high availability and performance.

## Network Identifiers
- **Normal Deployment:** Standard network identifiers.
- **InstanceSet:** Generates fixed names for each instance and creates a Headless Service, providing stable network identifiers.

---

# Summary

### The main differences between using a ResourceGraphDefinition with InstanceSet and a normal Kubernetes deployment:

1. **Unified Management:** ResourceGraphDefinition allows defining and managing multiple related resources as a single, reusable unit. This ensures resources are deployed together with the correct configuration.
2. **Dependency Management:** ResourceGraphDefinition treats resources as a Directed Acyclic Graph (DAG), ensuring correct deployment order based on interdependencies.
3. **Custom APIs:** Creating a ResourceGraphDefinition generates a Custom Resource Definition (CRD) in your cluster, allowing for structured and controlled resource deployment.
4. **InstanceSet Features:** Extends native Kubernetes resources like StatefulSet and Deployment with advanced features such as role-based management, high availability, and deterministic rolling updates.
5. **Stable Network Identifiers:** InstanceSet assigns fixed names to instances and creates a Headless Service, ensuring stable network identifiers for communication.
6. **Efficient Scaling and Updates:** Supports horizontal scaling and rolling updates, maintaining high availability and performance.

Using **ResourceGraphDefinition** and **InstanceSet** provides a more structured, efficient, and reliable way to manage complex deployments, especially for stateful workloads. It simplifies deployment, ensures consistency, and offers advanced features unavailable in standard Kubernetes deployments.
