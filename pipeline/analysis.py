#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

from api_vision.api_mgt import get_msvision_objdetection
from pipeline.nms import non_max_suppression_fast


def detect_objects(img, api_credentials, model_setup, overlap_thresh=0.3):

    """
    Retrieve the classification result for the MS Vision API

    Args:
        img (np.ndarray): image (or cropped image) to classify
        api_credentials (dict): all credentials required to access the API 

    Returns:
        pred_conf (dict): predicted confidence for each class
    """

    pred_boxes, pred_labs, pred_conf = get_msvision_objdetection(img, api_credentials, model_setup)
    nms_idx = non_max_suppression_fast(pred_boxes, overlapThresh=overlap_thresh)

    return pred_boxes[nms_idx], pred_labs[nms_idx], pred_conf[nms_idx]


def ajdust_colors(pred_labs, pred_conf):
    return 0