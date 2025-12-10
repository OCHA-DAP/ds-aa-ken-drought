"""
Ken Drought AA Trigger Package.

This package provides drought analysis and early warning functionality for Kenya.
"""

# Import submodules to make them available at package level
from . import constants
from . import datasources
from . import utils

# Optionally expose key items at package level
# from .constants import *
# from .datasources.era5 import *
# from .utils.db_utils import *

__version__ = "0.0.1"
__author__ = "Pauline Ndirangu"
__email__ = "pauline.ndirangu@un.org"
