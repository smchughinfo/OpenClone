from glob import glob
import shutil
import torch
from time import  strftime
import os, sys, time
from argparse import ArgumentParser

from src.utils.preprocess import CropAndExtract
from src.test_audio2coeff import Audio2Coeff  
from src.facerender.animate import AnimateFromCoeff
from src.generate_batch import get_data
from src.generate_facerender_batch import get_facerender_data
from src.utils.init_path import init_path

import GlobalVariables
import pickle

from audio_remover import AudioRemover

def generate_deepfake(image_path, audio_path, m3u8_path = None, mp4_path = None, remove_audio_fom_mp4 = False, cpu = 0, tsSegmentLength = 5):
    # Set the current working directory to the directory of the current file
    current_file_directory = os.path.dirname(os.path.abspath(__file__))
    os.chdir(current_file_directory)

    # set arguments
    custom_args = {
        "source_image": image_path,
        "driven_audio": audio_path,
        "cpu": "cpu" if cpu == 1 else None
    }
    args = get_args(custom_args)

    # do the deepfake
    do_inference(args, m3u8_path=m3u8_path, mp4_path=mp4_path, remove_audio_from_mp4=remove_audio_fom_mp4, tsSegmentLength=tsSegmentLength)

def save_animation_cache_parameters(args, save_dir, save_path):
        pic_path = args.source_image
        audio_path = args.driven_audio
        #######################################os.makedirs(save_dir, exist_ok=True)
        pose_style = args.pose_style
        device = args.device
        batch_size = args.batch_size
        input_yaw_list = args.input_yaw
        input_pitch_list = args.input_pitch
        input_roll_list = args.input_roll
        ref_eyeblink = args.ref_eyeblink
        ref_pose = args.ref_pose

        GlobalVariables.applicationLog.log(f"Generating animation parameters cache for {pic_path}.")

        #current_root_path = os.path.split(sys.argv[0])[0]
        current_root_path = os.path.dirname(os.path.abspath(__file__))

        sadtalker_paths = init_path(args.checkpoint_dir, os.path.join(current_root_path, 'src/config'), args.size, args.old_version, args.preprocess)

        #init model
        preprocess_model = CropAndExtract(sadtalker_paths, device) # this one needs it

        audio_to_coeff = Audio2Coeff(sadtalker_paths,  device) # this one needs it
        
        animate_from_coeff = AnimateFromCoeff(sadtalker_paths, device) # this one needs it

        #crop image and extract 3dmm from image
        first_frame_dir = os.path.join(save_dir, 'first_frame_dir')
        os.makedirs(first_frame_dir, exist_ok=True)
        print('3DMM Extraction for source image')
        first_coeff_path, crop_pic_path, crop_info =  preprocess_model.generate(pic_path, first_frame_dir, args.preprocess,\
                                                                                source_image_flag=True, pic_size=args.size)
        if first_coeff_path is None:
            print("Can't get the coeffs of the input")
            return

        if ref_eyeblink is not None:
            ref_eyeblink_videoname = os.path.splitext(os.path.split(ref_eyeblink)[-1])[0]
            ref_eyeblink_frame_dir = os.path.join(save_dir, ref_eyeblink_videoname)
            os.makedirs(ref_eyeblink_frame_dir, exist_ok=True)
            print('3DMM Extraction for the reference video providing eye blinking')
            ref_eyeblink_coeff_path, _, _ =  preprocess_model.generate(ref_eyeblink, ref_eyeblink_frame_dir, args.preprocess, source_image_flag=False)
        else:
            ref_eyeblink_coeff_path=None

        if ref_pose is not None:
            if ref_pose == ref_eyeblink: 
                ref_pose_coeff_path = ref_eyeblink_coeff_path
            else:
                ref_pose_videoname = os.path.splitext(os.path.split(ref_pose)[-1])[0]
                ref_pose_frame_dir = os.path.join(save_dir, ref_pose_videoname)
                os.makedirs(ref_pose_frame_dir, exist_ok=True)
                print('3DMM Extraction for the reference video providing pose')
                ref_pose_coeff_path, _, _ =  preprocess_model.generate(ref_pose, ref_pose_frame_dir, args.preprocess, source_image_flag=False)
        else:
            ref_pose_coeff_path=None
        
        animationParametersCache = {
            "animate_from_coeff": animate_from_coeff,
            "save_dir": save_dir,
            "pic_path": pic_path,
            "crop_info": crop_info,
            "first_coeff_path": first_coeff_path,
            "audio_path": audio_path,
            "device": device,
            "ref_eyeblink_coeff_path": ref_eyeblink_coeff_path,
            "audio_to_coeff": audio_to_coeff,
            "pose_style": pose_style,
            "ref_pose_coeff_path": ref_pose_coeff_path,
            "crop_pic_path": crop_pic_path,
            "first_coeff_path": first_coeff_path,
            "batch_size": batch_size,
            "input_yaw_list": input_yaw_list,
            "input_pitch_list": input_pitch_list,
            "input_roll_list": input_roll_list
        }    

        with open(save_path, "wb") as file:
            pickle.dump(animationParametersCache, file)

