# Prerequisites  

Before you begin, ensure you have the following installed and configured:  

- **Container Runtime:** Docker or Podman  
- **Helm:** Version 3.x (if using Helm)  
- **Kubernetes CLI:** `kubectl` installed and configured to interact with your Kubernetes cluster  
- **Kind:** Kubernetes-in-Docker (kind) installed  
- **Infrastructure Automation:** Ansible or Terraform  
- **Optional Tools:** k9s (for better cluster management)  

---

# Setting Up the Demo with Ansible  

Run the following Ansible playbook to prepare the demo environment:  

```sh
cd ansible
ansible-playbook kind_build.yaml -v
```

Verify the setup:  

```sh
kind get clusters
kubectl get ns
```

---

# Installing Kro  

Fetch the latest Kro version and install it using Helm:  

```sh
export KRO_VERSION=$(curl -sL \
    https://api.github.com/repos/kro-run/kro/releases/latest | \
    jq -r '.tag_name | ltrimstr("v")'
  )

echo $KRO_VERSION  # Example output: 0.2.1

helm install kro oci://ghcr.io/kro-run/kro/kro \
  --namespace kro \
  --create-namespace \
  --version=${KRO_VERSION}
```

Verify the installation:  

```sh
kubectl get ns
kubectl get pods -n kro
```

---

# Deploying Kro with Terraform  

Initialize and apply the Terraform configuration:  

```sh
terraform init
terraform plan -out tfplan
terraform apply tfplan -var="kro_version=0.2.1"
```

---

# Manual Deployment  

Navigate to the deployment directory and apply the necessary Kubernetes manifests:  

```sh
cd ./demo/
kubectl apply -f test-instance.yaml
kubectl apply -f test-rgd.yaml
```

---

# Verifying the Deployment  

### Check the ResourceGraphDefinition (RGD) status  

```sh
kubectl get rgd -o wide
```

**Example Output:**  

```
NAME             APIVERSION   KIND          STATE      TOPOLOGICALORDER                     AGE
my-application   v1alpha1     Application   Active     ["deployment","service","ingress"]   5m43s
postgres-db      v1alpha1     Application   Inactive                                        3s
```

### Check the deployment status  

```sh
kubectl get po,svc,ingress -n default
```

---

# Developer Workflow  

### Updating Ingress Version  

To modify the ingress version, update the instance specification:  

```yaml
image: nginx:1.26.0
```

### Fun Deployment  

For developers who want to experiment:  

```sh
kubectl apply -f fun/doom-instance.yaml
kubectl apply -f fun/doom-rg.yaml
k9s
<shift-f>
```

---

# Troubleshooting  

### Check Logs for Errors  

```sh
kubectl get pods -n kro
kubectl logs kro-b667bd485-q2lg2 -n kro | grep ERROR
```

### Remove Inactive Resources  

```sh
kubectl rgd delete postgres-db
```

---

# Understanding Kro  

## What is ResourceGraphDefinition (RGD)?  

A **ResourceGraphDefinition (RGD)** is a declarative way to define and manage related Kubernetes resources efficiently.  

### **Key Features:**  

- **Schema Definition:** Specifies the fields users can provide when creating an instance, including default values and types.  
- **Resource Templates:** Uses templates to dynamically create Kubernetes resources based on the schema.  
- **Dependency Management:** Ensures resources are created in the correct order (e.g., a Service depends on a Deployment).  
- **Conditional Resources:** Supports conditions like enabling/disabling Ingress dynamically based on instance configurations.  

### **Workflow Overview:**  

1. **Define the RGD:** Create an RGD that specifies the schema and templates.  
2. **Instantiate Resources:** Use an `Instance` to deploy resources based on the RGD.  
3. **Deploy to Kubernetes:** The RGD processes dependencies and provisions resources in the correct order.  

---

# Comparison: Standard Kubernetes vs. Kro  

| Feature | Standard Kubernetes | Kro (RGD + InstanceSet) |
|---------|----------------------|------------------------|
| **Resource Management** | Manages resources (ConfigMap, Deployment, Secret, etc.) separately. | Manages multiple related resources as a single unit. |
| **Deployment Process** | Uses standard Kubernetes objects. | Extends capabilities with role-based management, HA, and updates. |
| **Scaling & Updates** | Manual scaling and rolling updates. | Supports automatic scaling and rolling updates. |
| **Dependency Handling** | Requires manual ordering of resource creation. | Ensures correct order with DAG-based execution. |
| **Networking** | Uses standard Kubernetes networking. | Provides stable network identifiers via InstanceSet. |

---

# Summary  

Using **ResourceGraphDefinition** and **InstanceSet** provides:  

✅ **Unified Resource Management:** Manage multiple resources together, ensuring consistency.  
✅ **Automated Dependency Management:** Uses DAG to order resource creation properly.  
✅ **Custom APIs for Control:** Generates CRDs for structured deployment.  
✅ **Advanced Features:** Enables role-based access, high availability, and deterministic updates.  
✅ **Stable Networking:** Assigns fixed instance names with Headless Services for reliable networking.  
✅ **Efficient Scaling:** Supports automatic scaling and controlled rolling updates.  

By leveraging Kro’s **RGD** and **InstanceSet**, you simplify deployment, improve reliability, and gain powerful features beyond standard Kubernetes deployments. 🚀  
