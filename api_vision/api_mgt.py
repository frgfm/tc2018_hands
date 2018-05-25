#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

import numpy as np


def get_msvision_classif(img, api_credentials):

    """
    Retrieve the classification result for the MS Vision API

    Args:
        img (np.ndarray): image (or cropped image) to classify
        api_credentials (dict): all credentials required to access the API 

    Returns:
        pred_conf (np.array): predicted confidence for each class (index predefined)
    """

    try:
        #####################
        # Your code here 
        #####################
        #pred_conf =

    except Exception:
        raise ValueError('Call to MS Vision API failed.')

    pred_conf = np.asarray(pred_conf)

    return pred_conf