# if you need a clean run delete the animationParametersCache file, otherwise it will use the cached data and the only half the data that gets used for processing is the cached data so it's behavior is undefined unless you look at it. ...the audio file to play, obviously, does not get cached.
def do_inference(args, m3u8_path=None, mp4_path=None, remove_audio_from_mp4=False, tsSegmentLength = 5):
    source_image_dir = os.path.dirname(args.source_image)

    if mp4_path is not None:
        mp4_path = os.path.join(GlobalVariables.openclone_fs_path, mp4_path)


    #torch.backends.cudnn.enabled = False
    animationCacheId, _ = os.path.splitext(os.path.basename(args.source_image))
    animationParametersCacheDirectory = os.path.join(source_image_dir, "DeepFake", "SadTalker_Cache", args.device, str(animationCacheId))
    animationParametersCacheFilePath = os.path.join(animationParametersCacheDirectory, "AnimationParametersCache.pickle")

    GlobalVariables.applicationLog.log(f"Using Cache Directory {animationParametersCacheDirectory}") # TODO: these logs might get a bit chatty

    os.makedirs(animationParametersCacheDirectory, exist_ok=True)
    if not os.path.exists(animationParametersCacheFilePath):
        save_animation_cache_parameters(args, animationParametersCacheDirectory, animationParametersCacheFilePath)
    
    with open(animationParametersCacheFilePath, "rb") as file:
        animationParameterCache  = pickle.load(file)
        
        #audio2ceoff
        batch = get_data(animationParameterCache["first_coeff_path"], animationParameterCache["audio_path"], animationParameterCache["device"], animationParameterCache["ref_eyeblink_coeff_path"], still=args.still)
        coeff_path = animationParameterCache["audio_to_coeff"].generate(batch, animationParameterCache["save_dir"], animationParameterCache["pose_style"], animationParameterCache["ref_pose_coeff_path"])

        # 3dface render
        if args.face3dvis:
            from src.face3d.visualize import gen_composed_video
            gen_composed_video(args, animationParameterCache["device"], animationParameterCache["first_coeff_path"], coeff_path, animationParameterCache["audio_path"], os.path.join(animationParameterCache["save_dir"], '3dface.mp4'))
        
        #coeff2video
        data = get_facerender_data(coeff_path, animationParameterCache["crop_pic_path"], animationParameterCache["first_coeff_path"], animationParameterCache["audio_path"], 
                                    animationParameterCache["batch_size"], animationParameterCache["input_yaw_list"], animationParameterCache["input_pitch_list"], animationParameterCache["input_roll_list"],
                                    expression_scale=args.expression_scale, still_mode=args.still, preprocess=args.preprocess, size=args.size)

        if m3u8_path is not None:
            GlobalVariables.applicationLog.log(f"Begin DeepFake Stream For:\n{args.source_image}\n{args.driven_audio}")
            animationParameterCache["animate_from_coeff"].generate(data, animationParameterCache["save_dir"], animationParameterCache["pic_path"], animationParameterCache["crop_info"],
                        enhancer=args.enhancer, background_enhancer=args.background_enhancer, preprocess=args.preprocess, img_size=args.size, m3u8_path=m3u8_path, tsSegmentLength=tsSegmentLength)
        
        if mp4_path is not None:
            GlobalVariables.applicationLog.log(f"Begin DeepFake MP4 For:\n{args.source_image}\n{args.driven_audio}")
            result = animationParameterCache["animate_from_coeff"].generate(data, animationParameterCache["save_dir"], animationParameterCache["pic_path"], animationParameterCache["crop_info"],
                        enhancer=args.enhancer, background_enhancer=args.background_enhancer, preprocess=args.preprocess, img_size=args.size)
            GlobalVariables.applicationLog.log(f"Copy DeepFake\nWorking Dir:{result}\nmp4_path{mp4_path}")
            shutil.move(result, mp4_path)
            if remove_audio_from_mp4:
                GlobalVariables.applicationLog.log("Saving MP4 To: " + mp4_path)
                audio_remover = AudioRemover(mp4_path)
                audio_remover.remove_audio()
        
        return

        ############### all code below this line is original ###################################

        
        print('The generated video is named:', mp4_path)

        if not args.verbose:
            shutil.rmtree(animationParameterCache["save_dir"])
    
