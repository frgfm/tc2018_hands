#!/usr/bin/env python

'''
These functions were developped as part of the HANDS project for forest wildfire detection

'''

import numpy as np
import cv2


def add_boxes(img, boxes, labels=None, line_width=3, font_size=1, color=(0, 0, 255), label_out=True, label_top=True):

    """
    Provide the user with visualization for false positives
    Args:
        img (ndarray): input image
        boxes (np.matrix): 2D coordinates of boxes to draw
        labels (np.array): respective labels of the boxes
        line_width (int): line width of the box
        font_size (int): font size of the label
        color (tuple): BGR color of the labelled box
        label_out (bool): boolean specifying if the label should be outside or inside the box
        label_top (bool): boolean specifying if the label should be at the top or at the bottom of the box
    Returns:
        img (ndarray): image with drawn rectangles
    """

    if labels is not None and len(boxes) != len(labels):
        print('arguments boxes and labels don\'t have the same length')
        return img

    boxes = np.asarray(boxes)
    img_shape = img.shape
    for i, box in enumerate(boxes):

        top_left = (int(box[0] * float(img_shape[0])), int(box[1] * float(img_shape[1])))
        bot_right = (int((box[0] + box[2]) * float(img_shape[0])), int((box[1] + box[3]) * float(img_shape[1])))
        top_left, bot_right = (top_left[1], top_left[0]), (bot_right[1], bot_right[0])

        cv2.rectangle(img, top_left, bot_right, color, line_width)

        if labels is not None:
            if label_top:
                if label_out:
                    y_pos = top_left[1] - 2 * line_width
                else:
                    y_pos = top_left[1] + 8 * line_width
            else:
                if label_out:
                    y_pos = bot_right[1] + 8 * line_width
                else:
                    y_pos = bot_right[1] - 2 * line_width

            lab_pos = (top_left[0], y_pos)
            if isinstance(labels[i], list):
                for i, line in enumerate(labels[i]):
                    y = y_pos + 30 * i * font_size
                    cv2.putText(img, line, (top_left[0], y), cv2.FONT_HERSHEY_SIMPLEX, font_size, color, line_width)
            else:
                cv2.putText(img, labels[i], lab_pos, cv2.FONT_HERSHEY_SIMPLEX, font_size, color, line_width)

    return img
