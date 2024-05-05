from robot.libraries.BuiltIn import BuiltIn

class DurationTrackingListener(object):
    ROBOT_LISTENER_API_VERSION = 3

# The following will measure the duration of each test. This listener will fail a test if it runs beyond the maximum allowed timeout value (max_seconds).
# Set to 1800 seconds or 30 minutes.

    def __init__(self, max_seconds=1800, trigger_keyword="Trigger Only After Timeout"):
        self.max_milliseconds = float(max_seconds) * 1000
        self.builtin = BuiltIn()
        self.trigger_keyword = trigger_keyword 

    def end_test(self, data, test):
        if test.status == 'PASS' and test.elapsedtime > self.max_milliseconds:
            test.status = 'FAIL'
            test.message = 'FAIL --> FATAL ERROR -- Individual test execution took too long.'
            self.builtin.run_keyword(self.trigger_keyword)