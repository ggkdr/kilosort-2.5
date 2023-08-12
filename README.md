### Kilosort 2.5, adapted ###
To install, do the following:

1. Clone these github repositories:
- ggkdr/kilosort-2.5
- cortex-lab/spikes
- kwikteam/npy-matlab

2. Install the tdt python sdk:
https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-python/getting-started/

3. Install CUDA and gcc-9: (will get error with gcc >9)
https://developer.nvidia.com/cuda-downloads?target_os=Linux
https://askubuntu.com/questions/1140183/install-gcc-9-on-ubuntu-18-04

* sudo apt install gcc-9 g++-9
* sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9
