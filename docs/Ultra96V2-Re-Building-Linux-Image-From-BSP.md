<br id="toc">

# Avnet Ultra96V2: Re-Building Linux image from pre-built BSP 2023.2

#### Instructive writing describing a specific use case



Table of Contents

<a href="#intro">Intro</a>

```
	Audience
	The use case
	Refresher on BSP building
```

<a href="#ch1">Chapter 1</a>

```
	1. Getting BSP and creating PetaLinux project
```

<a href="#ch2">Chapter 2</a>

```
	2. Adjustments to the Project 
    
		2.1 Start
		2.2 Parameter KEEP_WORK
		2.3 Parameter BOOT_METHOD
```

<a href="#ch3.1">Chapter 3.1</a>

```
	3 Adjustments to the Project specific for my case

		3.1 Configuring and building U-Boot

			3.1.1 USB-Ethernet dongle
			3.1.2 U-Boot patching
			3.1.3 Building U-Boot
```

<a href="#ch3.2">Chapter 3.2</a>

```
		3.2 Reducing RootFS

			3.2.1 Step 1. Adding the layer
			3.2.2 Step 2. Users
		
		3.3 Reducing kernel
```

<a href="#ch4">Chapter 4</a>

```
	4. Rebuilding the image
    
		4.1 Populating SD card
```

<a href="#outro">Outro</a>

```
	List of Xilinx User Guides
```



<br id="intro">

# Avnet Ultra96V2: Re-Building Linux image from pre-built BSP 2023.2


## Audience

<br>

This article is for ones who have built BSP for Avnet's Ultra96V2 board using
"single-button" script provided in Avnet SDK (further, "SDK").
The script allows to change a few parameters of an image before building.

Let's consider another scenario: you have a pre-built BSP and want
to customize and re-build an image.

Using this work as an example, you can get some introductory vision on
Xilinx-style BSP customization.

Would be useful if you had some familiarity with concepts of Yocto project.


## The use case

<br>

My goal is to build customized Linux distribution image with 
**minimal root file system**  and **minimal kernel**.

Also I need to maintain  **two**  image configurations with different  **boot methods**  :

- rootfs is in RAM ("INITRD")
- rootfs is on SD card ("EXT4")

Besides that, I want to apply my patch to U-Boot sources fetched by the BSP.


## Refresher on BSP building

<br>

Avnet SDK provides scripts to build a Xilinx-style board support package
(PetaLinux BSP) which in turn can be a starting point to build a customized image.

We have two options: to build BSP from scratch using the SDK or use a pre-built BSP.

In the first case, you clone three repositories from the Avnet
github page - "bdf", "hdl" and "petalinux", checkout proper branches, 
for example "2023\.2", run a "single-button" script and hope that an image builds successfully.

In the second case, a pre-built BSP provides the correct versions of Avnet scripts
and configuration files for your specific board. Along with that, you have
pre-built ready-to-go binary artifacts that comprise a Linux distribution image.
You can start customizing your image from there.

As mentioned earlier, the article explores the second case.

I used the pre-built BSP 'u96v2\_sbc\_base\_2023\_2\.bsp' (further BSP\.u96v2-2023\.2),
with upload date: July 2024.

<a href="#toc">TOC</a>
<a href="#intro">Up this chapter</a>

<br id="ch1">

## 1. Getting BSP and creating PetaLinux project

<br>

Presuming that Vitis kit and PetaLinux had been installed on the host machine,
run the scripts to setup Vitis environment in your build shell:

```
. [path_to_petalinux]/petalinux-v2023.2/settings.sh
. [path_to_vivado]/Vivado/2023.2/settings64.sh
. [path_to_vitis]/Vitis/2023.2/settings64.sh
```


You can find the BSP at the Avnet sharepoint page. You can navigate there manually from
Element14 community's page for Ultra96V2 - https://community.element14.com/,
then find the link named "Ultra96-V2 – PetaLinux 2020+ BSP (Sharepoint site)"

