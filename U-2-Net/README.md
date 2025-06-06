**LINUX**

The container runs on linux and uses the software defined in the dockerfile. However, I developed the container on the windows machine listed below. I think most of the details below are irrelevent for linux other than perhaps Version + GeForce drivers, I'm not sure. 

To build the container cd into the directory with the docker file and run `docker build --no-cache -t openclone-u-2-net:1.0 .` You will need Docker Desktop, WSL, WSL enabled in Docker Desktop, etc.

To run the container do: 

```
@echo off

@echo off

rem ####################################################################
rem ##### RUN EXISITING CONTAINER IF IT EXISTS #########################
rem ####################################################################

docker container inspect u-2-net >nul 2>&1
if %ERRORLEVEL% == 0 (
    cmd -d /K "docker start -a u-2-net"
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

set cmd=%cmd% -p 5002:5002

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

set cmd=%cmd% --gpus all

rem ####################################################################
rem ###### CONTAINER NAME ##############################################
rem ####################################################################

set cmd=%cmd% --name u-2-net u-2-net:1.0

rem Finally execute the command
start cmd /k "%cmd%"


```

**WINDOWS**

Instructions were made on a Windows 11 64-bit with a Nvidia 4070 GPU.

1. Install VS Code Theme [Candy](https://vscodethemes.com/e/meganrogge.candy-theme/candy?language=javascript)
2. [Install Python 3.8.8](https://www.python.org/downloads/release/python-388/). *Container uses 3.10.12 so you could use that too*
3. [Install CUDA Toolkit 11.8](https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local) *Container uses 11.2.2 so you could use that too*
4. `git clone https://github.com/smchughinfo/U-2-Net`
5. `cd U-2-Net`
6. `code .`
7. ctrl+shift+p > Python: Create Environment > Venv > Python 3.8.8rc 64-bit (choose U-2-Net/requirements.txt or do step 9)
8. if environment not activated `.venv/scripts/activate`
9. `pip install -r U-2-Net/requirements.txt`

Some notes about versions:

* The U-2-Net repository makes mention of Python 3.6 but it's not clear if that is a recommendaition. I'm using Python 3.8.8 on windows for consistency with [SadTalker](https://github.com/smchughinfo/SadTalker). 
* You need to make sure your GeForce drivers support the version of CUDA you're using (at time of writing I was on 556.12).

Source:

* [U-2-Net](https://github.com/xuebinqin/U-2-Net)

