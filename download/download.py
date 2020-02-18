
class DownloadResource(object):

    def __init__(self, helper_methods):
        self._helper_methods = helper_methods

    def on_get(self, req, resp, file_name):
        resp.content_type = self._helper_methods.get_content_type(file_name)
        resp.stream, resp.content_length = self._helper_methods.get_file(file_name)
        resp.set_header('Powered-By', 'ProgImage: https://proimage.innovology.io')
