from .image_converters.conversion import to_jpeg
from .image_converters.conversion import to_svg
from .image_converters.conversion import to_gif
from .image_converters.conversion import to_png
from .image_converters.conversion import svg_to_png
from .image_converters.conversion import svg_to_jpeg
from .image_converters.conversion import svg_to_gif
from .image_converters.conversion import no_conversion
import falcon

class ImageConverters(object):

    def __init__(self):

        self._conversions={
            "pngjpeg": to_jpeg,
            "pngjpg": to_jpeg,
            "pnggif": to_gif,
            "pngsvg": to_svg,

            "gifpng": to_png,
            "gifjpeg": to_jpeg,
            "gifjpg": to_jpeg,
            "gifsvg": to_svg,

            "svgpng": svg_to_png,
            "svggif": svg_to_gif,
            "svgjpeg": svg_to_jpeg,
            "svgjpg": svg_to_jpeg,

            "jpegpng": to_png,
            "jpeggif": to_gif,
            "jpegsvg": to_svg,
            "jpegjpg": no_conversion,
            #
            "jpgjpeg": no_conversion,
            "jpgsvg": to_svg,
            "jpgpng": to_png,
            "jpggif": to_gif
        }

    def convert_file(self, original_path, converted_path, new, org):
        try:
            f = self._conversions["{org}{new}".format(org=org, new=new)]

        except KeyError:
            raise falcon.HTTPNotAcceptable(
                "Please contact the provider for list of acceptable file names",
                "File Name"
            )

        return f(original_path=original_path, converted_path=converted_path)
