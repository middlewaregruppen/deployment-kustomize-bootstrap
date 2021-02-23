# deployment-bootstrap for OpenShift/Kustomize

Helper tool to bootstrap the deployment config and kustomize setup for a new project

In order to use this, just run the following command in a bash shell

```bash
./bootstrap.sh
```

You will be asked to provide the following information

1. The OpenShift project name you want to bootstrap
2. The OpenShify environment names for
   1. dev
   2. test
   3. prod

Once this is done, the script will copy the contents of the Deployments folder into a new folder ```build``` that will contain one folder with the name of the project you indicated.

So the resulting tree structure will be as follows

```text
build
└── Deployments
    └── yourprojectname
        ├── base
        │   ├── deployment.yaml
        │   ├── kustomization.yaml
        │   ├── route.yaml
        │   └── service.yaml
        └── overlays
            ├── dev
            │   ├── kustomization.yaml
            │   └── sizing.yaml
            ├── prod
            │   ├── kustomization.yaml
            │   └── sizing.yaml
            └── test
                ├── kustomization.yaml
                └── sizing.yaml
```
You can copy the ```Deployments``` folder to your project and commit it.