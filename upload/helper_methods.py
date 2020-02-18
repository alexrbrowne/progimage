import io
import os
import re
import imghdr as image_tester
import redis
import defusedxml.cElementTree as element_tree

import falcon

class HelperMethods(object):
    _CHUNK_SIZE_BYTES = 4096

    def __init__(self, pool, storage_path, mimetypes):
        self._ext_accepted=list(mimetypes.values())
        self._storage_path = storage_path
        self._r = redis.Redis(connection_pool=pool)
        self._mimetypes = mimetypes

    def test_content_type(self, content_type):
        try:
            ext = self._mimetypes[content_type]
        except KeyError:
            raise falcon.HTTPInvalidHeader(
                "Please contact the provider for list of acceptable headers",
                "Content-Type"
            )

        return ext

    #  determine if the file really is what it is pretending to be
    def test_image(self, image_path, ext, ext_accepted):
        test=image_tester.what(image_path)

        # strip the dot from the exts
        ext_accepted = [x[1:len(x)] for x in self._ext_accepted]
        ext = ext[1:len(ext)]

        if test is None:
            # maybe it is an SVG
            if self.is_svg(image_path):
                test = "svg"

        # sanity check the ext against the test
        if ((test != ext) and not (test == 'jpeg' and ext == 'jpg')):
            # whooo, hey cowboy, you just sent us the wrong content-type.... lets fix that for you
            ext = test
            # need to move file...
            new_image_path = re.sub("[.][a-z]{3,8}", ".{ext}".format(ext=ext), image_path)

            os.rename(image_path, new_image_path)
            image_path = new_image_path

            if ext not in ext_accepted:
                # clean up
                os.remove(image_path)

                # fail out - HTTP406
                raise falcon.HTTPNotAcceptable(
                    "Only the following are acceptable: jpeg, jpg, png, gif & svg"
                )

        return ".{ext}".format(ext=ext)

    # detect an svg as best as we can
    @staticmethod
    def is_svg(filename):
        tag = None
        with open(filename, "r") as f:
            try:
                for _, el in element_tree.iterparse(f, ('start',)):
                    tag = el.tag
                    break
            except element_tree.ParseError:
                pass
        return tag == '{http://www.w3.org/2000/svg}svg'

    # Add records for later searching of this file
    def add_to_db(self, uuid, name):
        for ext in self._ext_accepted:
            self._r.set('{uuid}{ext}'.format(ext=ext,uuid=uuid), name)

    # Save to the storage_path location
    def save_to_disk(self, uuid, ext, io_stream):
        name = '{uuid}{ext}'.format(uuid=uuid, ext=ext)

        image_path = os.path.join(self._storage_path, name)

        with io.open(image_path, 'wb') as image_file:
            while True:
                chunk = io_stream.read(self._CHUNK_SIZE_BYTES)
                if not chunk:
                    break

                image_file.write(chunk)

        # lets test that content is correct just to be sure
        ext = self.test_image(image_path, ext, self._ext_accepted)

        return name, ext
