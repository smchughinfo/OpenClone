**LINUX**

The container runs on linux and uses the software defined in the dockerfile. However, I developed the container on the windows machine listed below. I think most of the details below are irrelevent for linux other than perhaps Cuda 11.8 + GeForce drivers, I'm not sure.

To build the container cd into the directory with the docker file and run `docker build --no-cache -t openclone-sadtalker:1.0 .` You will need Docker Desktop, WSL, WSL enabled in Docker Desktop, etc.

To run the container do:

```
@echo off

rem ####################################################################
rem ##### RUN EXISITING CONTAINER IF IT EXISTS #########################
rem ####################################################################

docker container inspect sadtalker >nul 2>&1
if %ERRORLEVEL% == 0 (
    docker start -a sadtalker
    pause
    goto :EOF
)

rem ####################################################################
rem ###### RUN CONTAINER FOR THE FIRST TIME ############################
rem ####################################################################

rem Initialize the command string
set cmd=docker run

rem ####################################################################
rem ###### NETWORK #####################################################
rem ####################################################################

set cmd=%cmd% -p 5001:5001

rem ####################################################################
rem ###### FILE SYSTEM #################################################
rem ####################################################################

set cmd=%cmd% -v "%OpenClone_OpenCloneFS%":/OpenCloneFS
set cmd=%cmd% -e OpenClone_OpenCloneFS=/OpenCloneFS

rem ####################################################################
rem ###### LOG DATABASE ################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_DB_Host=%OpenClone_DB_Host%
set cmd=%cmd% -e OpenClone_DB_Port=%OpenClone_DB_Port%
set cmd=%cmd% -e OpenClone_LogDB_Name=%OpenClone_LogDB_Name%
set cmd=%cmd% -e OpenClone_LogDB_User=%OpenClone_LogDB_User%
set cmd=%cmd% -e OpenClone_LogDB_Password=%OpenClone_LogDB_Password%

rem ####################################################################
rem ###### GPU SETTINGS ################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_CUDA_VISIBLE_DEVICES=%OpenClone_CUDA_VISIBLE_DEVICES%
set cmd=%cmd% --gpus all

rem ####################################################################
rem ###### CONTAINER NAME ##############################################
rem ####################################################################

set cmd=%cmd% --name sadtalker sadtalker:1.0

rem Finally execute the command
start cmd /k "%cmd%"

```

**WINDOWS**

Instructions were made on a Windows 11 64-bit with a Nvidia 4070 GPU.

1. Install VS Code Theme [Shades of Purple](https://vscodethemes.com/e/ahmadawais.shades-of-purple/shades-of-purple)
2. [Install Python 3.8.8](https://www.python.org/downloads/release/python-388/)
3. [Install CUDA Toolkit 11.8](https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local)
4. `git clone https://github.com/smchughinfo/SadTalker.git`
5. `cd SadTalker`
6. `code .`
7. ctrl+shift+p > Python: Create Environment > Venv > Python 3.8.8rc 64-bit (don't install any requirements)
8. if environment not activated `.venv/scripts/activate`
~9. pip install torch==2.1.0+cu118 torchvision==0.16 torchaudio --index-url https://download.pytorch.org/whl/cu118~
9. pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118
10. `pip install -r SadTalker/requirements.txt`

I have had a lot of problems getting pytorch to install right. It doesn't seem to work if I just put these in the requirements.txt:

* torch==2.1.0+cu118
* torchaudio==2.1.0+cu118
* torchvision==0.16.0+cu118

Some notes about versions:

* torchvision==0.17.0 had functions removed from it that are required for SadTalker to work (e.g. 0.16 is the latest you can use). this in turn limits the latest version of torch you can use.
* The SadTalker repository recommends using python 3.8.
* You need to make sure your GeForce drivers support CUDA 11.8 (at time of writing I was on 556.12).

Source:
* [SadTalker](https://github.com/OpenTalker/SadTalker)

Misc Notes:

* If it doesn't recognize file paths that you pass to it as existing then delete the SadTalker_Cache directory.