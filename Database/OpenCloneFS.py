import shutil
import os

openclone_root_dir = os.getenv("OpenClone_Root_Dir")
openclone_fs_dir = os.getenv("OpenClone_OpenCloneFS")

def delete_dir(dir_to_delete):
    if os.path.exists(dir_to_delete): 
        shutil.rmtree(dir_to_delete)

def reset_openclone_fs(TODO_UPDATE_THIS=False):
    if(TODO_UPDATE_THIS == False): return
    delete_dir(openclone_fs_dir)
    shutil.copytree(os.path.join(openclone_root_dir, "Database/Backups/OpenCloneFS"), openclone_fs_dir)