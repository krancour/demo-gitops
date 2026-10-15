# setup/

One-time cluster setup resources for chapter 3. The chapter creates them one at
a time with the Argo CD and Kargo CLIs; this directory is the same material in
one place, for tearing down and rebuilding.

Run `configure.sh` first so every file points at your fork. The Argo CD
Applications render `charts/demo-app` with each environment's `envs/` values
file; nothing in this directory is rendered into the cluster by Argo CD.

## Apply order

```bash
argocd appset create setup/01-applicationset.yaml
kargo create project demo
kargo create repo-credentials --project demo demo-git-creds --git \
  --repo-url https://github.com/<your-org>/demo-gitops.git \
  --username <your-github-username> --password "$(gh auth token)"
kargo apply -f setup/03-warehouse.yaml
kargo apply -f setup/04-stage-dev.yaml
kargo apply -f setup/05-stage-pre-prod.yaml
kargo apply -f setup/06-stage-prod.yaml
kargo apply -f setup/07-projectconfig.yaml   # auto-promotion for dev
```

`setup/02-project.yaml` is the Project as `kargo create project demo` creates
it; `kargo apply -f setup/02-project.yaml` is equivalent.

The Git credentials are never stored in a file: `kargo create repo-credentials`
builds the Secret from the token `gh auth token` prints.

Apply `07-projectconfig.yaml` last. It turns on auto-promotion for the `dev`
Stage, and the chapter walks through it only after the manual dev, pre-prod, and
prod promotions, so that auto-promotion has something to demonstrate. Applying
it earlier is harmless but skips ahead of the narrative.
