#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

from azure.cognitiveservices.vision.customvision.prediction import prediction_endpoint


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