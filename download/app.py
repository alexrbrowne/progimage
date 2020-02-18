import falcon
import logging
import redis

from .download import DownloadResource
from .helper_methods import HelperMethods
from .healthz import HealthzResource



# *********************************************************
# *********************************************************
# ******* Download API only /download GET mapped **********
# *********************************************************
# *********************************************************

# connection pool to redis
pool = redis.ConnectionPool(host='redis', port=6379, db=0)

# accept not standard minetype for jpg
mimetypes = {
    'jpg': 'image/jpg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'svg': 'image/svg+xml'
}

helper_methods=HelperMethods(pool=pool, storage_path='/images', mimetypes=mimetypes)

images = DownloadResource(helper_methods=helper_methods)
logging.info('Local storage path /images being consumed')

# Start Falcon
app = application = falcon.API()

app.add_route('/images/{file_name}', images)
logging.info('listening on GET /images/{file_name}')

app.add_route('/healthz', HealthzResource())
logging.info('listening on GET /healthz')
