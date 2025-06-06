import os
from skimage import io
import torch
from torch.autograd import Variable
from torch.utils.data import DataLoader
from torchvision import transforms
import numpy as np
from PIL import Image
import GlobalVariables

from data_loader import RescaleT, ToTensorLab, SalObjDataset
from model import U2NET

# Normalize the predicted SOD probability map
def normPRED(d):
    ma = torch.max(d)
    mi = torch.min(d)
    dn = (d - mi) / (ma - mi)
    return dn

def save_output(image_path, pred, output_path):
    predict = pred.squeeze()
    predict_np = predict.cpu().data.numpy()
    im = Image.fromarray(predict_np * 255).convert('RGB')
    img_name = os.path.basename(image_path)
    image = io.imread(image_path)
    imo = im.resize((image.shape[1], image.shape[0]), resample=Image.BILINEAR)

    pb_np = np.array(imo)

    aaa = img_name.split(".")
    imidx = ".".join(aaa[:-1])
    imo.save(output_path)

def process_image(image_path, output_path):
    model_path = os.path.join(os.path.dirname(__file__), 'saved_models', 'u2net_human_seg', 'u2net_human_seg.pth')

    # Load the U2NET model
    net = U2NET(3, 1)
    if torch.cuda.is_available():
        net.load_state_dict(torch.load(model_path))
        net.cuda()
    else:
        net.load_state_dict(torch.load(model_path, map_location='cpu'))
    net.eval()

    # Prepare the dataset and dataloader
    img_name_list = [image_path]
    test_salobj_dataset = SalObjDataset(
        img_name_list=img_name_list,
        lbl_name_list=[],
        transform=transforms.Compose([RescaleT(320), ToTensorLab(flag=0)])
    )
    test_salobj_dataloader = DataLoader(test_salobj_dataset, batch_size=1, shuffle=False, num_workers=1)

    # Perform inference on the image
    for i_test, data_test in enumerate(test_salobj_dataloader):
        inputs_test = data_test['image']
        inputs_test = inputs_test.type(torch.FloatTensor)

        if torch.cuda.is_available():
            inputs_test = Variable(inputs_test.cuda())
        else:
            inputs_test = Variable(inputs_test)

        d1, d2, d3, d4, d5, d6, d7 = net(inputs_test)

        # Normalize and save the result
        pred = d1[:, 0, :, :]
        pred = normPRED(pred)

        save_output(image_path, pred, output_path)

        del d1, d2, d3, d4, d5, d6, d7
