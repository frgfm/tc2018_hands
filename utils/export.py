#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

import numpy as np
import pandas as pd
import os


def export_map_data(device_names, gps, confs, timestamps):

    """
    Provide the user with visualization for false positives
    Args:
        img (ndarray): input image
        max_side_pxl (int): number of pixels on the longest side of the output image
    Returns:
        img (ndarray): image with drawn rectangles
    """

    data_dict = {'lat': gps[:, 0], 'lng': gps[:, 1], 'name': device_names, 'proba': confs, 'timestamp': timestamps}

    df = pd.DataFrame.from_dict(data_dict)

    save_path = os.path.join('static', 'geo_output', 'map_data.csv')
    df.to_csv(save_path, sep=';', index=False)