or use the following link:

https://avtinc.sharepoint.com/teams/ET-Downloads/Shared%20Documents/Forms/AllItems.aspx?id=%2Fteams%2FET%2DDownloads%2FShared%20Documents%2Fprojects%2Fpublic%5Frelease%2F2023%2E2%2FBSP&viewid=dba68156%2Dce4b%2D4ebb%2Db7a7%2Dec03b27b013d

You need files:

- u96v2\_sbc\_base\_2023\_2\.bsp
- u96v2\_sbc\_base\_2023\_2\.bsp\.md5


Choose you working directory and in the build shell create a PetaLinux project
from .bsp file ('project' is not a name, it is a type of the object we
want to create):

`$ petalinux-create -t project -s [path_to_bsp_file]/u96v2_sbc_base_2023_2.bsp`


After unpacking, you will get the project directory 'u96v2\_sbc\_base\_2023\_2'.

<a href="#toc">TOC</a>
<a href="#ch1">Up this chapter</a>



<br id="ch2">


## 2. Adjustments to the Project

<br>

The SDK provides a main "single-button" build script for every specific
 'board' / 'hw configuration'.

Each main script runs or includes other scripts, which in turn either set
configuration parameters or provide helping shell functions.

BSP\.u96v2-2023\.2 provides four scripts picked from the SDK
(can be found in 'u96v2\_sbc\_base\_2023\_2/pre-built/linux/images'):

- rebuild\_u96v2\_sbc\_base\.sh (modification of the original make\_u96v2\_sbc\_base\.sh)
- config\.boot\_method\.EXT4\.sh
- config\.boot\_method\.INITRD\.sh
- common\.sh




Printing substantial part of 'rebuild\_u96v2\_sbc\_base\.sh' here:

```
	...

HDL_PROJECT_NAME=base
HDL_BOARD_NAME=u96v2_sbc

ARCH="aarch64"
SOC="zynqMP"

PETALINUX_BOARD_FAMILY=u96v2
PETALINUX_BOARD_NAME=${HDL_BOARD_NAME}
PETALINUX_BOARD_PROJECT=${HDL_PROJECT_NAME}
PETALINUX_PROJECT_ROOT_NAME=${PETALINUX_BOARD_NAME}_${PETALINUX_BOARD_PROJECT}

# Use the PETALINUX_BUILD_IMAGE variable to build a different yocto image than the default petalinux-image-minimal
#PETALINUX_BUILD_IMAGE=avnet-image-full

KEEP_CACHE="true"
KEEP_WORK="false"
DEBUG="no"

#NO_BIT_OPTION can be set to 'yes' to generate a BOOT.BIN without bitstream
NO_BIT_OPTION='yes'

source ${MAIN_SCRIPT_FOLDER}/common.sh

verify_environment

BOOT_METHOD='EXT4'
build_bsp

	...

```

'rebuild\_u96v2\_sbc\_base\.sh' script does not provide enough flexibility
to adjust the project the way I need. So, instead of changing the SDK workflow
in the script I will to use PetaLinux command line utilities directly,
which is a nominal way to customize an image.

Also, I made a set of scripts - **u96v2-bsp-tweak-kit** - that manipulate project
parameters. Please find it in GitHub:

