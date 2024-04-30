# Deploy Jitsi Meet to Kubernetes Cluster

This action is intended to update Kubernets Cluster when a change is made to
subsequent forks of
[docker-jitsi-meet](https://github.com/jitsi/docker-jitsi-meet.git).

## How to use:

### Setting variables:

You will need 3 environment variables for this action to work.

- DOCKER_USERNAME
- DOCKER_PASSWORD
- KUBECONFIG **(Kubernetes configuration file in YAML format)**

These variables will be used to build docker image and push to the target
repository with specified tag (in this case: **latest**).

### Workflow file:

After setting environment variables. Preferably as a GitHub Actions secret.
Create the `.github/workflows/update-prosody.yml` workflow file and, paste the
contents below into the workflow.

- This workflow will run everytime when a change is made under prosody/\*\* or
  the workflow itself changes.

- Docker build process will use Docker Hub cache so the build processes will be
  really fast after the first build.

- Action will try to connect to your Kubernetes cluster and delete pod(s) named
  `jitsi.*-prosody-` for you. If your deployment is pulling the images
  automatically, your image should be up in 20 seconds.

```yml
name: Build & Deploy Prosody

on:
  push:
    branches:
      - dev
      - main
    paths:
      - 'prosody/**'
      - '.github/workflows/update-prosody.yml'

concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.ref_name }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: Deploy prosody
        uses: alvelive/deploy-jitsi@master
        with:
          component: prosody
          docker-username: ${{ secrets.DOCKER_USERNAME }}
          docker-password: ${{ secrets.DOCKER_PASSWORD }}
          tag: latest
          kube-config: ${{ secrets.KUBECONFIG }} # Kubernetes configuration file in YAML format
```

### Inputs

## Action Inputs

The following inputs are required for the GitHub Action to execute properly:

### `component`

- **Description**: Specifies the Jitsi component to be deployed. Valid options
  are `jibri`, `jicofo`, `jigasi`, `jvb`, `prosody`, and `web`.
- **Required**: Yes

### `docker-username`

- **Description**: Your Docker Hub username. This is used to log in to Docker
  Hub to push the Docker images.
- **Required**: Yes

### `docker-password`

- **Description**: Your Docker Hub password. This is used in conjunction with
  the Docker username to authenticate against Docker Hub.
- **Required**: Yes

### `tag`

- **Description**: The tag to be used for the Docker image. This tag is applied
  to the image during build and push operations.
- **Required**: Yes
- **Default**: `latest`

### `context`

- **Description**: The context for the Docker Build. (e.g. Dockerfile path)
- **Required**: No
- **Default**: `'./' + ${{ inputs.component }}`

### `kube-config`

- **Description**: The Kubernetes configuration file in YAML format. This file
  should not be Base64 encoded as it is expected to be used directly.
- **Required**: Yes

### `kube-config-file`

- **Description**: The filepath where the Kubernetes configuration file should
  be stored on the system running the action.
- **Required**: No
- **Default**: `$HOME/.kubeconfig`

### Expected Outputs

If you provide the values below:

```yml
- name: Deploy prosody
  uses: alvelive/deploy-jitsi@master
  with:
    component: prosody
    docker-username: ${{ secrets.DOCKER_USERNAME }}
    docker-password: ${{ secrets.DOCKER_PASSWORD }}
    tag: latest
    kube-config: ${{ secrets.KUBECONFIG }}
```

The action will build and push the following image to Docker Hub:
`johndoe/prosody:latest`.
