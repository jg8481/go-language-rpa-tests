import os
import subprocess
from robot.api.deco import keyword

class VegetaLoadTestLibrary:
    def __init__(self):
        self.ramps = [50, 100, 150, 200, 250, 300]  # Request rate ramps.
        self.durations = ['30s', '60s', '90s', '120s', '150s', '180s']  # Durations for each ramp iteration.
        self.output_prefix = "results"

    @keyword("Run Vegeta Ramp Up Load Test")
    def run_vegeta_ramp_up_load_test(self, url, method):
        """
        Runs the vegeta-load-test-runner.go automation with a ramp up mechanism.
        """
        for i in range(len(self.ramps)):
            output_file = f"{self.output_prefix}-{i}.bin"
            cmd = [
                'go', 'run', 'vegeta-load-test-runner.go',
                '-rate', str(self.ramps[i]),
                '-duration', self.durations[i],
                '-url', url,
                '-method', method,
                '-output', output_file
            ]
            print(f"Running Vegeta load test: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error running Vegeta load test : {result.stderr}")
            else:
                print(f"Vegeta load test executed successfully: {result.stdout}")

    @keyword("Run Specific Parameters Vegeta Load Test")
    def run_specific_vegeta_load_test(self, rate, duration, url, method, body, output_file):
        """
        Runs the vegeta-load-test-runner.go automation with specific given parameters for more customization.
        """
        cmd = [
            'go', 'run', 'vegeta-load-test-runner.go',
            '-rate', rate,
            '-duration', duration,
            '-url', url,
            '-method', method,
            '-body', body,
            '-output', output_file
        ]
        print(f"Running Vegeta load test: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error running Vegeta load test : {result.stderr}")
        else:
            print(f"Vegeta load test executed successfully: {result.stdout}")