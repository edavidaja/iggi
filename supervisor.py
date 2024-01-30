import subprocess

subprocess.run("mpirun -np 8 python main.py", shell=True, capture_output=True)