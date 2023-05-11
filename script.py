import os
import sys

# argv[1] home dir
# argv[2] timeout
# home directory of PAYNT
home_dir = sys.argv[1]

if len(sys.argv) < 3:
	timeout = 60
else:
	timeout = sys.argv[2]

model_directory = home_dir + "/models/cassandra/pomdp"
files = os.listdir(model_directory)
models = []

for file in files:
    if ".pomdp" in file: 
        models.append(file)

# paynt call parts
timeout_call = "timeout " + timeout + "s "
paynt_call = "python3 paynt.py --project models/cassandra/pomdp/ --filetype=cassandra --sketch "
summary = " | tail -n 8 | head -n 6"

# calling all models in directory 
for model in models:
    
    call = timeout_call + paynt_call + model + summary
    output = os.popen(call).read().split("\n")
    
    if (len(output) < 6):
        #print("### model: " + model + " ERROR ###")
        #print("time:    ERROR ###")
        #print("optimal: ERROR ###\n")
        continue

    # extracting time and result from output
    time_line = output[0]
    result_line = output[5]

    time = time_line[28:-2]
    optimal = result_line[9:]

    # catching errors
    try:
        float(time)
        float(optimal)
    except ValueError:
        #print("### model: " + model + " ERROR ###")
        #print("time:    ERROR ###")
        #print("optimal: ERROR ###\n")
        continue

    # printing results
    print("### model: " + model)
    print("time: " + time)
    print("optimal: " + optimal + "\n")
    #print("### model: " + model + " || optimal: " + optimal)
    sys.stdout.flush()


