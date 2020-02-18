import io
import os
import re
import redis
from .converters import ImageConverters

import falcon

class HelperMethods(object):
    _IMAGE_NAME_PATTERN = re.compile('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[a-z]{2,4}$')

    def __init__(self, pool, storage_path, mimetypes):
        self._storage_path = storage_path
        self._r = redis.Redis(connection_pool=pool)
        self._mimetypes = mimetypes
        self._image_converter=ImageConverters()


    def get_content_type(self, file_name):
        try:
            content_type = self._mimetypes[re.sub("((.*)\.)", "", file_name)]
        except KeyError:
            raise falcon.HTTPNotAcceptable(
                "Please contact the provider for list of acceptable file types",
                "File Type"
            )
        return content_type


    # Find record for this file
    def find_file_in_db(self, name):
        return self._r.get(name).decode("utf-8")


    # Save to the storage_path location
    def get_file(self, file_name):
        # Always validate untrusted input!
        if not self._IMAGE_NAME_PATTERN.match(file_name):
            raise falcon.HTTPNotAcceptable(
                "Please contact the provider for list of acceptable file names",
                "File Name"
            )

        stored_file_name = self.find_file_in_db(file_name)
        image_path = os.path.join(self._storage_path, stored_file_name)

        if file_name != stored_file_name:
            new_image_path = os.path.join(self._storage_path, file_name)

            new = re.sub("((.*)\.)", "", file_name)
            org = re.sub("((.*)\.)", "", stored_file_name)
            image_path = self._image_converter.convert_file(original_path=image_path,converted_path=new_image_path,new=new,org=org)

            # set in redis to skip conversion next time
            self._r.set(file_name, file_name)

        try:
            stream = io.open(image_path, 'rb')
        except OSError:
            raise falcon.HTTPNotFound()

        content_length = os.path.getsize(image_path)

        return stream, content_length
