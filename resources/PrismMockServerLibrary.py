import os
import time
import subprocess
from robot.api.deco import keyword

class PrismMockServerLibrary:

    @keyword("Download And Install Prism")
    def download_and_install_prism(self):
        """
        Downloads and installs the Prism tool.
        """
        run_process = subprocess.Popen(
            f'curl -L https://raw.githack.com/stoplightio/prism/master/install | sh',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        return (status, output, error)

    @keyword("Start Prism Mock Server")
    def start_prism_mock_server(self):
        """
        Start the Prism tool and create a mock API server.
        """
        run_process = subprocess.Popen(
            f'nohup prism mock -h 0.0.0.0 /tests/petstore.oas3.yaml > /tests/resources/api-application.log &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay for the server to start.
        return (status, output, error)


