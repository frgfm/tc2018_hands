#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

import numpy as np
import pandas as pd

(44.3, 6)

def export_map_data(device_names, labs, confs, timestamps):

    """
    Provide the user with visualization for false positives
    Args:
        img (ndarray): input image
        max_side_pxl (int): number of pixels on the longest side of the output image
    Returns:
        img (ndarray): image with drawn rectangles
    """

    lat;lng;name;proba;timestamp

    data_dict = {'lat': gps[0], 'lon': gps[1], 'name': device_names, 'proba': confs, 'timestamp': timestamps}

    df = pd.DataFrame.from_dict(data_dict)
    

    return resized_img
