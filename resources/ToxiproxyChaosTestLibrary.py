import os
import subprocess
import time
from robot.api.deco import keyword

class ToxiproxyChaosTestLibrary:

    @keyword("Start Toxiproxy Server")
    def start_toxiproxy_server(self):
        """
        Start the Toxiproxy server.
        """
        run_process = subprocess.Popen(
            f'toxiproxy-server > ./resources/toxiproxy.log 2>1 &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay for the server to start.
        return (status, output, error)

    @keyword("Create TCP Chaos Proxy")
    def create_tcp_chaos_proxy(self):
        """
        Create a TCP Chaos Proxy for the Vegeta load tests.
        """
        run_process = subprocess.Popen(
            f'toxiproxy-cli create exploratory-testing-proxy -l 127.0.0.1:8080 -u 0.0.0.0:4010 >> ./resources/toxiproxy.log 2>1 &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay for the creation of the proxy.
        return (status, output, error)

## --> More documentation about the Toxiproxy toxic types can be found here... https://github.com/Shopify/toxiproxy?tab=readme-ov-file#toxics

    @keyword("Add Limited Bandwidth Toxic")
    def add_limited_bandwidth_toxic(self):
        """
        Add the Limited Bandwidth Toxic to the Vegeta load tests. It will limit a connection to a maximum number of kilobytes per second.
        """
        run_process = subprocess.Popen(
            f'toxiproxy-cli toxic add -t bandwidth -a rate=100 exploratory-testing-proxy >> ./resources/toxiproxy.log 2>1 &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay to add a new toxic to the proxy.
        return (status, output, error)

    @keyword("Add Slow Close Toxic")
    def add_slow_close_toxic(self):
        """
        Add the Slow Close Toxic to the Vegeta load tests. It will delay the TCP socket from closing until delay has elapsed.
        """
        run_process = subprocess.Popen(
            f'toxiproxy-cli toxic add -t slow_close -a delay=1000 exploratory-testing-proxy >> ./resources/toxiproxy.log 2>1 &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay to add a new toxic to the proxy.
        return (status, output, error)

    @keyword("Add Latency Toxic")
    def add_latency_toxic(self):
        """
        Add the Latency Toxic to the Vegeta load tests. It will add a delay to all data going through the proxy.
        """
        run_process = subprocess.Popen(
            f'toxiproxy-cli toxic add -t latency -a latency=10000 exploratory-testing-proxy >> ./resources/toxiproxy.log 2>1 &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay to add a new toxic to the proxy.
        return (status, output, error)

    @keyword("Remove All Three Toxics")
    def remove_all_three_toxics(self):
        """
        Remove all three toxics from the exploratory-testing-proxy.
        """
        run_process = subprocess.Popen(
            f'toxiproxy-cli toxic remove -n latency exploratory-testing-proxy; toxiproxy-cli toxic remove -n slow_close exploratory-testing-proxy; toxiproxy-cli toxic remove -n bandwidth exploratory-testing-proxy >> ./resources/toxiproxy.log 2>1 &',
            stdout = subprocess.PIPE,
            text = True,
            shell = True
        )
        (output, error) = run_process.communicate()
        status = run_process.wait()
        time.sleep(5)  # Allow a short delay for the server to start
        return (status, output, error)
