# Unity Builder

A Docker Compose application to kick start a Unity Jenkins build server. You can have the Jenkins CI/CD server automatically make builds whenever you want.

Example job templates are set up automatically so that hooking up to Perforce is easier.

## Getting Started

Define your environment variables by copying `.env-example` to `.env` and editing the file. `PASSWORD` will be used to set the root password for the image.

### Modify Unity setup parameters

Figure out the version, changeset number, and modules needed for the Unity version you want to use, and set the `VERSION` and `CHANGESET` parameters in the `.env` file.

To set the modules, modify this command in the Dockerfile:

```bash
xvfb-run unityhub --headless install --version <version> --changeset <changeset> -m <modules> --childmodules
```

- By default, the Dockerfile is set up to install Mac (Mono) and Windows (Mono) using the version and changeset from environment variables.
- To find the changeset number, you can go to the Unity download archive - the custom URI for the "Unity Hub" button will contain the changeset number.

For example, to install Unity 2022.3.8 with Windows and Mac Mono build support, you would run the following command based on the image below:

```bash
xvfb-run unityhub --headless install --version 2022.3.8f1 --changeset b5eafc012955 -m mac-mono windows-mono --childmodules
```

![Example on how to find the changeset](images/changeset.png)

If you are building on platforms besides Windows and Mac, you will need to change which modules you install.

### Modify Jenkins setup parameters

If you wish, you can modify the `plugins.txt` file to install the Jenkins plugins you desire and the `config.xml` files in the `jobs/` directory to provision job definitions. You can always modify the Jenkins server directly after the initial setup too.

### Starting

Once you are finished with your configuration, you can start the Docker application via Compose.

```bash
docker compose up -d
```

## Docker Post Setup

### Activate Unity

To activate Unity without a GUI, you'll need to generate an [activation file](https://docs.unity3d.com/Manual/ManualActivationGuide.html):

```bash
cd /var/jenkins_home/Unity/Hub/Editor/<version>/Editor/
./Unity -batchmode -createManualActivationFile -logfile
```

Copy the activation file to your computer. By default, the activation file name should be `Unity_v<version>.alf`. You can quickly copy the file to your Downloads folder with the `download.ps1` script. Alternatively, in Windows:

```powershell
docker cp <container>:/var/jenkins_home/Unity/Hub/Editor/<version>/Editor/<alf file> $env:userprofile\Downloads\<alf file>
```

Activate the license on Unity: https://license.unity3d.com/manual

- Note that if you don't have a serial number and are planning on using Unity Personal Edition, you'll need to use a workaround to get your license activated

Copy the license file back to server. By default, the activation file name should be `Unity_v<version year>.x.ulf`. You can quickly copy the file back to the Docker container with the `upload.ps1` script. Alternatively, in Windows:

```powershell
docker cp $env:userprofile\Downloads\<ulf file> <container>:/var/jenkins_home/Unity/Hub/Editor/<version>/Editor/<ulf file>
```

Connect to the container's terminal, and use the ulf to complete the activation:

```bash
./Unity -batchmode -nographics -manualLicenseFile <ulf file>
```

If done correctly, you should see a message saying `[Licensing::Module] License file successfully loaded.`

### Finish Jenkins setup

Log in to the Jenkins server at `localhost:8080`.

Then, set up a job or pipeline that will run the scripts needed to build from Unity.
By default, the Dockerfile copies over an example workflow that you can base your CI/CD off of.

To connect to Perforce properly, you will need to set up a Perforce Password Credential and tell the Build job to use that credential in both the "Source Code Management" and the "Post-build Actions" sections. Make sure to test the connection beforehand!

## Misc

If you receive the following error - `Error building player because build target was unsupported` - then you need to ensure your needed Unity modules are installed within the Dockerfile. Refer to the [Unity Hub CLI](https://docs.unity3d.com/hub/manual/HubCLI.html) for more info on the module names. To add modules to an existing Unity installation, run the following command:

```bash
xvfb-run unityhub --headless install-module --version <version> -m <module1> <module2> --childmodules
```

## Limitations

If you're running Docker on a Windows machine, there is currently no way to integrate NVIDIA into your Docker container and utilize Unity NVIDIA features like DLSS.
Otherwise, you can install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and set that up.
