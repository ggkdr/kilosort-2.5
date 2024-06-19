### Kilosort 2.5, adapted ###
To install, do the following:

1. Clone these github repositories:
- ggkdr/kilosort-2.5
- cortex-lab/spikes
- kwikteam/npy-matlab

2. Install the tdt python sdk:
https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-python/getting-started/

3. Install CUDA:
- run this command: ubuntu-drivers devices; sudo ubuntu-drivers autoinstall
- if getting errors: check CUDA is not already installed, or try removing and reinstalling
- refer to these also:
  - https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-ubuntu-22-04
  - https://askubuntu.com/questions/1140183/install-gcc-9-on-ubuntu-18-04 (may need to use gcc <=9, if error related to gcc version)
      - sudo apt install gcc-9 g++-9
      - sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9
* NOTE: when installing CUDA, make sure to use DEB, not RUNFILE, because runfile does not update package management and will mess up [https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local)https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local

4. Add all folders to MATLAB path
5. In MATLAB, run this command: mexGPUall
6. If necessary, set up swap memory on machine (certain steps in Kilosort briefly use large amounts of RAM)