[https://github.com/malus-brandywine/u96v2-bsp-tweak-kit](https://github.com/malus-brandywine/u96v2-bsp-tweak-kit)


### 2.1 Start


Reminder before the start: PetaLinux utilities and the scripts provided
in the tweak kit must be run in the build shell with Vitis/PetaLinux
environment set (mentioned in Chapter 1, paragraph 1).
We start configuring the PetaLinux project with deploying configuration files.
In your working directory in the build shell run the command:

`$ petalinux-config -p u96v2_sbc_base_2023_2 --get-hw-description=u96v2_sbc_base_2023_2/hardware/u96v2_sbc_base_2023_2`

You will get ncurses-based menu, just exit it for now and let the command
do its job - it places configuration files into 'u96v2\_sbc\_base\_2023\_2/build/conf/'.


Next, let's create directory 'images/linux' in the project:

`$ mkdir -p u96v2_sbc_base_2023_2/images/linux`


Also, copy the tweak kit files into your working directory.


### 2.2 Parameter KEEP\_WORK


I need to be able to choose whether I keep components' temporary workspaces
(see class 'rm_work' in Yocto Manual) after they have been built.

The rebuild script mentions KEEP\_WORK parameter, but it never lets the parameter to give an effect.
As mentioned above, I don't want to rearrange the workflow juggling with the SDK functions,
so I wrote the script 'keep\_work.sh' to switch between "Keep"-ing and "Drop"-ing
workspaces.

For example, run the script to set dropping workspaces:

`$ ./keep_work.sh  u96v2_sbc_base_2023_2  Drop`

The change is applied to 'u96v2\_sbc\_base\_2023\_2/build/conf/local.conf'


### 2.3 Parameter BOOT\_METHOD


While maintaining images with the two boot methods, I need to be able to switch between the two image boot methods -
'EXT4' (SD card) and 'INITRD' because I use both image versions while I
debug my applications. Since we don't use the rebuild script, let's apply changes the other way.

'pre-built/linux/images' directory provides two relevant scripts picked from the SDK:

- config.boot\_method\.EXT4\.sh and
- config.boot\_method\.INITRD\.sh

Both of them tweak auto-generated project configuration files:

- u96v2\_sbc\_base\_2023\_2/project-spec/configs/config and
- u96v2\_sbc\_base\_2023\_2/project-spec/configs/rootfs\_config
accordingly to the chosen boot method.


Those 'config.boot\_method\.*\.sh' scripts expect to find the config files
at the fixed relative path.
I modified the scripts so they use a parameter as a path to PetaLinux project.

Besides that, 'config.boot\_method.INITRD.sh' has a minor bug in Ultr96V2 board support
(in the given version of BSP). I fixed that.


Also, I added two other "run" scripts that compose the proper command line for the
two aforementioned scripts. They also require input parameter: the project name.

`$ ./run.config.EXT4.sh u96v2_sbc_base_2023_2`

or

`$ ./run.config.INITRD.sh u96v2_sbc_base_2023_2`


```
Important!  In 'run.config.INITRD.sh', the name of ramdisk image INITRAMFS_IMAGE
is set to 'u96v2exp-image-core' to match the recipe name I will introduce later
in the document. You might want to use 'avnet-image-minimal' or something else.
```

Reasoning of using the scripts. Normal way to configure boot method is to run
'petalinux-config' with parameter '-c rootfs'. It offers ncurses-based menu
where you set proper parameters. Using the tweak kit scripts is a faster way
to update the configuration files.

<a href="#toc">TOC</a>
<a href="#ch2">Up this chapter</a>


<br id="ch3.1">

## 3 Adjustments to the Project specific for my case


### 3.1 Configuring and building U-Boot


#### 3.1.1 USB-Ethernet dongle


I need to enable my USB - Ethernet dongle, it gives me Ethernet connection
to "tftpboot" my executable file into RAM.
We can configure U-Boot with 'petalinux-config':

`$ petalinux-config -p u96v2_sbc_base_2023_2 -c u-boot`

The command opens ncurses-based U-Boot config menu. I select option:

**Device Drivers** --->
**USB support** --->
**USB to Ethernet Controller Drivers** --->
**Realtek RTL8152B/8153 Support**

Done. Save. Exit.

```
Side note. 'petalinux-build' utility would make the same effect:

$ petalinux-build -p u96v2_sbc_base_2023_2 -c u-boot-xlnx -x menuconfig
```

#### 3.1.2 U-Boot patching


For ZynqMP platforms, U-Boot switches from EL2 to EL1 when it
executes "go" command. Which is reasonable, but not for the case when
U-Boot runs a component that should be started at EL2 (in a debugging scenario).
To solve it, I made a patch for 'zynqmp\.c': **Switch-To-EL2-if-debug\.patch**.

The patched U-Boot switches to EL1 with the standard "go" command, as usual:

`ZynqMP> go [addr]`

but stays in EL2 when the additional parameter "debug" is passed:

`ZynqMP> go [addr] debug`


If you fulfilled step 3.1.1 "USB-Ethernet dongle", than you already have U-Boot sources in
the temporary workspace directory and you can apply the patch.
Copy 'Switch-To-EL2-if-debug\.patch' into

'u96v2\_sbc\_base\_2023\_2/build/tmp/work/u96v2\_sbc\_base\_xczu3eg-xilinx-linux/u-boot-xlnx/1_v2023.01-...-r0/git'

and in that directory run:

`$ patch -b -p1 < Switch-To-EL2-if-debug.patch`

Done.


If you skipped step 3.1.1 "USB-Ethernet dongle", than you need to setup U-Boot sources into
the temporary workspace directory first.
Run command:

`$ petalinux-build -p u96v2_sbc_base_2023_2 -c u-boot-xlnx -x configure`

It will unpack sources into the workspace directory (along with succeeding default silent patching and configuring) so you can apply the patch as described above.



#### 3.1.3 Building U-Boot


We build U-Boot with utility 'petalinux-build':

`$ petalinux-build -p u96v2_sbc_base_2023_2 -c u-boot-xlnx`


<a href="#toc">TOC</a>
<a href="#ch3.1">Up this chapter</a>

<br id="ch3.2">

### 3.2 Reducing RootFS


In some cases root filesystem has to be considerably smaller than the one that
'avnet-image-minimal' produces. 
I chose to add my own Yocto layer 'meta-u96v2-experiment' to avoid fixing
Avnet recipes. The new layer includes only one recipe, it designed to build image
'u96v2exp-image-core'.


What is in the recipe.

**First**, I made an image to inherit from class 'core-image', it means that it
will not include packages added by PetaLinux and Avnet layers.

**Second**, the following features, that are useful for my specific setting, 
are not set by default in 'core-image':

- serial-autologin-root (login 'root' with empty password  on the serial console)
- debug-tweaks that enable:

	 - empty-root-password
	 - allow-empty-password
	 - allow-root-login
	 - post-install-logging

I added the both features to IMAGE_FEATURES.

<br>

Reasoning to derive from 'image-core'. Normally, it's possible to remove packages
added by PetaLinux and Avnet layers with:
 
`IMAGE_INSTALL:remove:zynqmp = [list of packages to remove]`

Deriving from 'image-core' gives a "bare" image where we can add packages into
when needed, instead of removing packages that we don't need.

<br>

Now, how to make the layer work.

<br>

#### 3.2.1 Step 1. Adding the layer


Copy the layer directory 'meta-u96v2-experiment' to a suitable location,
I keep it in 'u96v2\_sbc\_base\_2023\_2/project-spec'.

In build shell, go to your working directory and run the command:

`$ petalinux-config -p u96v2_sbc_base_2023_2 --get-hw-description=u96v2_sbc_base_2023_2/hardware/u96v2_sbc_base_2023_2`

to get ncurses-based menu, then choose

**Yocto Settings** ---> **User Layers**,

then, in the empty line named "user layer 1" type:

`${PROOT}/[path to the new layer directory]`

For my case, it's:

`${PROOT}/project-spec/meta-u96v2-experiment`


Done. Save. Exit.


#### 3.2.2 Step 2. Users


You can modify user(s) the following way. Run the command: 

`$ petalinux-config -p u96v2_sbc_base_2023_2 -c rootfs`


When you have got the ncurses-based menu, select "PetaLinux RootFS Settings".
There, you can find lines to modify users, groups and sudoers.

~~~
Side note. Additionally, I chose `Sysvinit` in "Image Features" -> "Init-manager".
~~~

Done. Save. Exit.

<br>

### 3.3 Reducing kernel

You can run configuration utility to configure Linux kernel:


`$ petalinux-config -p u96v2_sbc_base_2023_2 -c kernel`

The well-known ncurses-based menu will pop-up.


<br>

Alternatively, you can use the build utility:

`$ petalinux-build -p u96v2_sbc_base_2023_2 -c linux-xlnx -x menuconfig`

<a href="#toc">TOC</a>
<a href="#ch3.2">Up this chapter</a>


<br id="ch4">

## 4. Rebuilding the image

<br>

If we maintain two types of images with, at least, different boot methods and potentially
other parameters somewhat different, then it's reasonable
to have separate directories to deploy raw built artifacts into.

The script 'deploy\_dir\.sh' allows to tweak config parameters faster than doing it
through the ncurses-based menu offered by 'petalinux-config' with parameter '--get-hw-description='.
The script assigns a chosen directory inside the 'path\_to\_the\_project/images/linux' path as a Deploy Directory.

For example, it can be 'path\_to\_the\_project/images/linux/ext4' for EXT4 boot method:

`$ ./deploy_dir.sh u96v2_sbc_base_2023_2 ext4`

If the 2nd parameter is skipped, the Deploy Directory falls back to the default
'path\_to\_the\_project/images/linux.

<br>

When everything is set, run the following command to build an image:

`$ petalinux-build -p u96v2_sbc_base_2023_2 -c u96v2exp-image-core`

<br>

After the image has been built, we should generate boot file BOOT.BIN
using 'petalinux-package' utility.

All parameters for the utility are set in the script 'update\.bootbin\.sh'.
'petalinux-package' doesn't use Deploy Directory variable defined in the project,
so we have to provide a path to the components 'petalinux-package' uses (fsbl, atf, u-boot, etc)
and where to place BOOT.BIN into.

Like for Deploy Directory, 'update\.bootbin\.sh' takes the second parameter to construct
a path to the components inside directory 'path\_to\_the\_project/images/linux'.

For example, if your Deploy Directory was 'path\_to\_the\_project/images/linux/ext4', you will
run:

`$ ./update.bootbin.sh u96v2_sbc_base_2023_2 ext4`

If the 2nd parameter is skipped, 'path\_to\_the\_project/images/linux' will be used.

All done.


### 4.1 Populating SD card


Now you need to place:

- BOOT\.BIN
- u-boot\.scr
- image\.ub

into the first partition of boot SD card.

If you built 'INITRD' image, compressed ramdisk is already in 'image\.ub'.

If you built 'EXT4' image, you need to unpack 'rootfs\.tar\.gz' into the
second partition:

`$ tar xvf rootfs.tar.gz -C [path to a mount point of the 2nd partition]`

<br>

~~~
Side note. Unpacking 'rootfs.tar.gz' and placing files into a mounted partition keeps
the whole partition available for using.

'rootfs.ext4' contains a raw image of a preset-sized partition.
Copying of a raw image into a device presenting a physical partition
(with utilities like 'dd' or 'bmaptool') makes available only the space
limited by the raw image.
~~~

~~~
Hint. If you assigned a custom Deploy Directory earlier and then later forgot which one
you assigned, you can check the variable PLNX_DEPLOY_DIR in 
'u96v2_sbc_base_2023_2/project-spec/config/plnxtool.conf'
~~~

<a href="#toc">TOC</a>
<a href="#ch4">Up this chapter</a>

<br id="outro">

## List of Xilinx User Guides
<br>

- (UG1137) Zynq UltraScale+ MPSoC. Software Developer Guide
- (UG1144) PetaLinux Tools. Documentation Reference Guide
- (UG1085) Zynq UltraScale+ Device. Technical Reference Manual
- (UG1283) Bootgen User Guide

Available at https://docs.amd.com/


<a href="#toc">TOC</a>
