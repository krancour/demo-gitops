# setup/

One-time cluster setup resources for Chapter 3. Apply these in order after
forking this repo and adding your GitHub token to `03-git-credentials.yaml`.

The Argo CD Applications render `charts/` with each environment's `envs/` values
file; nothing in this directory is rendered into the cluster by Argo CD.

## Apply order

Apply the Project before the Git credentials, Warehouse, and Stages: it
provisions the `demo` namespace those resources land in.

```bash
kubectl apply -f setup/00-namespaces.yaml
kubectl apply -f setup/01-project.yaml
kubectl apply -f setup/02-argocd-apps.yaml
kubectl apply -f setup/03-git-credentials.yaml   # add your token first
kubectl apply -f setup/04-warehouse.yaml
kubectl apply -f setup/05-stage-dev.yaml
kubectl apply -f setup/06-stage-pre-prod.yaml
kubectl apply -f setup/07-stage-prod.yaml
kubectl apply -f setup/08-projectconfig.yaml     # auto-promotion for dev
```

Apply `08-projectconfig.yaml` last. It turns on auto-promotion for the `dev`
Stage, and the chapter walks through it only after the manual dev, pre-prod, and
prod promotions, so that auto-promotion has something to demonstrate. Applying
it earlier is harmless but skips ahead of the narrative.
