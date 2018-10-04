#!/usr/bin/env python
#
# Stress test CPU hotplug
#
# Andrew F. Davis <afd@ti.com>

import random

up_cores = [0, 1, 2, 3]  # Cores all start on
down_cores = []

online_file = '/sys/devices/system/cpu/cpu{0}/online'


def core_change(core, direction):
    print("{0} core {1}".format("Starting" if direction == 'up' else "Stopping", core))
    f = open(online_file.format(core), 'r+', 0)
    target_value = '1' if direction == 'up' else '0'
    f.write(target_value)  # Bring core up/down
    f.seek(0)
    status = f.read()
    f.close()
    if status[0] != target_value[0]:
        raise NameError("Could not {} core {}".format("start" if direction == 'up' else "stop", core))


cpu_directions = ['down', 'up']
while True:
    direction = random.choice(cpu_directions)
    if direction == 'down':
        if len(up_cores) <= 1:  # need to keep at least 1 core alive
            continue
        core = random.choice(up_cores)
        core_change(core, direction)
        up_cores.remove(core)
        down_cores.append(core)
    elif direction == 'up':
        if not down_cores:  # no cores to bring up
            continue
        core = random.choice(down_cores)
        core_change(core, direction)
        down_cores.remove(core)
        up_cores.append(core)
