# deployment-bootstrap for OpenShift/Kustomize

Helper tool to bootstrap the deployment config and kustomize setup for a new project

In order to use this, just run the following command in a bash shell

```bash
./bootstrap.sh
```

You will be asked to provide the following information

1. The OpenShift project name you want to bootstrap
2. How many environments you need (max 5)
3. For each of the environments, you'll be asked the short name (eg: dev, test, prod)
4. And the corresponding OpenShift environment name (eg: online-dev, online-test etc.)

Once this is done, the script will copy the contents of the Deployments folder into a new folder ```build``` that will contain one folder with the name of the project you indicated.

So the resulting tree structure will be as follows (assuming envs chosen were dev, test and prod)

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

You can copy the ```Deployments``` folder to your project and commit it, or if you are generating a new base set of deployment scripts for another service, just copy the ```yourprojectname``` folder to the ```Deployments``` folder in your project.

### To be done

1. Offer the same script in powershell
2. Add in an option for number of replicas during the environment phase with a default of 1 replica
