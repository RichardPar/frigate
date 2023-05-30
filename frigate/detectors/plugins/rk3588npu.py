#from rknnlite.api import RKNNLite
import logging
import numpy as np

from frigate.detectors.detection_api import DetectionApi
from frigate.detectors.detector_config import BaseDetectorConfig
from typing_extensions import Literal

logger_ = logging.getLogger(__name__)

DETECTOR_KEY = "rk3588npu"


class Rk3588npuDetectorConfig(BaseDetectorConfig):
    type: Literal[DETECTOR_KEY]



class Rk3588npu(DetectionApi):
    type_key = DETECTOR_KEY

    def __init__(self, detector_config: Rk3588npuDetectorConfig):
        logger_.info('Loading RK3588 NPU - Using %s',detector_config.model.path)
        #rknn_lite = RKNNLite()
        #ret = rknn_lite.load_rknn(detector_config.model.path)


    def detect_raw(self, tensor_input):
        #self.interpreter.set_tensor(self.tensor_input_details[0]["index"], tensor_input)
        #self.interpreter.invoke()

        detections = np.zeros((20, 6), np.float32)

        return detections
