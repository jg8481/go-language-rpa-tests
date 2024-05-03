class TimeTrackingListener(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self

# The following will measure and display how long a test takes. The measurement will be printed to the console.

    def _end_test(self, name, attrs):
        print ('%s => status: %s, elapsed time: %s ms' % (name, attrs['status'], attrs['elapsedtime']))