def get_args(overrides=None):
    parser = ArgumentParser()
    parser.add_argument("--driven_audio", default='./examples/driven_audio/bus_chinese.wav', help="path to driven audio")
    parser.add_argument("--source_image", default='./examples/source_image/full_body_1.png', help="path to source image")
    parser.add_argument("--ref_eyeblink", default=None, help="path to reference video providing eye blinking")
    parser.add_argument("--ref_pose", default=None, help="path to reference video providing pose")
    parser.add_argument("--checkpoint_dir", default='./checkpoints', help="path to output")
    parser.add_argument("--result_dir", default='./results', help="path to output")
    parser.add_argument("--pose_style", type=int, default=0,  help="input pose style from [0, 46)")
    parser.add_argument("--batch_size", type=int, default=2,  help="the batch size of facerender")
    parser.add_argument("--size", type=int, default=256,  help="the image size of the facerender")
    parser.add_argument("--expression_scale", type=float, default=1.,  help="the batch size of facerender")
    parser.add_argument('--input_yaw', nargs='+', type=int, default=None, help="the input yaw degree of the user ")
    parser.add_argument('--input_pitch', nargs='+', type=int, default=None, help="the input pitch degree of the user")
    parser.add_argument('--input_roll', nargs='+', type=int, default=None, help="the input roll degree of the user")
    parser.add_argument('--enhancer',  type=str, default=None, help="Face enhancer, [gfpgan, RestoreFormer]")
    parser.add_argument('--background_enhancer',  type=str, default=None, help="background enhancer, [realesrgan]")
    parser.add_argument("--cpu", dest="cpu", action="store_true") 
    parser.add_argument("--face3dvis", action="store_true", help="generate 3d face and 3d landmarks") 
    parser.add_argument("--still", action="store_true", help="can crop back to the original videos for the full body animation") 
    parser.add_argument("--preprocess", default='crop', choices=['crop', 'extcrop', 'resize', 'full', 'extfull'], help="how to preprocess the images" ) 
    parser.add_argument("--verbose",action="store_true", help="saving the intermedia output or not" ) 
    parser.add_argument("--old_version",action="store_true", help="use the pth other than safetensor version" ) 

    # net structure and parameters
    parser.add_argument('--net_recon', type=str, default='resnet50', choices=['resnet18', 'resnet34', 'resnet50'], help='useless')
    parser.add_argument('--init_path', type=str, default=None, help='Useless')
    parser.add_argument('--use_last_fc',default=False, help='zero initialize the last fc')
    parser.add_argument('--bfm_folder', type=str, default='./checkpoints/BFM_Fitting/')
    parser.add_argument('--bfm_model', type=str, default='BFM_model_front.mat', help='bfm model')

    # default renderer parameters
    parser.add_argument('--focal', type=float, default=1015.)
    parser.add_argument('--center', type=float, default=112.)
    parser.add_argument('--camera_d', type=float, default=10.)
    parser.add_argument('--z_near', type=float, default=5.)
    parser.add_argument('--z_far', type=float, default=15.)

    # Parse the default arguments
    args = parser.parse_args()

    # Override arguments if provided
    if overrides:
        for key, value in overrides.items():
            setattr(args, key, value)

    has_cuda = torch.cuda.is_available()
    if has_cuda and not args.cpu:
        args.device = "cuda"
    else:
        args.device = "cpu"

    return args

if __name__ == '__main__':
    args = get_args()
    do_inference(args)

