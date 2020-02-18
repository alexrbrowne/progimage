class HealthzResource:
    @classmethod
    def on_get(self, req, resp):
        resp.media = {'status': 'OK', 'health': 1.0}
