#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''


import numpy as np

# Malisiewicz et al.
def non_max_suppression_fast(boxes, overlapThresh):
    # if there are no boxes, return an empty list
    if len(boxes) == 0:
        return []

    # if the bounding boxes integers, convert them to floats --
    # this is important since we'll be doing a bunch of divisions
    if boxes.dtype.kind == "i":
        boxes = boxes.astype("float")

    # initialize the list of picked indexes 
    pick = []

    # grab the coordinates of the bounding boxes
    xmin, ymin, w, h = boxes[:, 0], boxes[:, 1], boxes[:, 2], boxes[:, 3]

    # compute the area of the bounding boxes and sort the bounding
    # boxes by the bottom-right y-coordinate of the bounding box
    area = w * h
    idxs = np.argsort(ymin + h)

    # keep looping while some indexes still remain in the indexes
    # list
    while len(idxs) > 0:
        # grab the last index in the indexes list and add the
        # index value to the list of picked indexes
        last = len(idxs) - 1
        i = idxs[last]
        pick.append(i)

        # find the largest (x, y) coordinates for the start of
        # the bounding box and the smallest (x, y) coordinates
        # for the end of the bounding box
        xxmin = np.maximum(xmin[i], xmin[idxs[:last]])
        yymin = np.maximum(ymin[i], ymin[idxs[:last]])
        xxmax = np.minimum(xmin[i] + w[i], xmin[idxs[:last]] + w[idxs[:last]])
        yymax = np.minimum(ymin[i] + h[i], ymin[idxs[:last]] + h[idxs[:last]])

        # compute the width and height of the bounding box
        width = np.maximum(0, xxmax - xxmin)
        height = np.maximum(0, yymax - yymin)

        # compute the ratio of overlap
        overlap = (width * height) / area[idxs[:last]]

        # delete all indexes from the index list that have
        idxs = np.delete(idxs, np.concatenate(([last],
            np.where(overlap > overlapThresh)[0])))

    # return only the bounding boxes that were picked using the
    # integer data type
    return pick