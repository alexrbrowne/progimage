import uuid
import datetime
import falcon

class UploadResource(object):

    def __init__(self, helper_methods):
        self._helper_methods = helper_methods

    def on_post(self, req, resp):
        ext = self._helper_methods.test_content_type(req.content_type)

        # set the id for the file
        uid = uuid.uuid4()

        # ext is potentially reset if it was incorrectly passed in
        name, ext = self._helper_methods.save_to_disk(uid, ext, req.stream)

        # add this to our datastore
        self._helper_methods.add_to_db(uid, name)

        dt = datetime
        ttl= (dt.datetime.now() + dt.timedelta(minutes = 30)).timestamp()

        return_urls = {}

        for e in self._helper_methods._ext_accepted:
            return_urls[e[1:len(e)]] = '/images/{uuid}{ext}'.format(ext=e, uuid=uid)

        body = {
            'image': {
                'href':'/images/{uuid}{ext}'.format(ext=ext, uuid=uid),
                'size':req.content_length,
                'ttl':ttl,
                'alternative_formats': return_urls
                }
            }

        resp.media = body
        resp.status = falcon.HTTP_201
        resp.set_header('Powered-By', 'ProgImage: https://proimage.innovology.io')
