#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

from azure.cognitiveservices.vision.customvision.prediction import prediction_endpoint
import numpy as np


def get_msvision_classif(img, api_credentials, model_setup):

    """
    Retrieve the classification result for the MS Vision API

    Args:
        img (np.ndarray): image (or cropped image) to classify
        api_credentials (dict): all credentials required to access the API 

    Returns:
        pred_conf (dict): predicted confidence for each class
    """

    try:
        predictor = prediction_endpoint.PredictionEndpoint(api_credentials['prediction_key'])
        results = predictor.predict_image(model_setup['project_id'], img, model_setup['iter_id'])
        pred_conf = {}
        for prediction in results.predictions:
            pred_conf[prediction.tag_name] = prediction.probability

    except Exception:
        raise ValueError('Call to MS Vision API failed.')

    return pred_conf


def get_msvision_objdetection(img, api_credentials, model_setup):

    """
    Retrieve the classification result for the MS Vision API

    Args:
        img (np.ndarray): image (or cropped image) to classify
        api_credentials (dict): all credentials required to access the API 

    Returns:
        pred_conf (dict): predicted confidence for each class
    """

    try:
        predictor = prediction_endpoint.PredictionEndpoint(api_credentials['prediction_key'])
        results = predictor.predict_image(model_setup['project_id'], img, model_setup['iter_id'])
        predictions = []
        pred_boxes, pred_labs, pred_conf = [], [], []
        for prediction in results.predictions:
            pred_boxes.append([prediction.bounding_box.left, prediction.bounding_box.top, prediction.bounding_box.width, prediction.bounding_box.height])
            pred_labs.append(prediction.tag_name)
            pred_conf.append(prediction.probability)
            predictions.append({'tag': prediction.tag_name, 'conf': prediction.probability,
                                'box': [prediction.bounding_box.left, prediction.bounding_box.top, prediction.bounding_box.width, prediction.bounding_box.height]})

        pred_boxes, pred_labs, pred_conf = np.asarray(pred_boxes), np.asarray(pred_labs), np.asarray(pred_conf)
        sorted_idx = np.where(pred_conf >= 0.2)
        pred_boxes, pred_labs, pred_conf = pred_boxes[sorted_idx], pred_labs[sorted_idx], pred_conf[sorted_idx]
    except Exception:
        raise ValueError('Call to MS Vision API failed.')

    return pred_boxes, pred_labs, pred_conf
